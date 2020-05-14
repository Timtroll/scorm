package Freee::EAV::Subscription;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

sub new {
    my ( $Class, $params ) = @_;

    $params = { Type => 'subscription' } if !defined( $params ) || !ref( $params ) || ref( $params ) ne 'HASH';

    my $Object = $Class->SUPER::new( $params );
    $Object->{CacheObject} = $Kernel::OM->Get('Kernel::System::Cache');

    if ( exists( $params->{id} ) ) {
        return $Object->Get( $params );
    }
    else {
        my $failed = 0;
        for my $f ( 'OwnerID', 'SLAID', 'ServiceID', 'title' ) {
            $failed = 1 if !exists( $params->{ $f } ) || !defined( $params->{ $f } );
        }
        return $Object->Create( $params ) if !$failed;
    }

    return $Object;
}

sub IsExists{
    my ( $self, $params ) = @_;

    my @Where = ();
    my %Required = (
        'OwnerID'   => 'owner_id ',
        'SLAID'     => 'sla_id',
        'ServiceID' => 'service_id',
        'deny'      => 'deny'
    );
    for my $Field ( keys %Required ) {
        if ( !exists( $params->{ $Field } ) || !defined( $params->{ $Field } ) ) {
            # $self->{LogObject}->Log(
            #     Priority    => 'error',
            #     Message     => 'Param '.$Field.' required!'
            # );
            return undef;
        }
        push @Where, $Required{$Field}." = ".$self->{dbh}->quote( $params->{ $Field } );
    }

    my $SQL = 'SELECT count(*) as exists FROM "public"."EAV_submodules_subscriptions" WHERE '.join(' AND ', @Where);
    $self->{Debug} && $self->{LogObject}->Dumper( $SQL );

    my $Result = $self->{dbh}->selectrow_hashref( $SQL );
    if ( my $Error = $self->{dbh}->errstr() ) {
        # $self->{LogObject}->Log(
        #     Priority    => 'error',
        #     Message     => 'Can\'t check item. SQL Error: ' . $Error
        # );
        return undef;
    }
    return $Result->{exists};
}

sub SubscriptionTitle{
    my ( $self, $params ) = @_;

    return undef() if !defined( $params ) || !ref( $params ) || ref( $params ) ne 'HASH';

    my $required = [ 'OwnerID', 'SLAID', 'ServiceID' ];
    for my $f ( @$required ) {
        return undef() if !exists( $params->{ $f } ) || !defined( $params->{ $f } );
    }

    return 'Owner'.$params->{OwnerID}.'SLA'.$params->{SLAID}.'Service'.$params->{ServiceID};
}

sub Create {
    my ( $self, $params ) = @_ ;

    my $Title = $self->SubscriptionTitle( $params );
    return undef if !$Title;

    if ( $self->IsExists( $params ) ) {
        $self->{LogObject}->Log(
            Priority    => 'error',
            Message     => "Subscription $Title already exists",
        );
        return;
    }

    my $owner = $self->_get( $params->{OwnerID} );
    return undef if !defined( $owner );

    my $s = $self->_create( {
        publish => $params->{data}->{publish} || 'true',
        parent => $self->{Root}->id(),
        title => $Title
    } );
    $self->{_item} = $s;
    $self->_MultiStore( $params->{data} ) if exists( $params->{data} ) && ref( $params->{data} ) && ref( $params->{data} ) eq 'HASH';
    $self->{Debug} && $self->{LogObject}->Dumper($params);
    $self->{dbh}->do(
        'INSERT INTO "public"."EAV_submodules_subscriptions" '.
        '( "owner_id", "sla_id", "service_id", "subscription_id", "distance", "owner_type", "deny", "address_id", "publish_alias", "type_subscription_alias" ) VALUES
        ( ' . int( $params->{OwnerID} ) . ', ' . int( $params->{SLAID} ) . ', ' . int( $params->{ServiceID} ) . ', '.$self->id() . ', 0, '.$self->{dbh}->quote( $owner->{type} ).', '.( $params->{deny} ? 'true' : 'false' ).', '.int( $params->{AddressID} || 0 ).', '.$self->_boolean_by_input( $params->{data}->{publish} ).', '.$self->_boolean_by_input( $params->{data}->{subscription}->{type_subscription} ).' ) '.
        'ON CONFLICT ON CONSTRAINT "EAV_submodules_subscriptions_pkey" DO NOTHING'
    );

    if ( $owner->{type} eq 'location' || $params->{AddressID} ) {
        my $LocID = int( $params->{OwnerID} || $params->{AddressID} );
        my $RegionID;
        # check if this is region
        my $Info = $self->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."EAV_submodules_locations" WHERE "id" = '.$LocID );
        $RegionID = $LocID if defined( $Info ) && !defined( $$Info{region} );
        if ( !defined( $RegionID ) ) {
            $RegionID = $self->{dbh}->selectrow_array(
                'SELECT i."id" FROM "public"."EAV_submodules_locations" AS i '.
                'INNER JOIN "public"."EAV_links" AS l ON l."parent" = i."id" AND l."id" = '.$LocID.
                'WHERE i."region" IS NULL '
            );
        }

        if ( $RegionID ) {
            my $Region = Kernel::System::EAV->new( 'Location', { id => $RegionID } );
            $Region->GroupLeader( \1 );
        }
        # $RegionID can not be undefined, but it is possible if owner->{type} ne 'location' and params->{AddressID} actually not from Locations tree.
    }

    # reset Service cache
    # $self->{CacheObject}->CleanUp(
    #     Type => 'Service',
    # );

    return $self;
}

sub publish {
    my ( $self, $params ) = @_;

    return undef() unless exists( $self->{_item} ) && $self->{_item}->{id};
    return $self->{_item}->{publish} unless defined( $params );

    return $self->{dbh}->do( 'UPDATE "public"."EAV_submodules_subscriptions" SET "publish_alias" = ' . $self->_boolean_by_input( $params ) . ' WHERE "subscription_id" = ' . $self->{_item}->{id} );
}

sub type_subscription {
    my ( $self, $params ) = @_;

    return undef() unless exists( $self->{_item} ) && $self->{_item}->{id};
    return $self->_get_field( 'type_subscription' ) unless defined( $params );

    return $self->{dbh}->do( 'UPDATE "public"."EAV_submodules_subscriptions" SET "type_subscription_alias" = ' . $self->_boolean_by_input( $params ) . ' WHERE "subscription_id" = ' . $self->{_item}->{id} );
};

sub Delete {
    my ($self) = @_;

    if ( !exists( $self->{_item} ) ) {
        $self->{LogObject}->Log(
            Priority => 'error',
            Message  => "No _item element!",
        );
        return undef;
    }

    $self->{dbh}->do( 'DELETE FROM "public"."EAV_submodules_subscriptions" WHERE "subscription_id" = ' . $self->id() );
    if ( my $Error = $self->{dbh}->errstr() ) {
        $self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Can\'t delete element! SQL error: '.$Error,
        );
        return undef;
    }

    #!!NB удаление EAV-объекта должно случаться после удаления из EAV_submodules_subscriptions из-за триггера AFTER DELETE. как оно сейчас и есть.
    return $self->_RealDelete();
}

sub List {
    my ( $self, $params ) = @_ ;

    return undef() if !defined( $params ) || !ref( $params ) || ref( $params ) ne 'HASH';

    my $call_source = @{[caller(1)]}[3]." from line ".@{[caller(0)]}[2];
    $self->{Debug} && $self->{LogObject}->Dumper( {
            Caller  => $call_source,
            Params  => $params
        } );

    my $required = [ 'OwnerID', 'SLAID', 'ServiceID' ];
    my $hasSubscriptionsFilterParams = 0;
    for my $f ( @$required ) {
        return undef() if !exists( $params->{ $f } ) || !defined( $params->{ $f } );
        $params->{ $f } = int( $params->{ $f } || 0 );
        $hasSubscriptionsFilterParams = 1 if $params->{ $f };
    }

    $hasSubscriptionsFilterParams = 1 if exists( $params->{FilterTitle} ) && defined( $params->{FilterTitle} ) && length( $params->{FilterTitle} ) > 3;
    $hasSubscriptionsFilterParams = 1 if exists( $params->{Subscriptions}->{deny} ) && defined( $params->{Subscriptions}->{deny} );
    $hasSubscriptionsFilterParams = 1 if exists( $params->{Subscriptions}->{isValid} ) && defined( $params->{Subscriptions}->{isValid} );
    $hasSubscriptionsFilterParams = 1 if exists( $params->{Subscriptions}->{Filter} ) && ref( $params->{Subscriptions}->{Filter} ) && ref( $params->{Subscriptions}->{Filter} ) eq 'HASH' && scalar( keys %{ $params->{Subscriptions}->{Filter} } );

    $self->{Debug} && $self->{LogObject}->Dumper( $params );

    my $ListParams = {};
    $ListParams->{Parents} = [ 0 ];
    $ListParams->{Filter} = {};

    my $useTitleFilter = 0;
    if ( exists( $params->{title} ) && defined( $params->{title} ) && ref( $params->{title} ) && ref( $params->{title} ) eq 'HASH' ) {
        $useTitleFilter = 1;
    }

    my $control;
    if ( $params->{OwnerID} > 0 ) {
        $control = $self->_get( $params->{OwnerID} );
        if ( defined( $control ) ) {
            $ListParams->{Parents} = { $control->{id} => 0 };
#            $p = [ $p->{id}, @{ $self->_get_childs( $p->{id} ) } ];
#            $pFilter = { import_type => [ $p->{Type}, 'user' ] }
        }
    }
    elsif( !$useTitleFilter ) {
        $ListParams->{Filter} = { 'Default.GroupLeader' => \1 };
    }

    my ( $BitMapMin, $BitMapMax, $bitmap_sql_c0, $bitmap_sql_c1 ) = ( undef(), undef(), '', '' );
    my $BitParams = {
        publish => {
            value => exists( $params->{Subscriptions}->{isValid} ) && defined( $params->{Subscriptions}->{isValid} ) ? $params->{Subscriptions}->{isValid} : undef(),
            true => 2,
            false => 1
        },
        type => {
            value => exists( $params->{Subscriptions}->{Filter}->{'subscription.type_subscription'} ) && defined( $params->{Subscriptions}->{Filter}->{'subscription.type_subscription'} ) ? $params->{Subscriptions}->{Filter}->{'subscription.type_subscription'} : undef(),
            true => 8,
            false => 4
        },
        deny => {
            value => exists( $params->{Subscriptions}->{deny} ) && defined( $params->{Subscriptions}->{deny} ) ? $params->{Subscriptions}->{deny} : undef(),
            true => 32,
            false => 16
        }
    };

    my $HasBitmapParams = 0;
    for my $key ( keys %$BitParams ) {
        if ( !defined( $BitParams->{ $key }->{value} ) ) {
            $bitmap_sql_c1 .= ' AND c1.bitmap & '.$BitParams->{ $key }->{true}.' = 0 AND c1.bitmap & '.$BitParams->{ $key }->{false}.' = 0';
            $bitmap_sql_c0 .= ' AND c0.bitmap & '.$BitParams->{ $key }->{true}.' = 0 AND c0.bitmap & '.$BitParams->{ $key }->{false}.' = 0';
            next;
        }
        $HasBitmapParams = 1;
        my $CheckBit = $BitParams->{ $key }->{value} ? $BitParams->{ $key }->{true} : $BitParams->{ $key }->{false};
        $bitmap_sql_c1 .= ' AND c1.bitmap & '.$CheckBit.' > 0';
        $bitmap_sql_c0 .= ' AND c0.bitmap & '.$CheckBit.' > 0';
    }

    if ( !$HasBitmapParams ) {
        $bitmap_sql_c1 = ' AND c1.bitmap = 0';
        $bitmap_sql_c0 = ' AND c0.bitmap = 0';
    }

    $ListParams->{JOIN} = ' '.
        ( $useTitleFilter ? 'INNER' : 'LEFT' ).' JOIN "public"."EAV_submodules_subscriptions_counts" AS c1 ON c1."item_id" = items."id" '.$bitmap_sql_c1.' '.#AND c1."distance" != 0
        'LEFT JOIN "public"."EAV_submodules_subscriptions_counts" AS c0 ON c0."item_id" = items."id" AND c0."distance" = 0  '.$bitmap_sql_c0.' ';
#    $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts" AS c1 ON c1."item_id" = items."id" ' if $useTitleFilter;

    if ( exists( $params->{SLAID} ) && $params->{SLAID} && exists( $params->{ServiceID} ) && $params->{ServiceID} ) {
        $ListParams->{JOIN} = ' '.
            'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $params->{SLAID} || 0 ).' AND c1."service_id" = '.int( $params->{ServiceID} || 0 ).'  '.$bitmap_sql_c1.' '.#AND c1."distance" != 0
            'LEFT JOIN "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" AS c0 ON c0."item_id" = items."id" AND c0."sla_id" = '.int( $params->{SLAID} || 0 ).' AND c0."service_id" = '.int( $params->{ServiceID} || 0 ).' AND c0."distance" = 0 '.$bitmap_sql_c0.' ';
#        $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $params->{SLAID} || 0 ).' AND c1."service_id" = '.int( $params->{ServiceID} || 0 ).' ';
    }
    elsif ( exists( $params->{SLAID} ) && $params->{SLAID} ) {
        $ListParams->{JOIN} = ' '.
            'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $params->{SLAID} || 0 ).' '.$bitmap_sql_c1.' '.
            'LEFT JOIN "public"."EAV_submodules_subscriptions_counts_with_sla" AS c0 ON c0."item_id" = items."id" AND c0."sla_id" = '.int( $params->{SLAID} || 0 ).' AND c0."distance" = 0 '.$bitmap_sql_c0.' ';
#        $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $params->{SLAID} || 0 ).' ';
    }
    elsif ( exists( $params->{ServiceID} ) && $params->{ServiceID} ) {
        $ListParams->{JOIN} = ' '.
            'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_service" AS c1 ON c1."item_id" = items."id" AND c1."service_id" = '.int( $params->{ServiceID} || 0 ).' '.$bitmap_sql_c1.' '.
            'LEFT JOIN "public"."EAV_submodules_subscriptions_counts_with_service" AS c0 ON c0."item_id" = items."id" AND c0."service_id" = '.int( $params->{ServiceID} || 0 ).' AND c0."distance" = 0 '.$bitmap_sql_c0.' ';
#        $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_service" AS c1 ON c1."item_id" = items."id" AND c1."service_id" = '.int( $params->{ServiceID} || 0 ).' ';
    }
    if ( $useTitleFilter ) {
        $ListParams->{JOIN} .= ' '.
            'INNER JOIN "public"."EAV_items" AS iTitleFilter ON '.
                'iTitleFilter."id" = c1."item_id" AND '.
                ( exists( $params->{title}->{type} ) && defined( $params->{title}->{type} ) ? 'iTitleFilter."import_type" = '.$self->{dbh}->quote( $params->{title}->{type} ).' AND ' : '' ).
                'lower(iTitleFilter."title") '.$self->_MakeFilterStatement( { value => $params->{title}, prefix => '' } );
    }

#    $ListParams->{FIELDS} = ', INJECTION."Count0", INJECTION."Count" ';
    $ListParams->{FIELDS} = 'items."id", items."import_type", MIN(c0."count") AS "Count0", SUM(c1."count") AS "Count" ';
#    $ListParams->{INJECTION} = '( SELECT items."id", MIN(c0."count") AS "Count0", SUM(c1."count") AS "Count" FROM "public"."EAV_items" AS items '.$CountersSQL.' WHERE items."publish" = true GROUP BY items."id" ) AS INJECTION INNER JOIN ';
    $ListParams->{GROUP_BY} = 'GROUP BY items."id", items."import_type"';
    for my $p ( keys %$params ) {
        if ( !exists( $ListParams->{ $p } ) ) {
            $ListParams->{ $p } = $params->{ $p };
        }
    }

    my $sql = $self->_list( { %$ListParams, SQLResult => 1 } );
    $self->{Debug} && $self->{LogObject}->Dumper( \$sql );
    my $items = $self->_list( $ListParams );
    $self->{Debug} && $self->{LogObject}->Dumper( \$hasSubscriptionsFilterParams );

    $items = [
        map {
            my $title = $_->{Object}->GetTitle();
            if ( $useTitleFilter && $_->{data}->{import_type} ne 'location' ) {
                my @c = $_->{Object}->BreadCrumbsArray( );
                $title = join( ' | ', map{ $_->{title} } @c );
            }
            $_->{Object}->{_item}->{import_type} = $_->{Object}->{_item}->{Type};
            $_ = { %{ $_->{data} }, %{ $_->{Object}->{_item} }, title => $title };
            $_
        } grep {
            $_->{data}->{Count} || $_->{data}->{Count0} || ( !$useTitleFilter && $_->{Object}->GroupLeader() )
        } map {
            my $r = { data => $_, Object => Kernel::System::EAV->new( ucfirst( $_->{import_type} ), { id => $_->{id} } ) };
            $r
        } @$items
    ];

    $hasSubscriptionsFilterParams = 1 if !scalar( @$items );

    if ( $hasSubscriptionsFilterParams && ( $params->{OwnerID} > 0 || $params->{ServiceID} > 0  ) ) {
        #подписки от текущей ноды.
        my @ListParams;
        ( @ListParams ) = ( $self->_list( { %{ $params->{Subscriptions} }, SQLResult => 1 } ) ) if exists( $params->{Subscriptions} ) && ref( $params->{Subscriptions} ) && ref( $params->{Subscriptions} ) eq 'HASH';
        my $Addons = {};
        if ( scalar( @ListParams ) ) {
            for my $key ( keys %{ $ListParams[1] } ) {
                $Addons->{ $key } = ${$ListParams[1]->{ $key }} if defined( ${$ListParams[1]->{ $key }} ) && length( ${$ListParams[1]->{ $key }} );
            }
        }

        $sql =
            'SELECT items.*, s.*, dContract."data" AS "contract" '.( exists( $$Addons{SelectFields} ) ? $$Addons{SelectFields} : '' ).' '.
            'FROM "public"."EAV_submodules_subscriptions" AS s '.
            'INNER JOIN "public"."EAV_items" AS items ON s.subscription_id = items."id" '.
            'LEFT JOIN "public"."EAV_data_string" AS dContract ON dContract."id" = items."id" AND dContract."field_id" = EAV_getFieldID( \'subscription\', \'contract\' ) '.
#            ( exists( $params->{Subscriptions}->{AddressID} ) && $params->{Subscriptions}->{AddressID} ?
#                'INNER JOIN "public"."EAV_links" AS sAddressFilter ON ( sAddressFilter."parent" = s."address_id" ) '
#            ).
            ( exists( $params->{Subscriptions}->{isValid} ) && defined( $params->{Subscriptions}->{isValid} ) ? ' AND items."publish" = '.( $params->{Subscriptions}->{isValid} ? 'true': 'false' ) : '' ).' '.
####            ( defined( $control ) ? 'LEFT JOIN "public"."EAV_links" AS control_link ON control_link."parent" = '.$control->{id}.' AND control_link."id" = s."owner_id" ' : '' ).
            (
                exists( $params->{FilterTitle} ) && defined( $params->{FilterTitle} ) && length( $params->{FilterTitle} ) > 3 ?
                    $self->_MakeFilterStatement( { value => { ILIKE => '%'.$params->{FilterTitle}.'%' }, prefix => 'INNER JOIN "public"."EAV_items" AS iC ON s.owner_id = iC."id"  AND iC."title" ' } ) : ''
            ).
            ( exists( $$Addons{Data} ) ? $$Addons{Data} : '' ).' '.
            ( exists( $$Addons{Filter} ) ? $$Addons{Filter} : '' ).' '.
            'WHERE 1 = 1 ';
####        $sql .= ' AND ( s."owner_id" = '.$control->{id}.' OR control_link."distance" IS NOT NULL ) ' if defined( $control );
        $sql .= ' AND s."owner_id" = '.$control->{id} if defined( $control );
        $sql .= ' AND s."sla_id" = '.int( $params->{SLAID} ) if $params->{SLAID};
        $sql .= ' AND s."service_id" = '.int( $params->{ServiceID} ) if $params->{ServiceID};
        $sql .= ' AND s."address_id" = '.int( $params->{AddressID} ) if $params->{AddressID};
        $sql .= exists( $params->{Subscriptions}->{deny} ) && defined( $params->{Subscriptions}->{deny} ) ? ' AND s.deny = '.( $params->{Subscriptions}->{deny} ? 'true' : 'false' ) : '';
        $self->{Debug} && $self->{LogObject}->Dumper( $sql );

        my $sth = $self->{dbh}->prepare( $sql );
        $sth->execute();
        my $subscriptions = $sth->fetchall_arrayref({});
        $sth->finish();

        my %SLAList = $Kernel::OM->Get('Kernel::System::SLAGroup')->SLAGroupList(
            Valid   => 'valid',
            Return  => 'HASH'
        );

        push @$items, map { $_->{SLATitle} = $SLAList{ $_->{sla_id} }; $_ } @$subscriptions;
    }

    return $items;
}

sub Get {
    my ( $self, $params ) = @_;

    return undef() unless defined( $params );
    my $id = ref( $params ) && ref( $params ) eq 'HASH' ? int( $params->{id} || 0 ) : int( $params || 0 );
    return undef() unless $id;

    my $try = $self->_get( $id );
    if ( defined( $try ) ) {
        $self->{_item} = $try;
        my $r = $self->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."EAV_submodules_subscriptions" WHERE subscription_id = '.$id );
        delete( $$r{subscription_id} );
        $self->{_item} = { %{ $self->{_item} }, %$r };

        return $self;
    }

    return undef();
}

sub Store {
    my ( $self, $params ) = @_;

    return undef() unless defined( $params );

    my $owner = $self->_get( $self->owner_id() );
    return undef() unless defined( $owner );

    #!!NB - по-скольку есть триггер на AFTER UPDATE на submodules_subscriptions - update EAV-данных подписки должен идти раньше чем апдейт главной таблицы.
    $self->_MultiStore( $params->{data} );
    #!!?? я сейчас не совсем понимаю зачем я здесь требую совпадения первичного ключа, если subscription_id вполне себе уникальный..
    #м.б. я имел в виду что группы этих параметров могут указывать на один и тот же сабскрипшен ? да, но зачем ?
    $self->{dbh}->do(
        'UPDATE "public"."EAV_submodules_subscriptions" SET "deny" = '.( $params->{deny} ? 'true' : 'false' ).' WHERE '.
        '"owner_id" = '.$self->owner_id().' AND "sla_id" = '.$self->sla_id().' AND "service_id" = '.$self->service_id().' AND "subscription_id" = '.$self->id().' AND "distance" = 0 AND "owner_type" = '.$self->{dbh}->quote( $owner->{type} ).' '
    );
    # reset Service cache
    $self->{CacheObject}->CleanUp(
        Type => 'Service',
    );
    $self->{CacheObject}->CleanUp(
        Type => 'SubscriptionContracts',
    );

    return 1;
}

sub ListByServices {
    my ( $self, $params ) = @_ ;
    return undef() if !defined( $params ) || !ref( $params ) || ref( $params ) ne 'HASH';
    my $ServiceID = int( $params->{ServiceID} || 0 );
    my $TreeID = int( $params->{OwnerID} || 0 );

    my $sql;
    if ( !$ServiceID ) {
        $sql = 'SELECT "service_id", COUNT( "owner_id" ) AS "count" FROM "public"."EAV_submodules_subscriptions" GROUP BY "service_id"';
    }
    else {
        $sql =
            'SELECT i.*, COUNT(s.owner_id)  FROM "public"."EAV_submodules_subscriptions" AS s '.
            'INNER JOIN "public"."EAV_links" AS l ON l."id" = s."owner_id" '.
            'INNER JOIN "public"."EAV_links" AS lP ON lP."id" = l."parent" AND lP."parent" = '.$TreeID.' AND lP.distance = 0 '.
            'INNER JOIN "public"."EAV_items" AS i ON i."id" = lP."id" '.
            'WHERE s."service_id" = ' . $ServiceID . ' '.
            'GROUP BY i."id"';
    }

    my $res = [];
    my $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();
    $res = $sth->fetchall_arrayref({});
    $sth->finish();

    return $res;
}

sub GetContrcatBySubscription {
    my ( $self, %param ) = @_;

    return if ( !%param || !$param{SubscriptionID} );

    # my $Cache = $self->{CacheObject}->Get(
    #     Type => 'SubscriptionContracts',
    #     Key  => 'All'
    # );
    # if( $Cache && defined( $Cache->{$param{SubscriptionID}} ) ){
    #     return $Cache->{$param{SubscriptionID}};
    # }

    my $Sql = 'SELECT id, data FROM "EAV_data_string" WHERE field_id = EAV_GetFieldID( \'subscription\', \'contract\' )';
    my $Data = $self->{dbh}->selectall_arrayref( $Sql, { Slice => {} } );

    if ( $Data && ref( $Data ) eq 'ARRAY' && @$Data ) {
        my %Store = map{ $_->{id} => $_->{data} }@$Data;
        # $self->{CacheObject}->Set(
        #     Type    => 'SubscriptionContracts',
        #     Key     => 'All',
        #     Value   => \%Store
        # );
        return $Store{$param{SubscriptionID}};
    }

    return;
}

1;
