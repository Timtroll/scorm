package Kernel::Modules::EAV::Base;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log',

);
use feature 'state';

sub new {
    state $Self;
    my $Class = shift;

    if ( !defined( $Self ) ) {
        $Self = bless {}, $Class;
        $Self->_init();
    };

    return $Self;
}

sub _init {
    my $Self = shift;

    $Self->{DBObject} = $Kernel::OM->Get('Kernel::System::DB');
    $Self->{DBObject}->Connect() unless $Self->{DBObject}->{dbh};
    $Self->{dbh} = $Self->{DBObject}->{dbh};

    my $sth = $Self->{dbh}->prepare( 'SELECT * FROM "public"."EAV_fields"' );
    $sth->execute();
    my $fields = $sth->fetchall_arrayref({});
    $sth->finish();

    $Self->{FieldsAsArray} = $fields;
    $Self->{Fields} = {};
    foreach my $field ( @$fields ) {
        $Self->{Fields}->{ $field->{set} }->{ $field->{alias} } = $field;
        $Self->{FeildsById}->{ $$field{id} } = $field;
    };

    $Self->{DataTables} = {
        int => '"public"."EAV_data_int4"',
        string => '"public"."EAV_data_string"',
        boolean => '"public"."EAV_data_boolean"',
        datetime => '"public"."EAV_data_datetime"'
    };
}

sub _get {
    my $Self = shift;
    my $id = int( $_[0] || 0 );

    my $item = $Self->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."EAV_items" WHERE "id" = '.$id );
    #!!FIXIT
    $$item{type} = $$item{import_type};
    delete( $$item{import_type} );
    #!!FIXIT
    my $sth = $Self->{dbh}->prepare( 'SELECT "parent", "distance" FROM "public"."EAV_links" WHERE "id" = '.$id );
    $sth->execute();
    $item->{parents} = $sth->fetchall_arrayref({});
    $sth->finish();

    return $item
}                                                                                                

sub _getAll {
    my $Self = shift;
    return undef() unless exists( $Self->{_item} );

    $Self->{_item}->{Childs} = $Self->_get_childs( { Split => 1 } );
    
    my $types = { map { ( $Self->{Fields}->{ $Self->{_item}->{type} }->{ $_ }->{type}, 1 ) } keys %{ $Self->{Fields}->{ $Self->{_item}->{type} } } };

    foreach my $tbl ( map { $Self->{DataTables}->{ $_ } } grep { exists( $types->{ $_ } ) } keys %{ $Self->{DataTables} } ) {
        my $sth = $Self->{dbh}->prepare( 'SELECT "field_id", "data" FROM '.$tbl.' WHERE "id" = '.int( $Self->{_item}->{id} ) );
        $sth->execute();
        my $rows = $sth->fetchall_arrayref({});
        $sth->finish();

        foreach my $r ( @$rows ) {
            my $alias = $Self->{FeildsById}->{ $$r{field_id} };
            $Self->{_item}->{ $alias } = $r->{data};
        };
    };

    return $Self->{_item};
};

sub _get_field {
    my $Self = shift;
    my $field = shift;

    return undef() unless exists( $Self->{_item} );
    return undef() unless exists( $Self->{Fields}->{ $Self->{_item}->{type} }->{ $field } );

    my $val = $Self->{Fields}->{ $Self->{_item}->{type} }->{ $field };
    my $result = $Self->{dbh}->selectrow_array( 'SELECT "data" FROM '.$Self->{DataTables}->{ $$val{type} }.' WHERE "id" = '.$Self->{_item}->{id}.' AND "field_id" = '.$$val{id} );

    return $result;
}

sub _get_childs {
    my $Self = shift;
    return undef() unless exists( $Self->{_item} );

    my $id = int( $Self->{_item}->{id} );

    my $Params = $_[0];

    my $sth = $Self->{dbh}->prepare( 'SELECT "id", "distance" FROM "publish"."EAV_links" WHERE "parent" = '.$id.( exists( $Params->{Direct} ) ? ' AND "distance" = 0' : '' ) );
    $sth->execute();
    my $Childs = $sth->fetchall_arrayref({});
    $sth->finish();

    return [ map { $_->{id} } @{ $Childs } ] if !exists( $Params->{Split} ) || !$Params->{Split};

    return {
        Direct => [ map { $_->{id} } grep { !$_->{distance} } @{ $Childs } ],
        All => $Childs
    };
};

sub _store {
    my $Self = shift;
    my ( $field, $data ) = @_;

    return undef() unless exists( $Self->{_item} );
    return undef() unless exists( $Self->{Fields}->{ $Self->{_item}->{type} }->{ $field } );
    my $val = $Self->{Fields}->{ $Self->{_item}->{type} }->{ $field };
    if ( $$val{type} eq 'boolean' ) {
        my $value = 'true';
        $value = 'NULL' if !defined( $data );
        $value = 'false' if !$data || $data eq 'f' || $data eq 'false';
        $data = $value;
    } else {
        $data = $Self->{dbh}->quote( $data );
    };

    my $result = $Self->{dbh}->do( 
        'INSERT INTO '.$Self->{DataTables}->{ $$val{type} }.'  ( "id", "field_id", "data" ) VALUES ( '.int( $Self->{_item}->{id} ).', '.int( $$val{id} ).', '.$data.') '.
        'ON CONFLICT '.
        'ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "data" = '.$data 
    );

    return $result;
}

sub _create {
    my $Self = shift;
    my $Item = $_[0];
    die unless exists( $$Item{type} ) && exists( $Self->{Fields}->{ $$Item{type} } );
    die unless exists( $$Item{parent} ) && $$Item{parent} =~ /^\d+$/;

    my $data = { 'publish' => 'false', 'import_type' => $Self->{dbh}->quote( $$Item{type} ) };
    $$data{publish} = 'true' if exists( $$Item{publish} ) && $$Item{publish} && $$Item{publish} !~ /^(?:false|0)$/i;
    $$data{import_id} = $Self->{dbh}->quote( $$Item{import_id} ) if exists( $$Item{import_id} ) && defined( $$Item{import_id} );
    $$data{title} = $Self->{dbh}->quote( $$Item{title} );

    $Self->{dbh}->do( 'INSERT INTO "public"."EAV_items" ('.join( ',', map { '"'.$_.'"'} keys %$data ).') VALUES ('.join( ',', map { $$data{$_} } keys %$data ).') RETURNING "id"' );
    my $id = $$data{id} = $Self->{dbh}->last_insert_id();

    foreach my $val ( grep { defined( $_->{default_value} ) } @{ $Self->{FieldsAsArray} } ) {
        $Self->{dbh}->do( 'INSERT INTO '.$Self->{DataTables}->{ $$val{type} }.' ( "id", "field_id", "data" ) VALUES ('.$id.', '.$$val{fieldid}.', '.$Self->{dbh}->quote( $$val{default_value} ).' )'  );
        $data->{ $$Item{type} }->{ $$val{alias} } = $$val{default_value};
    };

    $Self->{dbh}->do( 'INSERT INTO "public"."EAV_links" ("parent", "id", "distance") VALUES ('.$$Item{parent}.', '.$id.', 0)' );
    $data->{parents} = [ {distance => 0, parent => $$Item{parent} }, map { $_->{distance} += 1; $_ } sort { $a->{distance} <=> $b->{distance} } @{ $Self->_get( $$Item{parent} )->{parents} } ];

    return $data;
};

sub _delete {
    my $Self = shift;
    return undef() unless exists( $Self->{_item} );
    return $Self->{dbh}->do( 'UPDATE "public"."EAV_items" SET "publish" = false WHERE "id" = '.int( $Self->{_item}->{id} ) );
};

sub _MoveChilds {
    my $Self = shift;
    my $Params = $_[0];
    return undef() unless exists( $Params->{NewParent} );
    my $id = int( $Self->{_item}->{id} );

    my $Childs = $Self->_get_childs();

    #move childs to parent of this node inside it's graph.
    my $sth = $Self->{dbh}->prepare( 'SELECT "parent", "distance" FROM "publish"."EAV_links" WHERE "id" = '.$id );
    my $parents = $sth->fetchall_arrayref({});
    $sth->finish();
    foreach my $parent ( @$parents ) {
        $Self->{dbh}->do( 'DELETE FROM "publish"."EAV_links" WHERE "parent" = '.$parent->{parent}.' AND "id" IN ('.join( ', ', @$Childs ).')' );
    };

    foreach my $child ( @$Childs ) {
        $Self->{dbh}->do( 
            'INSERT INTO "publish"."EAV_links" ( "id", "parent", "distance" ) VALUES ( '.$child.', '.int( $Params->{NewParent} ).', 0 ) '.
            'ON CONFLICT ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "distance" = 0' 
        );
    };

    return 1;
};

sub _RealDelete {
    my $Self = shift;
    return undef() unless exists( $Self->{_item} );

    my $id = int( $Self->{_item}->{id} );
    return undef() if !$id;#use truncates..

    my $Params = $_[0];

    my $items = [ $id ];

    my $Childs = $Self->_get_childs();

    if ( !exists( $Params->{SaveChilds} ) || !$Params->{SaveChilds} ) {
        push @$items, @$Childs;
    } else {
        my $dParent = $Self->{dbh}->selectrow_array( 'SELECT "parent" FROM "publish"."EAV_links" WHERE "id" = '.$id.' AND distance = 0' );
        $Self->_MoveChilds( $dParent );
    };
    $Self->{dbh}->do( 'DELETE FROM "publish"."EAV_links" WHERE "id" IN ('.join( ',', @$items ).') ' );
    $Self->{dbh}->do( 'DELETE FROM "publish"."EAV_links" WHERE "parent" IN ('.join( ',', @$items ).') ' );
    $Self->{dbh}->do( 'DELETE FROM "publish"."EAV_items" WHERE "id" IN ('.join( ',', @$items ).')' );
    foreach my $tbl ( map { $Self->{DataTables}->{ $_ } } keys %{ $Self->{DataTables} } ) {
        $Self->{dbh}->do( 'DELETE FROM '.$tbl.' WHERE "id" IN ('.join( ',', @$items ).')' );
    };

    delete( $Self->{_item} );

    return 1;
}

sub _MakeFilterStatement {
    my ( $Self, $Params ) = @_ ;

    my $v = $Params->{value};
    my $prefix = $Params->{prefix};

    my $res = '';
    if ( !defined( $v ) ) {
        $res .= ' AND '.$prefix.' IS NULL ';
    } elsif ( !ref( $v ) ) {
        $res .= ' AND '.$prefix.' = '.$Self->{dbh}->quote( $v )
    } elsif ( ref( $v ) eq 'SCALAR' && $v == \0 || $v == \1 ) {
        $res .= ' AND '.$prefix.' = '.( $v == \0 ? 'false' : 'true' )
    } elsif ( ref( $v ) eq 'ARRAY' && scalar( @$v ) ) {
        if ( scalar( @$v ) <= 10 ) {
            $res .= ' AND ( '.join( ' OR ', map { $prefix.' = '.$Self->{dbh}->quote( $_ ) } @$v ).' )';
        } elsif ( scalar( @$v ) <= 1000 ) {
            $res .= ' AND '.$prefix.' IN ( '.join( ', ', map { $Self->{dbh}->quote( $_ ) } @$v ).' )';
        } else {
            $res .= ' AND '.$prefix.' = ANY ( VALUES( '.join( ', ', map { $Self->{dbh}->quote( $_ ) } @$v ).' )';
        }
    } elsif ( ref( $v ) eq 'HASH' ) {
        $res .= ' AND '.$prefix.' > '.$Self->{dbh}->quote( $v->{gt} ) if exists( $v->{gt} ) && defined( $v->{gt} );
        $res .= ' AND '.$prefix.' >= '.$Self->{dbh}->quote( $v->{gt} ) if exists( $v->{gt_or_eq} ) && defined( $v->{gt_or_eq} );
        $res .= ' AND '.$prefix.' < '.$Self->{dbh}->quote( $v->{gt} ) if exists( $v->{lt} ) && defined( $v->{lt} );
        $res .= ' AND '.$prefix.' <= '.$Self->{dbh}->quote( $v->{gt} ) if exists( $v->{lt_or_eq} ) && defined( $v->{lt_or_eq} );
    }
};

sub _list {
    my ( $Self, $Params ) = @_ ;

    my $sql = 'SELECT i.*';
    my $data_sql = '';
    #fields
    if ( exists( $Params->{Fields} ) && ref( $Params->{Fields} ) eq 'ARRAY' ) {
        my $i = 0;
        foreach my $f ( @{ $Params->{Fields} } ) {
            my ( $set, $field ) = ( split /\./, $f );
            next if !defined( $set ) || !defined( $field ) || !exists( $Self->{Fields}->{ $set }->{ $field } );
            my $Field = $Self->{Fields}->{ $set }->{ $field };
            $sql .= ', OutData'.$i.'."data" AS "'.$f.'"';
            my $tbl = $Self->{DataTables}->{ $Field->{type} };
            $data_sql .= ' INNER JOIN '.$tbl.' AS OutData'.$i.' ON i."id" = OutData'.$i.'."id" AND OutData'.$i.'."field_id" = '.$Field->{id};
            if ( exists( $Params->{Filter}->{$f} ) ) {
                $data_sql .= $Self->_MakeFilterStatement( { value => $Params->{Filter}->{$f}, prefix => 'OutData'.$i.'."data"' } );
            };
            $i++;
        }
    };
    $sql.= ' FROM "public"."EAV_items" AS i ';
    my $i = 0;
    foreach my $p ( @{ $Params->{Parents} } ) {
        $sql .= ' INNER JOIN "public"."EAV_links" AS links'.$i.' ON links'.$i.'."id" = i."id" AND links'.$i.'."parent" = '.int( $p );
    };
    $sql .= $data_sql;

    my $filter_sql = '';
    if ( exists( $Params->{Filter} ) && ref( $Params->{Filter} ) eq 'HASH' ) {
        my $i = 0;
        foreach my $f ( keys %{ $Params->{Filter} } ) {
            #already joined and filtered in $data_sql
            next if exists( $Params->{Fields} ) && ref( $Params->{Fields} ) eq 'ARRAY' && scalar( grep { $_ eq $f } @{ $Params->{Fields} } );

            my ( $set, $field ) = ( split /\./, $f );
            next if !defined( $set ) || !defined( $field ) || !exists( $Self->{Fields}->{ $set }->{ $field } );
            my $Field = $Self->{Fields}->{ $set }->{ $field };

            my $tbl = $Self->{DataTables}->{ $Field->{type} };
            $filter_sql .= ' INNER JOIN '.$tbl.' AS FilterData'.$i.' ON i."id" = FilterData'.$i.'."id" AND FilterData'.$i.'."field_id" = '.$Field->{id};
            $filter_sql .= $Self->_MakeFilterStatement( { value => $Params->{Filter}->{$f}, prefix => 'FilterData'.$i.'."data"' } );
        };
    };

    $sql .= ' WHERE 1 = 1 ';
    #default - show only published items, if we want to look over all - should add ShowHidden => 1, if we want to look hidden only - should add ShowHiddenOnly
    if ( !scalar( grep { $_ eq 'ShowHidden' && defined( $Params->{$_} ) && $Params->{$_} } keys %$Params ) ) {
        $sql .= ' AND i.publish = true ';
    } elsif ( exists( $Params->{ShowHiddenOnly} ) && $Params->{ShowHiddenOnly} ) {
        $sql .= ' AND i.publish = false ';
    };#else - ShowHidden exists and it's true - so we are not use "publish" filter.

    return $sql if exists( $Params->{SQLResult} ) && defined( $Params->{SQLResult} ) && $Params->{SQLResult};
}

1;