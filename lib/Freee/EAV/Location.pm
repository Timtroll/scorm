package Freee::EAV::Location;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

sub GetLocationsByOffice {
    my ( $Self, $Params ) = @_;

    my $OfficeID = defined( $Params ) ? int( ref( $Params ) && ref( $Params ) eq 'HASH' && exists( $Params->{id} ) ? $Params->{id} : $Params ) : $Self->{Roots}->{Office}->id();

    my $sql =
        'SELECT iL.* FROM '.
        '"public"."EAV_links" AS l '.
        'INNER JOIN "public"."EAV_links" AS linksU ON linksU."id" = l."id" AND linksU."parent" = '.$Self->{Roots}->{user}->{_item}->{id}.' '.
        'INNER JOIN "public"."EAV_links" AS linksL ON linksL."id" = linksU."id" AND linksL.distance <= 1 '.
        'INNER JOIN "public"."EAV_submodules_locations" AS iL ON iL."id" = linksL."parent" '.
        'WHERE l."parent" = '.$OfficeID.' '.
        'GROUP BY iL."id" ORDER BY iL.region, iL.city NULLS first, iL.street NULLS FIRST, iL.distance_from_root';

    my $r = $Self->{dbh}->SelectAllHR( $sql ) || [];

    return $r;
}

sub GetLocationsByUser {
    my ( $Self, $Params ) = @_;

    if ( !$Params || ref($Params) ne 'HASH' || !defined( $Params->{EAVID} ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'User ID is missing'
        );
        return undef;
    }

    my $sql = 'SELECT Locations.id FROM "EAV_submodules_locations" AS Locations '
        . 'INNER JOIN "EAV_links" AS Users ON Users."parent" = Locations."id" AND Users."distance" <= 5 '
        . 'WHERE Users.id = ' . $Params->{EAVID}
        . ' ORDER BY Locations.region, Locations.city NULLS first, Locations.street NULLS FIRST, Locations.distance_from_root';
    return $Self->{dbh}->selectall_array($sql);
}

sub _cleanup_prefixes {

}

sub GetTree {
    my ( $Self, $Params ) = @_;

    my $title = $Params->{title};
    $title = '%'.$title.'%' if exists( $Params->{title} ) && defined( $Params->{title} ) && $title !~ /(?:^\%|\%$)/;
    my $AskedNodesSQL = 'SELECT * FROM "public"."EAV_submodules_locations" WHERE '.( defined( $title ) ? ' "title" '.$Self->_MakeFilterStatement( { prefix => '', value => { ILIKE => $title } } ) : ' "id" = '.$Params->{id} );

    my $AskedNodes = {
        map {
            $_->{SearchResultNode} = 1; #чтобы мы могли выделить результаты поиска, если захотим
            $_->{parent} = $_->{street} || $_->{city} || $_->{region}; #чтобы не стучаться в EAV_items и не выяснять кто является 0-родителем этой ноды.
            ( $_->{id}, $_ )
        } @{ $Self->{dbh}->SelectAllHR( $AskedNodesSQL ) }
    };
    return undef() unless scalar( keys %$AskedNodes );

    my $Parents = {};
    my $keys = [ 'region', 'city', 'street' ];
    my $ParentsByKeys = {};
    for my $n ( map { $AskedNodes->{ $_ } } keys %$AskedNodes ) {
        for my $key ( @$keys ) {
            $Parents->{ $$n{ $key } } = 1 if defined( $$n{ $key } ) && !exists( $Parents->{ $$n{ $key } } );
            $ParentsByKeys->{ $key }->{ $$n{ $key } } = 1 if defined( $$n{ $key } );
        };
    };

    my $MixedTreeSQL =
        'SELECT DISTINCT(info."id"), info.* FROM "public"."EAV_submodules_locations" AS info '.
        'INNER JOIN "public"."EAV_links" AS l ON l."id" = info."id" '.
        'WHERE l.parent IN ('.join( ', ', keys %$AskedNodes ).') OR l."id" IN ( '.join( ', ', keys %$Parents ).' ) ';
    my $MixedTree = $Self->{dbh}->SelectAllHR( $MixedTreeSQL );
    my $MixedTreeAsHash = {
        map {
            $_->{parent} = $_->{street} || $_->{city} || $_->{region};
            ( $_->{id}, $_ )
        } @$MixedTree
    };

    $MixedTreeAsHash = { %$MixedTreeAsHash, %$AskedNodes };

    #мы выстраиваем дерево по родительским нодам включающим то что мы нашли, и показываем вглубь всех потомков от них
    my $RESULT = {};
    for my $region ( keys %{ $ParentsByKeys->{region} } ) {
        next unless exists( $MixedTreeAsHash->{ $region } );
        $RESULT->{ $region } = $MixedTreeAsHash->{ $region };
        $RESULT->{ $region }->{childs} = $Self->_GetTree( $MixedTreeAsHash, $region );
        for my $city ( grep { exists( $RESULT->{ $region }->{childs}->{ $_ } ) } keys %{ $ParentsByKeys->{city} } ) {
            $RESULT->{ $region }->{childs}->{ $city }->{childs} = $Self->_GetTree( $MixedTreeAsHash, $city );
            for my $street ( grep { exists( $RESULT->{ $region }->{childs}->{ $city }->{childs}->{ $_ } ) } keys %{ $ParentsByKeys->{street} } ) {
                $RESULT->{ $region }->{childs}->{ $city }->{childs}->{$street}->{childs} = $Self->_GetTree( $MixedTreeAsHash, $street );
            };
        };
    };
    return $RESULT;
};

sub _GetTree {
    my ( $Self, $Tree, $id ) = @_;

    my $RESULT = {};

    for my $item ( keys %$Tree ) {
        my $Item = $Tree->{ $item };
        next if !defined( $Item->{parent} ) || $Item->{parent} != $id;

        $RESULT->{ $Item->{id} } = $Item;
        $RESULT->{ $Item->{id} }->{childs} = $Self->_GetTree( $Tree, $Item->{id} );
    };
    return undef() unless scalar( keys %$RESULT );

    return $RESULT;
};

sub GetTitle {
    my $Self = shift;
    return undef() unless exists( $Self->{_item} );
    $Self->{_submodules_locations_cache} = $Self->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."EAV_submodules_locations" WHERE "id" = '.$Self->{_item}->{id} ) if !exists( $Self->{_submodules_locations_cache} );
    return $Self->{_submodules_locations_cache}->{clean_address} if defined( $Self->{_submodules_locations_cache} );

    return $Self->{_item}->{title};
};

=encoding utf8

=head2 SearchLocations()
Позволяет производить поиск по дереву адресов с выводом результатов "лесенкой":
Москва
Москва, Гончарная ул
Москва, Гончарная ул, 30

Метод не чувствителен к регистру и автоматически заменяет все , (запятые) на %, - таким образом можно искать:
Гончарная, 30 и получать результат "Москва, Гончарная ул, 30"

Автоматическая подстановка начальных и конечных %% не производится - если предполагается полнотекстовый поиск
их нужно передавать в запросе: Term => '%гончарная%'

=item Входные параметры:
$Self->SearchLocations( $Params<HashRef> )
$Params:
Term     - строка поиска (обязательный)
OfficeID - ID ГУ или регионального филиала, ограничивающий выбор адресов (необязательный)
Limit    - максимальное количество результатов (необязательный, по умолчанию 50)
Start    - начать поиск с элемента № (необязательный, по умолчанию 0)

=item Возвращает:
Ссылку на массив с результатами поиска

return $Ret = {
    city                         => 1183163,
    clean_address                => "Москва г, Москва, Гончарная ул",
    count_office                 => 345,
    count_users                  => 8241,
    count_users_direct           => 0,
    count_users_published        => null,
    count_users_published_direct => null,
    distance_from_root           => 2,
    id                           => 1183192,
    prefixed_address             => "ATRegion|Москва|ATCity|Москва|ATStreet|Гончарная ул",
    region                       => 1163800,
    street                       => null,
    title                        => "Гончарная ул",
}

=cut

sub SearchLocations {
    my ( $Self, $Params ) = @_ ;

    my $Term;
    my $OfficeID;
    my @Bind;
    my $OrderBy = 'ORDER BY clean_address';

    if ( defined( $Params->{Term} ) ) {
        $Term = lc( $Self->{dbh}->Quote($Params->{Term}) );
    }
    else {
        return undef;
    }

    $Term =~ s/\,/%,/g;

    my $SQL = 'SELECT * FROM  "public"."EAV_submodules_locations" WHERE lower("clean_address") LIKE ?';

    if ( defined( $Params->{OfficeID} ) ) {
        $OfficeID = $Params->{OfficeID} ;
        $SQL =
            'SELECT Locations.* FROM '.
            '"EAV_submodules_locations" AS Locations '.
            'INNER JOIN "EAV_links" AS Users ON Users."parent" = Locations."id" '.
            'INNER JOIN "EAV_links" AS Offices ON Offices."id" = Users."id" AND Offices."parent" = ? '.
            'WHERE lower(Locations."clean_address") LIKE ? AND ( Locations.count_users > 0 OR Locations.count_office > 0 ) '.
            'GROUP BY Locations."id"';
        push @Bind, \$OfficeID;
    }

    $SQL .= ' '.$OrderBy;

    push @Bind, \$Term;
    my $Ret = $Self->{dbh}->SelectAllArrayref(
        SQL      => $SQL,
        Bind     => \@Bind,
        Slice    => {},
        Limit   => $Params->{Limit} || 200,
        Start    => $Params->{Start} || 0
    );

    return $Ret;
}

1;
