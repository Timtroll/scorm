package Mojolicious::EAV::Subscription;

use parent 'Mojolicious::EAV::Base';
use strict;
use warnings;

sub new {
    my ( $Class, $Params ) = @_;
    $Params = { Type => 'subscription' } if !defined( $Params ) || !ref( $Params ) || ref( $Params ) ne 'HASH';
    my $Object = $Class->SUPER::new( $Params );
    $Object->{CacheObject} = $Kernel::OM->Get('Kernel::System::Cache');

    if ( exists( $Params->{id} ) ) {
        return $Object->Get( $Params );
    } else {
        my $failed = 0;
        foreach my $f ( 'OwnerID', 'SLAID', 'ServiceID', 'title' ) {
            $failed = 1 if !exists( $Params->{ $f } ) || !defined( $Params->{ $f } );
        };
        return $Object->Create( $Params ) if !$failed;
    }

    return $Object;
};

sub IsExists{
    my ( $Self, $Params ) = @_;

    my @Where = ();
    my %Required = (
        'OwnerID'   => 'owner_id ',
        'SLAID'     => 'sla_id',
        'ServiceID' => 'service_id',
        'deny'      => 'deny'
    );
    foreach my $Field ( keys %Required ) {
        if ( !exists( $Params->{ $Field } ) || !defined( $Params->{ $Field } ) ){
            $Self->{LogObject}->Log(
                Priority    => 'error',
                Message     => 'Param '.$Field.' required!'
            );
            return undef;
        }
        push @Where, $Required{$Field}." = ".$Self->{dbh}->quote( $Params->{ $Field } );
    };

    my $SQL = 'SELECT count(*) as exists FROM "public"."EAV_submodules_subscriptions" WHERE '.join(' AND ', @Where);
    $Self->{Debug} && $Self->{LogObject}->Dumper( $SQL );

    my $Result = $Self->{dbh}->selectrow_hashref( $SQL );
    if( my $Error = $Self->{dbh}->errstr() ){
        $Self->{LogObject}->Log(
            Priority    => 'error',
            Message     => 'Can\'t check item. SQL Error: ' . $Error
        );
        return undef;
    }
    return $Result->{exists};
}

sub SubscriptionTitle{
    my ( $Self, $Params ) = @_;

    return undef() if !defined( $Params ) || !ref( $Params ) || ref( $Params ) ne 'HASH';
    my $required = [ 'OwnerID', 'SLAID', 'ServiceID' ];
    foreach my $f ( @$required ) {
        return undef() if !exists( $Params->{ $f } ) || !defined( $Params->{ $f } );
    };

    return 'Owner'.$Params->{OwnerID}.'SLA'.$Params->{SLAID}.'Service'.$Params->{ServiceID};
}

sub Create {
    my ( $Self, $Params ) = @_ ;

    my $Title = $Self->SubscriptionTitle( $Params );
    return undef if !$Title;

    if( $Self->IsExists( $Params ) ){
        $Self->{LogObject}->Log(
            Priority    => 'error',
            Message     => "Subscription $Title already exists",
        );
        return;
    }

    my $owner = $Self->_get( $Params->{OwnerID} );
    return undef if !defined( $owner );

    my $s = $Self->_create( {
        publish => $Params->{data}->{publish} || 'true',
        parent => $Self->{Root}->id(),
        title => $Title
    } );
    $Self->{_item} = $s;
    $Self->_MultiStore( $Params->{data} ) if exists( $Params->{data} ) && ref( $Params->{data} ) && ref( $Params->{data} ) eq 'HASH';
    $Self->{Debug} && $Self->{LogObject}->Dumper($Params);
    $Self->{dbh}->do(
        'INSERT INTO "public"."EAV_submodules_subscriptions" '.
        '( "owner_id", "sla_id", "service_id", "subscription_id", "distance", "owner_type", "deny", "address_id", "publish_alias", "type_subscription_alias" ) VALUES
        ( '.int( $Params->{OwnerID} ).', '.int( $Params->{SLAID} ).', '.int( $Params->{ServiceID} ).', '.$Self->id().', 0, '.$Self->{dbh}->quote( $owner->{type} ).', '.( $Params->{deny} ? 'true' : 'false' ).', '.int( $Params->{AddressID} || 0 ).', '.$Self->_boolean_by_input( $Params->{data}->{publish} ).', '.$Self->_boolean_by_input( $Params->{data}->{subscription}->{type_subscription} ).' ) '.
        'ON CONFLICT ON CONSTRAINT "EAV_submodules_subscriptions_pkey" DO NOTHING'
    );

    if ( $owner->{type} eq 'location' || $Params->{AddressID} ) {
        my $LocID = int( $Params->{OwnerID} || $Params->{AddressID} );
        my $RegionID;
        # check if this is region
        my $Info = $Self->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."EAV_submodules_locations" WHERE "id" = '.$LocID );
        $RegionID = $LocID if defined( $Info ) && !defined( $$Info{region} );
        if ( !defined( $RegionID ) ) {
            $RegionID = $Self->{dbh}->selectrow_array(
                'SELECT i."id" FROM "public"."EAV_submodules_locations" AS i '.
                'INNER JOIN "public"."EAV_links" AS l ON l."parent" = i."id" AND l."id" = '.$LocID.
                'WHERE i."region" IS NULL '
            );
        };

        if ( $RegionID ) {
            my $Region = Kernel::System::EAV->new( 'Location', { id => $RegionID } );
            $Region->GroupLeader( \1 );
        };
        # $RegionID can not be undefined, but it is possible if owner->{type} ne 'location' and Params->{AddressID} actually not from Locations tree.
    };

    # reset Service cache
    $Self->{CacheObject}->CleanUp(
        Type => 'Service',
    );

    return $Self;
}

sub publish {
    my ( $Self, $Params ) = @_;
    return undef() unless exists( $Self->{_item} ) && $Self->{_item}->{id};
    return $Self->{_item}->{publish} unless defined( $Params );

    return $Self->{dbh}->do( 'UPDATE "public"."EAV_submodules_subscriptions" SET "publish_alias" = '.$Self->_boolean_by_input( $Params ).' WHERE "subscription_id" = '.$Self->{_item}->{id} );
};

sub type_subscription {
    my ( $Self, $Params ) = @_;
    return undef() unless exists( $Self->{_item} ) && $Self->{_item}->{id};
    return $Self->_get_field( 'type_subscription' ) unless defined( $Params );

    return $Self->{dbh}->do( 'UPDATE "public"."EAV_submodules_subscriptions" SET "type_subscription_alias" = '.$Self->_boolean_by_input( $Params ).' WHERE "subscription_id" = '.$Self->{_item}->{id} );
};

sub Delete {
    my ($Self) = @_;

    if ( !exists( $Self->{_item} ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "No _item element!",
        );
        return undef;
    }

    $Self->{dbh}->do( 'DELETE FROM "public"."EAV_submodules_subscriptions" WHERE "subscription_id" = ' . $Self->id() );
    if ( my $Error = $Self->{dbh}->errstr() ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Can\'t delete element! SQL error: '.$Error,
        );
        return undef;
    }

    # reset Service cache
    $Self->{CacheObject}->CleanUp(
        Type => 'Service',
    );

    #!!NB удаление EAV-объекта должно случаться после удаления из EAV_submodules_subscriptions из-за триггера AFTER DELETE. как оно сейчас и есть.
    return $Self->_RealDelete();
}

sub List {
    my ( $Self, $Params ) = @_ ;
    return undef() if !defined( $Params ) || !ref( $Params ) || ref( $Params ) ne 'HASH';

    my $call_source = @{[caller(1)]}[3]." from line ".@{[caller(0)]}[2];
    $Self->{Debug} && $Self->{LogObject}->Dumper( {
                Caller  => $call_source,
                Params  => $Params
            } );

    my $required = [ 'OwnerID', 'SLAID', 'ServiceID' ];
    my $hasSubscriptionsFilterParams = 0;
    foreach my $f ( @$required ) {
        return undef() if !exists( $Params->{ $f } ) || !defined( $Params->{ $f } );
        $Params->{ $f } = int( $Params->{ $f } || 0 );
        $hasSubscriptionsFilterParams = 1 if $Params->{ $f };
    };
    $hasSubscriptionsFilterParams = 1 if exists( $Params->{FilterTitle} ) && defined( $Params->{FilterTitle} ) && length( $Params->{FilterTitle} ) > 3;
    $hasSubscriptionsFilterParams = 1 if exists( $Params->{Subscriptions}->{deny} ) && defined( $Params->{Subscriptions}->{deny} );
    $hasSubscriptionsFilterParams = 1 if exists( $Params->{Subscriptions}->{isValid} ) && defined( $Params->{Subscriptions}->{isValid} );
    $hasSubscriptionsFilterParams = 1 if exists( $Params->{Subscriptions}->{Filter} ) && ref( $Params->{Subscriptions}->{Filter} ) && ref( $Params->{Subscriptions}->{Filter} ) eq 'HASH' && scalar( keys %{ $Params->{Subscriptions}->{Filter} } );

    $Self->{Debug} && $Self->{LogObject}->Dumper( $Params );

    my $ListParams = {};
    $ListParams->{Parents} = [ 0 ];
    $ListParams->{Filter} = {};

    my $useTitleFilter = 0;
    if ( exists( $Params->{title} ) && defined( $Params->{title} ) && ref( $Params->{title} ) && ref( $Params->{title} ) eq 'HASH' ) {
        $useTitleFilter = 1;
    };

    my $control;
    if ( $Params->{OwnerID} > 0 ) {
        $control = $Self->_get( $Params->{OwnerID} );
        if ( defined( $control ) ) {
            $ListParams->{Parents} = { $control->{id} => 0 };
#            $p = [ $p->{id}, @{ $Self->_get_childs( $p->{id} ) } ];
#            $pFilter = { import_type => [ $p->{Type}, 'user' ] }
        };
    } elsif( !$useTitleFilter ) {
        $ListParams->{Filter} = { 'Default.GroupLeader' => \1 };
    };

    my ( $BitMapMin, $BitMapMax, $bitmap_sql_c0, $bitmap_sql_c1 ) = ( undef(), undef(), '', '' );
    my $BitParams = {
        publish => {
            value => exists( $Params->{Subscriptions}->{isValid} ) && defined( $Params->{Subscriptions}->{isValid} ) ? $Params->{Subscriptions}->{isValid} : undef(),
            true => 2,
            false => 1
        },
        type => {
            value => exists( $Params->{Subscriptions}->{Filter}->{'subscription.type_subscription'} ) && defined( $Params->{Subscriptions}->{Filter}->{'subscription.type_subscription'} ) ? $Params->{Subscriptions}->{Filter}->{'subscription.type_subscription'} : undef(),
            true => 8,
            false => 4
        },
        deny => {
            value => exists( $Params->{Subscriptions}->{deny} ) && defined( $Params->{Subscriptions}->{deny} ) ? $Params->{Subscriptions}->{deny} : undef(),
            true => 32,
            false => 16
        }
    };

    my $HasBitmapParams = 0;
    foreach my $key ( keys %$BitParams ) {
        if ( !defined( $BitParams->{ $key }->{value} ) ) {
            $bitmap_sql_c1 .= ' AND c1.bitmap & '.$BitParams->{ $key }->{true}.' = 0 AND c1.bitmap & '.$BitParams->{ $key }->{false}.' = 0';
            $bitmap_sql_c0 .= ' AND c0.bitmap & '.$BitParams->{ $key }->{true}.' = 0 AND c0.bitmap & '.$BitParams->{ $key }->{false}.' = 0';
            next;
        };
        $HasBitmapParams = 1;
        my $CheckBit = $BitParams->{ $key }->{value} ? $BitParams->{ $key }->{true} : $BitParams->{ $key }->{false};
        $bitmap_sql_c1 .= ' AND c1.bitmap & '.$CheckBit.' > 0';
        $bitmap_sql_c0 .= ' AND c0.bitmap & '.$CheckBit.' > 0';
    };

    if ( !$HasBitmapParams ) {
        $bitmap_sql_c1 = ' AND c1.bitmap = 0';
        $bitmap_sql_c0 = ' AND c0.bitmap = 0';
    };

    $ListParams->{JOIN} = ' '.
        ( $useTitleFilter ? 'INNER' : 'LEFT' ).' JOIN "public"."EAV_submodules_subscriptions_counts" AS c1 ON c1."item_id" = items."id" '.$bitmap_sql_c1.' '.#AND c1."distance" != 0
        'LEFT JOIN "public"."EAV_submodules_subscriptions_counts" AS c0 ON c0."item_id" = items."id" AND c0."distance" = 0  '.$bitmap_sql_c0.' ';
#    $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts" AS c1 ON c1."item_id" = items."id" ' if $useTitleFilter;

    if ( exists( $Params->{SLAID} ) && $Params->{SLAID} && exists( $Params->{ServiceID} ) && $Params->{ServiceID} ) {
        $ListParams->{JOIN} = ' '.
            'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $Params->{SLAID} || 0 ).' AND c1."service_id" = '.int( $Params->{ServiceID} || 0 ).'  '.$bitmap_sql_c1.' '.#AND c1."distance" != 0
            'LEFT JOIN "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" AS c0 ON c0."item_id" = items."id" AND c0."sla_id" = '.int( $Params->{SLAID} || 0 ).' AND c0."service_id" = '.int( $Params->{ServiceID} || 0 ).' AND c0."distance" = 0 '.$bitmap_sql_c0.' ';
#        $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $Params->{SLAID} || 0 ).' AND c1."service_id" = '.int( $Params->{ServiceID} || 0 ).' ';
    } elsif ( exists( $Params->{SLAID} ) && $Params->{SLAID} ) {
        $ListParams->{JOIN} = ' '.
            'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $Params->{SLAID} || 0 ).' '.$bitmap_sql_c1.' '.
            'LEFT JOIN "public"."EAV_submodules_subscriptions_counts_with_sla" AS c0 ON c0."item_id" = items."id" AND c0."sla_id" = '.int( $Params->{SLAID} || 0 ).' AND c0."distance" = 0 '.$bitmap_sql_c0.' ';
#        $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_sla" AS c1 ON c1."item_id" = items."id" AND c1."sla_id" = '.int( $Params->{SLAID} || 0 ).' ';
    } elsif ( exists( $Params->{ServiceID} ) && $Params->{ServiceID} ) {
        $ListParams->{JOIN} = ' '.
            'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_service" AS c1 ON c1."item_id" = items."id" AND c1."service_id" = '.int( $Params->{ServiceID} || 0 ).' '.$bitmap_sql_c1.' '.
            'LEFT JOIN "public"."EAV_submodules_subscriptions_counts_with_service" AS c0 ON c0."item_id" = items."id" AND c0."service_id" = '.int( $Params->{ServiceID} || 0 ).' AND c0."distance" = 0 '.$bitmap_sql_c0.' ';
#        $ListParams->{JOIN} = 'INNER JOIN "public"."EAV_submodules_subscriptions_counts_with_service" AS c1 ON c1."item_id" = items."id" AND c1."service_id" = '.int( $Params->{ServiceID} || 0 ).' ';
    };
    if ( $useTitleFilter ) {
        $ListParams->{JOIN} .= ' '.
            'INNER JOIN "public"."EAV_items" AS iTitleFilter ON '.
                'iTitleFilter."id" = c1."item_id" AND '.
                ( exists( $Params->{title}->{type} ) && defined( $Params->{title}->{type} ) ? 'iTitleFilter."import_type" = '.$Self->{dbh}->quote( $Params->{title}->{type} ).' AND ' : '' ).
                'lower(iTitleFilter."title") '.$Self->_MakeFilterStatement( { value => $Params->{title}, prefix => '' } );
    };

#    $ListParams->{FIELDS} = ', INJECTION."Count0", INJECTION."Count" ';
    $ListParams->{FIELDS} = 'items."id", items."import_type", MIN(c0."count") AS "Count0", SUM(c1."count") AS "Count" ';
#    $ListParams->{INJECTION} = '( SELECT items."id", MIN(c0."count") AS "Count0", SUM(c1."count") AS "Count" FROM "public"."EAV_items" AS items '.$CountersSQL.' WHERE items."publish" = true GROUP BY items."id" ) AS INJECTION INNER JOIN ';
    $ListParams->{GROUP_BY} = 'GROUP BY items."id", items."import_type"';
    foreach my $p ( keys %$Params ) {
        if ( !exists( $ListParams->{ $p } ) ) {
            $ListParams->{ $p } = $Params->{ $p };
        };
    };

    my $sql = $Self->_list( { %$ListParams, SQLResult => 1 } );
    $Self->{Debug} && $Self->{LogObject}->Dumper( \$sql );
    my $items = $Self->_list( $ListParams );
    $Self->{Debug} && $Self->{LogObject}->Dumper( \$hasSubscriptionsFilterParams );

    $items = [ map {
        my $title = $_->{Object}->GetTitle();
        if ( $useTitleFilter && $_->{data}->{import_type} ne 'location' ) {
            my @c = $_->{Object}->BreadCrumbsArray( );
            $title = join( ' | ', map{ $_->{title} } @c );
        };
        $_->{Object}->{_item}->{import_type} = $_->{Object}->{_item}->{Type};
        $_ = { %{ $_->{data} }, %{ $_->{Object}->{_item} }, title => $title };
        $_
    } grep {
        $_->{data}->{Count} || $_->{data}->{Count0} || ( !$useTitleFilter && $_->{Object}->GroupLeader() )
    } map {
        my $r = { data => $_, Object => Kernel::System::EAV->new( ucfirst( $_->{import_type} ), { id => $_->{id} } ) };
        $r
    } @$items ];

    $hasSubscriptionsFilterParams = 1 if !scalar( @$items );

    if ( $hasSubscriptionsFilterParams && ( $Params->{OwnerID} > 0 || $Params->{ServiceID} > 0  ) ) {
        #подписки от текущей ноды.
        my @ListParams;
        ( @ListParams ) = ( $Self->_list( { %{ $Params->{Subscriptions} }, SQLResult => 1 } ) ) if exists( $Params->{Subscriptions} ) && ref( $Params->{Subscriptions} ) && ref( $Params->{Subscriptions} ) eq 'HASH';
        my $Addons = {};
        if ( scalar( @ListParams ) ) {
            foreach my $key ( keys %{ $ListParams[1] } ) {
                $Addons->{ $key } = ${$ListParams[1]->{ $key }} if defined( ${$ListParams[1]->{ $key }} ) && length( ${$ListParams[1]->{ $key }} );
            };
        };

        $sql =
            'SELECT items.*, s.* '.( exists( $$Addons{SelectFields} ) ? $$Addons{SelectFields} : '' ).' '.
            'FROM "public"."EAV_submodules_subscriptions" AS s '.
            'INNER JOIN "public"."EAV_items" AS items ON s.subscription_id = items."id" '.
#            ( exists( $Params->{Subscriptions}->{AddressID} ) && $Params->{Subscriptions}->{AddressID} ?
#                'INNER JOIN "public"."EAV_links" AS sAddressFilter ON ( sAddressFilter."parent" = s."address_id" ) '
#            ).
            ( exists( $Params->{Subscriptions}->{isValid} ) && defined( $Params->{Subscriptions}->{isValid} ) ? ' AND items."publish" = '.( $Params->{Subscriptions}->{isValid} ? 'true': 'false' ) : '' ).' '.
####            ( defined( $control ) ? 'LEFT JOIN "public"."EAV_links" AS control_link ON control_link."parent" = '.$control->{id}.' AND control_link."id" = s."owner_id" ' : '' ).
            (
                exists( $Params->{FilterTitle} ) && defined( $Params->{FilterTitle} ) && length( $Params->{FilterTitle} ) > 3 ?
                    $Self->_MakeFilterStatement( { value => { ILIKE => '%'.$Params->{FilterTitle}.'%' }, prefix => 'INNER JOIN "public"."EAV_items" AS iC ON s.owner_id = iC."id"  AND iC."title" ' } ) : ''
            ).
            ( exists( $$Addons{Data} ) ? $$Addons{Data} : '' ).' '.
            ( exists( $$Addons{Filter} ) ? $$Addons{Filter} : '' ).' '.
            'WHERE 1 = 1 ';
####        $sql .= ' AND ( s."owner_id" = '.$control->{id}.' OR control_link."distance" IS NOT NULL ) ' if defined( $control );
        $sql .= ' AND s."owner_id" = '.$control->{id} if defined( $control );
        $sql .= ' AND s."sla_id" = '.int( $Params->{SLAID} ) if $Params->{SLAID};
        $sql .= ' AND s."service_id" = '.int( $Params->{ServiceID} ) if $Params->{ServiceID};
        $sql .= ' AND s."address_id" = '.int( $Params->{AddressID} ) if $Params->{AddressID};
        $sql .= exists( $Params->{Subscriptions}->{deny} ) && defined( $Params->{Subscriptions}->{deny} ) ? ' AND s.deny = '.( $Params->{Subscriptions}->{deny} ? 'true' : 'false' ) : '';
        $Self->{Debug} && $Self->{LogObject}->Dumper( $sql );

        my $sth = $Self->{dbh}->prepare( $sql );
        $sth->execute();
        my $subscriptions = $sth->fetchall_arrayref({});
        $sth->finish();

        my %SLAList = $Kernel::OM->Get('Kernel::System::SLAGroup')->SLAGroupList(
            Valid   => 'valid',
            Return  => 'HASH'
        );

        push @$items, map { $_->{SLATitle} = $SLAList{ $_->{sla_id} }; $_ } @$subscriptions;
    };

    return $items;
};

sub Get {
    my ( $Self, $Params ) = @_;
    return undef() unless defined( $Params );
    my $id = ref( $Params ) && ref( $Params ) eq 'HASH' ? int( $Params->{id} || 0 ) : int( $Params || 0 );
    return undef() unless $id;

    my $try = $Self->_get( $id );
    if ( defined( $try ) ) {
        $Self->{_item} = $try;
        my $r = $Self->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."EAV_submodules_subscriptions" WHERE subscription_id = '.$id );
        delete( $$r{subscription_id} );
        $Self->{_item} = { %{ $Self->{_item} }, %$r };

        return $Self;
    };
    return undef();
};

sub Store {
    my ( $Self, $Params ) = @_;
    return undef() unless defined( $Params );

    my $owner = $Self->_get( $Self->owner_id() );
    return undef() unless defined( $owner );

    #!!NB - по-скольку есть триггер на AFTER UPDATE на submodules_subscriptions - update EAV-данных подписки должен идти раньше чем апдейт главной таблицы.
    $Self->_MultiStore( $Params->{data} );
    #!!?? я сейчас не совсем понимаю зачем я здесь требую совпадения первичного ключа, если subscription_id вполне себе уникальный..
    #м.б. я имел в виду что группы этих параметров могут указывать на один и тот же сабскрипшен ? да, но зачем ?
    $Self->{dbh}->do(
        'UPDATE "public"."EAV_submodules_subscriptions" SET "deny" = '.( $Params->{deny} ? 'true' : 'false' ).' WHERE '.
        '"owner_id" = '.$Self->owner_id().' AND "sla_id" = '.$Self->sla_id().' AND "service_id" = '.$Self->service_id().' AND "subscription_id" = '.$Self->id().' AND "distance" = 0 AND "owner_type" = '.$Self->{dbh}->quote( $owner->{type} ).' '
    );
    # reset Service cache
    $Self->{CacheObject}->CleanUp(
        Type => 'Service',
    );

    return 1;
}

sub ListByServices {
    my ( $Self, $Params ) = @_ ;
    return undef() if !defined( $Params ) || !ref( $Params ) || ref( $Params ) ne 'HASH';
    my $ServiceID = int( $Params->{ServiceID} || 0 );
    my $TreeID = int( $Params->{OwnerID} || 0 );

    my $sql;
    if ( !$ServiceID ) {
        $sql = 'SELECT "service_id", COUNT( "owner_id" ) AS "count" FROM "public"."EAV_submodules_subscriptions" GROUP BY "service_id"';
    } else {
        $sql =
            'SELECT i.*, COUNT(s.owner_id)  FROM "public"."EAV_submodules_subscriptions" AS s '.
            'INNER JOIN "public"."EAV_links" AS l ON l."id" = s."owner_id" '.
            'INNER JOIN "public"."EAV_links" AS lP ON lP."id" = l."parent" AND lP."parent" = '.$TreeID.' AND lP.distance = 0 '.
            'INNER JOIN "public"."EAV_items" AS i ON i."id" = lP."id" '.
            'WHERE s."service_id" = '.$ServiceID.' '.
            'GROUP BY i."id"';
    };

    my $res = [];
    my $sth = $Self->{dbh}->prepare( $sql );
    $sth->execute();
    $res = $sth->fetchall_arrayref({});
    $sth->finish();

    return $res;
};

1;
