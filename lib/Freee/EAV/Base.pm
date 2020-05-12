package Freee::EAV::Base;

# Базовый класс EAV
use strict;
use warnings;
use feature 'state';

our @EXPORT_OK = qw( AUTOLOAD );
our $AUTOLOAD;

use Data::Dumper;

sub new {
    state $self;
    my $Class = shift;

    if ( !defined( $self ) ) {
        $self = bless {}, __PACKAGE__;
        $self->{dbh} = $_[0]->{dbh};
        $self->_init();
        return $self if ( !defined( $Class ) );
    }

warn Dumper $_[0]->{Type};
    my $Other = bless { Type => $_[0]->{Type} }, $Class;
    $self->_init_copy( $Other, $_[0] );

    return $Other if exists( $_[0]->{PreventCreate} ) && $_[0]->{PreventCreate};
    return defined( $Other->_InitThisItem( $_[0] ) ) ? $Other : undef();
}

sub AUTOLOAD {
    my $self = shift;
    my $method = substr( $AUTOLOAD, rindex( $AUTOLOAD, '::' ) + 2 );

    return 1 if $method eq 'DESTROY';

# warn Dumper $self->{Type};
    if (
        exists( $self->{Fields}->{ $self->{Type} }->{ $method } ) || exists( $self->{ItemFields}->{ $method } ) ||
        ( exists( $self->{_item} ) && exists( $self->{_item}->{ $method } ) ) ||
        exists( $self->{Fields}->{ 'Default' }->{ $method } )
    ) {
        if ( scalar( @_ ) ) {
            return $self->_store( $method, @_ );
        }
        elsif ( exists( $self->{_item} ) ) {
            return $self->{_item}->{ $method } if exists( $self->{_item}->{ $method } );
            return $self->_get_field( $method );
        }
        else {
            return undef();
        }
    } else {
#        return $self->$method( @_ );
    }
}

sub _init {
    my $self = shift;

    my $sth = $self->{dbh}->prepare( 'SELECT * FROM "public"."EAV_fields"' );
    $sth->execute();
    my $fields = $sth->fetchall_arrayref({});
    $sth->finish();

    $self->{FieldsAsArray} = $fields;
    $self->{Fields} = {};
    for my $field ( @$fields ) {
        $self->{Fields}->{ $field->{set} }->{ $field->{alias} } = $field;
        $self->{FieldsById}->{ $$field{id} } = $field;
    }

    $self->{ItemFields} = { map { ( $_, 1 ) } ( 'id', 'publish', 'import_id', 'type', 'import_type', 'title', 'date_created', 'date_updated', 'parent', 'has_childs' ) } ;

    $self->{DataTables} = {
        int      => [ '"public"."EAV_data_int4"', '"EAV_data_int4_pkey"' ],
        string   => [ '"public"."EAV_data_string"', '"EAV_data_string_pkey"' ],
        boolean  => [ '"public"."EAV_data_boolean"', '"EAV_data_boolean_pkey"' ],
        datetime => [ '"public"."EAV_data_datetime"', '"EAV_data_datetime_pkey"' ]
    };

    my $sql = 'SELECT i.* FROM "public"."EAV_links" AS l INNER JOIN "public"."EAV_items" AS i ON i."id" = l."id" WHERE l."parent" = 0 AND l."distance" = 0';
    $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();
    $self->{_roots} = $sth->fetchall_arrayref({});
    $self->{Roots} = {};

    my $Base = __PACKAGE__;
    $Base =~ s/::Base//;
    # my %Loaded;

    for my $Type ( keys %{ $self->{Fields} } ) {
        my $T = ucfirst($Type);
        my $Class = $Base . '::' . $T;

warn Dumper $Type;
warn Dumper $self->{_roots};
        my ( $id ) = ( map { $_->{id} } grep { $_->{import_type} eq $Type } @{ $self->{_roots} } );
warn $Class.'////'.$id;
        if ( !defined( $id ) ) {
            if ( $Type eq 'Default' ) {
                 $self->{Roots}->{ $Type } =  undef();
            }
            else {
                 my $obj;
                 eval '
                    use ' . $Class . ';
                    $obj = ' . $Class . '->new( { Type => $Type, parent => 0, publish => \1, import_id => undef(), title => $T, dbh => $self->{dbh}  } );
                ';
warn $obj;
                 $self->{Roots}->{ $Type } = $obj;
            }
        }
        else {
            my $obj;
            eval '
                use ' . $Class . '; 
                $obj = ' . $Class . '->new( { Type => $Type, dbh => $self->{dbh} } );
            ';
warn $obj;
            $obj->{_item} = $obj->_get( $id );
            $self->{Roots}->{ $Type } = $obj;
        }
    }
    $self->{Root} = $self->{Roots}->{ $self->{Type} } if exists( $self->{Type} );
    $sth->finish();
}

sub _init_copy {
    my ( $self, $Target, $Params ) = @_;

    my $fields = [
        'dbh',        'DBObject', 'FieldsAsArray',  'Fields',   'FieldsById', 'ItemFields',
        'DataTables', 'Roots',    'CacheType',      'CacheTTL', 'LogObject',  'Debug'
    ];

    $Target->{$_} = $self->{$_} foreach (@$fields);

    $Target->{Root} = $self->{Roots}->{ $Target->{Type} };
}

sub _InitThisItem {
    my ( $self, $Params ) = @_;

    if ( exists( $$Params{id} ) ) {
        $self->{_item} = $self->_get( $$Params{id} );
        return undef unless defined( $self->{_item} );
    }
    elsif ( exists( $$Params{import_id} ) && !exists( $$Params{parent} ) ) {
        $self->{_item} = $self->_get( $$Params{import_id}, $$Params{Type} );
        return undef unless defined( $self->{_item} );
    }
    elsif ( exists( $$Params{parent} ) && exists( $$Params{Type} ) ) {
        $self->{_item} = $self->_create( $Params );
        my $Type = '\'' . $$Params{Type} . '\'';
        if ( exists( $Params->{data} ) && defined( $Params->{data} ) && ref( $Params->{data} ) && ref( $Params->{data} ) eq 'HASH' ) {
            $self->_MultiStore( $Params->{data} );
        }
        elsif ( exists( $Params->{$Type} ) && defined( $Params->{$Type} ) && ref( $Params->{$Type} ) && ref( $Params->{$Type} ) eq 'HASH' ) {
            $self->_MultiStore( { $$Params{Type} => $Params->{$Type} } );
        }
    }

    return 1;
}

sub _get {
    my $self = $_[0];
    my $id = int( $_[1] || 0 );
    my $import_id_flag_and_type = exists( $_[2] ) && $_[2] ? $_[2] : 0;

    my $sql = $import_id_flag_and_type ? 'SELECT * FROM "public"."EAV_items" WHERE "import_id" = ' . $id . ' AND "import_type" = ' . $self->{dbh}->quote( $import_id_flag_and_type ) : 'SELECT * FROM "public"."EAV_items" WHERE "id" = ' . $id;
    my $item = $self->{dbh}->selectrow_hashref( $sql );
    return undef() unless defined( $item );

    #!!FIXIT
    $$item{Type} = $$item{type} = $$item{import_type};
    delete( $$item{import_type} );

    #!!FIXIT
    $sql = 'SELECT "parent", "distance" FROM "public"."EAV_links" WHERE "id" = ' . $id;
    my $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();
    $item->{parents} = $sth->fetchall_arrayref({});
    $sth->finish();

    return $item
}

sub GetTitle {
    my $self = shift;
    return undef() unless exists( $self->{_item} );

    return $self->{_item}->{title};
}

sub _getAll {
    my $self = shift;

    return undef() unless exists( $self->{_item} );

    $self->{_item}->{Childs} = $self->_get_childs( { Split => 1 } );
    my $types = { map { ( $self->{Fields}->{ $self->{Type} }->{ $_ }->{type}, 1 ) } keys %{ $self->{Fields}->{ $self->{Type} } } };

    for my $tbl ( map { $self->{DataTables}->{ $_ }->[0] } grep { exists( $types->{ $_ } ) } keys %{ $self->{DataTables} } ) {
        my $sql = 'SELECT "field_id", "data" FROM ' . $tbl . ' WHERE "id" = ' . int( $self->{_item}->{id} );
        my $sth = $self->{dbh}->prepare( $sql );
        $sth->execute();
        my $rows = $sth->fetchall_arrayref({});
        $sth->finish();

        for my $r ( @$rows ) {
            my $alias = $self->{FieldsById}->{ $$r{field_id} };
            $self->{_item}->{ $alias } = $r->{data};
        }
    }

    return $self->{_item};
}

sub _get_field {
    my ( $self, $FieldName ) = @_ ;

    return undef() unless exists( $self->{_item} );
    my $t = $self->{Type};
    $t = 'Default' if exists( $self->{Fields}->{ 'Default' }->{ $FieldName } );
    return undef() unless exists( $self->{Fields}->{ $t }->{ $FieldName } );

    my $Field = $self->{Fields}->{ $t }->{ $FieldName };
warn $self;
    my $sql = 'SELECT "data" FROM ' . $self->{DataTables}->{ $$Field{type} }->[0] . ' WHERE "id" = ' . $self->{_item}->{id} . ' AND "field_id" = ' . $$Field{id};
    my $result = $self->{dbh}->selectrow_array( $sql );

    return $result;
}

sub _get_childs {
    my $self = shift;

    return undef() unless exists( $self->{_item} );

    my $id = int( $self->{_item}->{id} );
    my $Params = $_[0];

    my $sql = 'SELECT "id", "distance" FROM "public"."EAV_links" WHERE "parent" = ' . $id . ( exists( $Params->{Direct} ) ? ' AND "distance" = 0' : '' );
    my $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();
    my $Childs = $sth->fetchall_arrayref({});
    $sth->finish();

    return [ map { $_->{id} } @{ $Childs } ] if !exists( $Params->{Split} ) || !$Params->{Split};

    return {
        Direct => [ map { $_->{id} } grep { !$_->{distance} } @{ $Childs } ],
        All => $Childs
    };
}

sub _boolean_by_input {
    my ( $self, $data ) = @_;

    return 'NULL' if !defined( $data );

    my $value = 'true';
    $value = 'false' if !$data || $data eq 'f' || $data eq 'false' || ( ref( $data ) && ref( $data ) eq 'SCALAR' && $$data == 0 );

    return $value;
}

sub _boolean_by_db {
}

sub _store {
    my ( $self, $FieldName, $data ) = @_;

    my $origin_data = $data;
    my $type = $self->{Type};
    $type = 'Default' if exists( $self->{Fields}->{ 'Default' }->{ $FieldName } );

    my $sysprefix = exists( $self->{ItemFields}->{ $FieldName } ) ? 1 : 0;

    return undef() unless exists( $self->{_item} );
    return undef() if !exists( $self->{Fields}->{ $type }->{ $FieldName } ) && !$sysprefix;
    return undef() if $sysprefix && $FieldName eq 'id';

    my $val = $sysprefix ? { type => 'string' } : $self->{Fields}->{ $type }->{ $FieldName };
    $val->{type} = 'boolean' if $sysprefix && $FieldName eq 'publish';

    if ( $$val{type} eq 'boolean' ) {
        $data = $self->_boolean_by_input( $data );
    }
    elsif ( ( $$val{type} eq 'datetime' || $$val{type} eq 'int' ) && !$data) {
        $data = 'NULL';
    }
    elsif ( $$val{type} eq 'int' ) {
         $data = $self->{dbh}->quote( int( $data ) );
    }
    else {
        $data = $self->{dbh}->quote( $data );
    }

    my ($x, $sql);
    if ( $sysprefix ) {
        $sql = 'UPDATE "public"."EAV_items" SET '.$FieldName.' = '.$data.' WHERE "id" = '.$self->{_item}->{id};
    }
    else {
        $sql = 'INSERT INTO ' . $self->{DataTables}->{ $$val{type} }->[0] .
            '  ( "id", "field_id", "data" ) VALUES ( ' . int( $self->{_item}->{id} ) . ', ' . int( $$val{id} ) . ', ' . $data . ') ' .
            'ON CONFLICT ' .
            'ON CONSTRAINT ' . $self->{DataTables}->{ $$val{type} }->[1] . ' DO UPDATE SET "data" = ' . $data;
    }
    $x = $self->{dbh}->do( $sql );

    if ( $x ) {
        if ( $sysprefix ) {
            $self->{_item}->{ $FieldName } = $origin_data;
            if ( $FieldName eq 'publish' ) {
                $self->{_item}->{publish} = $data eq 'true' ? 1 : 0;
            }
        }
        else {
            $self->{_item}->{ $self->{Type} }->{ $FieldName } = $origin_data;
            if ( $$val{type} eq 'boolean' ) {
                $self->{_item}->{ $self->{Type} }->{ $FieldName } = $data eq 'true' ? 1 : 0;
            }
        }
    }

    return $x;
}

sub RefreshView{
    # Метод должен быть переопределен
    # в соответствующем классе
    return 1;
}

sub _create {
    my ( $self, $Item ) = @_;

    $Item->{Type} = $self->{Type} unless exists( $Item->{Type} );
    die unless exists( $$Item{Type} ) && exists( $self->{Fields}->{ $$Item{Type} } );
    die unless exists( $$Item{parent} ) && $$Item{parent} =~ /^\d+$/;

    my $data = {
        'publish'     => 'false',
        'import_type' => $self->{dbh}->quote( $$Item{Type} )
    };
    $$data{publish}       = 'true' if exists( $$Item{publish} ) && $$Item{publish} && $$Item{publish} !~ /^(?:false|0)$/i;
    $$data{import_id}     = $self->{dbh}->quote( $$Item{import_id} ) if exists( $$Item{import_id} ) && defined( $$Item{import_id} );
    $$data{title}         = $self->{dbh}->quote( $$Item{title} );
    $$data{import_source} = $self->{dbh}->quote( $$Item{import_source} ) if exists( $$Item{import_source} ) && defined( $$Item{import_source} );

    my $sql = 'INSERT INTO "public"."EAV_items" ('.join( ',', map { '"'.$_.'"'} keys %$data ).') VALUES ('.join( ',', map { $$data{$_} } keys %$data ).') RETURNING "id"';
    $self->{dbh}->do( $sql );

    my $id = $$data{id} = $self->{dbh}->last_insert_id( undef, 'public', 'EAV_items', undef, { sequence => 'eav_items_id_seq' } );

    for my $val ( grep { defined( $_->{default_value} ) } @{ $self->{FieldsAsArray} } ) {
        next if $$val{type} ne $$Item{Type} && $$val{type} ne 'Default';

        $sql = 'INSERT INTO ' . $self->{DataTables}->{ $$val{type} }->[0] .
            ' ( "id", "field_id", "data" ) VALUES (' . $id . ', ' . $$val{id} . ', ' . $self->{dbh}->quote( $$val{default_value} ) . ' )';
        $self->{dbh}->do( $sql );

        $data->{ $$Item{Type} }->{ $$val{alias} } = $$val{default_value};
    }

    $sql = 'INSERT INTO "public"."EAV_links" ("parent", "id", "distance") VALUES (' . $$Item{parent} . ', ' . $id . ', 0)';
    $self->{dbh}->do( $sql );

    my $p = $self->_get( $$Item{parent} );
    my $parents = defined( $p ) ? $p->{parents} : [];
    $data->{parents} = [
        {
            distance => 0,
            parent   => $$Item{parent}
        },
        map { $_->{distance} += 1; $_ } sort { $a->{distance} <=> $b->{distance} } @$parents
    ];

    return $data;
}

sub _MultiStore {
    my ( $self, $Params ) = @_;

    for my $key ( keys %$Params ) {
        next if !defined( $Params->{ $key } ) || !ref( $Params->{ $key } ) || ref( $Params->{ $key } ) ne 'HASH';

        for my $field ( keys %{ $Params->{ $key } } ) {
            if ( exists( $self->{ItemFields}->{ $field } ) ) {
                $self->_store( $field, $Params->{ $key }->{ $field } );
                next;
            }
            next if !exists( $self->{Fields}->{ $key }->{ $field } );
            $self->_store( $field, $Params->{ $key }->{ $field } );
        }
    }

    return 1;
}

sub _delete {
    my $self = shift;

    return undef() unless exists( $self->{_item} );
    return $self->{dbh}->do( 'UPDATE "public"."EAV_items" SET "publish" = false WHERE "id" = ' . int( $self->{_item}->{id} ) );
}

sub _MoveChilds {
    my ( $self, $Params ) = @_ ;

    return undef() unless exists( $Params->{NewParent} );
    my $id = int( $self->{_item}->{id} );

    my $Childs = $self->_get_childs();

    #move childs to parent of this node inside it's graph.
    my $sth = $self->{dbh}->prepare( 'SELECT "parent", "distance" FROM "public"."EAV_links" WHERE "id" = ' . $id );
    $sth->execute();
    my $parents = $sth->fetchall_arrayref({});
    $sth->finish();

    for my $parent ( @$parents ) {
        my $sql = 'DELETE FROM "public"."EAV_links" WHERE "parent" = '.$parent->{parent}.' AND "id" IN ('.join( ', ', @$Childs ).')';
        $self->{dbh}->do( $sql );
    }

    for my $child ( @$Childs ) {
        my $sql = 'INSERT INTO "public"."EAV_links" ( "id", "parent", "distance" ) VALUES ( ' . $child . ', ' . int( $Params->{NewParent} ) . ', 0 ) ' . 'ON CONFLICT ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "distance" = 0';
        $self->{dbh}->do( $sql );
    }

    return 1;
}

sub _AttachToParent {
    my ( $self, $Params ) = @_ ;

    return undef() unless $self->{_item};
    return undef() unless defined( $Params );
    my $parent = ref( $Params ) && ref( $Params ) eq 'HASH' && exists( $Params->{parent} ) ? int( $Params->{parent} || 0 ) : int( $Params || 0 );
    return undef() unless $parent;

    my $sql = 'INSERT INTO "public"."EAV_links" ("id", "parent", "distance") VALUES ( '.int( $self->{_item}->{id} ).', '.$parent.', 0 ) ON CONFLICT ON CONSTRAINT "EAV_links_pkey" DO NOTHING';
    $self->{dbh}->do( $sql );

    return 1;
}

sub _RealDelete {
    my $self = shift;

    return undef() unless exists( $self->{_item} );

    my $id = int( $self->{_item}->{id} );
    return undef() if !$id; #use truncates..

    my $Params = $_[0];

    my $items = [ $id ];

    my $Childs = $self->_get_childs();

    if ( !exists( $Params->{SaveChilds} ) || !$Params->{SaveChilds} ) {
        push @$items, @$Childs;
    }
    else {
        my $dParent = $self->{dbh}->selectrow_array( 'SELECT "parent" FROM "public"."EAV_links" WHERE "id" = ' . $id . ' AND distance = 0' );
        $self->_MoveChilds( { NewParent => $dParent } );
    }
    $self->{dbh}->do( 'DELETE FROM "public"."EAV_links" WHERE "id" IN (' . join( ',', @$items ) . ') ' );
    $self->{dbh}->do( 'DELETE FROM "public"."EAV_links" WHERE "parent" IN (' . join( ',', @$items ) . ') ' );
    $self->{dbh}->do( 'DELETE FROM "public"."EAV_items" WHERE "id" IN (' . join( ',', @$items ) . ')' );
    for my $tbl ( map { $self->{DataTables}->{ $_ }->[0] } keys %{ $self->{DataTables} } ) {
        $self->{dbh}->do( 'DELETE FROM ' . $tbl . ' WHERE "id" IN (' . join( ',', @$items ) . ')' );
    }

    delete( $self->{_item} );

    return 1;
}

sub _MakeFilterStatement {
    my ( $self, $Params ) = @_ ;

    my $v = $Params->{value};
    my $prefix = exists( $Params->{prefix} ) && defined( $Params->{prefix} ) ? $Params->{prefix} : '';

    my $res = '';
    if ( !defined( $v ) ) {
        $res .= $prefix . ' IS NULL ';
    }
    elsif ( !ref( $v ) ) {
        $res .= $prefix . ' = ' . $self->{dbh}->quote( $v )
    }
    elsif ( ref( $v ) eq 'SCALAR' && ( $$v == 0 || $$v == 1 ) ) {
        $res .= $prefix . ' = ' . ( $$v == 0 ? 'false' : 'true' )
    }
    elsif ( ref( $v ) eq 'ARRAY' && scalar( @$v ) ) {
        if ( scalar( @$v ) <= 10 ) {
            $res .= '( ' . join( ' OR ', map { $prefix . ' = ' . $self->{dbh}->quote( $_ ) } @$v ) . ' )';
        }
        elsif ( scalar( @$v ) <= 1000 ) {
            $res .= $prefix . ' IN ( ' . join( ', ', map { $self->{dbh}->quote( $_ ) } @$v ) . ' )';
        }
        else {
            $res .= $prefix . ' = ANY ( VALUES( ' . join( ', ', map { $self->{dbh}->quote( $_ ) } @$v ) . ' )';
        }
    }
    elsif ( ref( $v ) eq 'HASH' ) {
        my $simple_keys = { gt => '>', gte => '>=', lt => '<', lte => '<=', '~*' => '~*' };
        my $v_keys = { map { ( $_, lc( $_ ) ) } keys %$v };
        for my $k ( grep { exists( $simple_keys->{ $v_keys->{ $_ } } ) } keys %$v_keys ) {
            $res .= $prefix . ' ' . $simple_keys->{ $v_keys->{$k} } . ' ' . $self->{dbh}->quote( $v->{ $k } )
        }

        #ILIKE не использует left-handed индекс
        #поэтому lower(field) like 'some%'
        #работает сильно быстрее, чем то-же самое с ilike
        my $like_keys = { like => 'LIKE', ilike => 'ILIKE' };
        for my $k ( grep { exists( $like_keys->{ $v_keys->{ $_ } } ) } keys %$v_keys ) {
            my $value = $v->{ $k };
            my $p_start = ( $value =~ /^\%/ and $value =~ s/^\%// ? 1 : 0 );
            my $p_end = ( $value =~ /\%$/ and $value =~ s/\%$// ? 1 : 0 );
            #!!test quote and like with "_".
            $value = $self->{dbh}->quote( $value );
            $value =~ s/(?:^E?\'|\'$)//gs;
            # lc и lower делаются для ускорения поиска по текстовым полям, на которых используется left-handed индекс lower(field) varchar_pattern_ops
            $value = lc( $value );
            # $value =~ s/(^.?\'|\'$)//gs;
            $prefix = $prefix && $prefix ne '' ? "lower($prefix)" : '';
            $res .= $prefix . ' ' . $like_keys->{ $v_keys->{$k} } . ' \'' . ( $p_start ? '%' : '' ) . $value . ( $p_end ? '%' : '' ) . '\'';
        }
    }

    $self->{Debug} && $self->{LogObject}->Dumper($res);
    return $res;
}

sub _list {
    my ( $self, $Params ) = @_ ;

    my $call_source = @{[caller(1)]}[3] . " from line " . @{[caller(0)]}[2];

    my $sql = 'SELECT items.*';
    my $select_fields = '';
    if ( exists( $Params->{FIELDS} ) && defined( $Params->{FIELDS} ) ) {
        $sql = ( $Params->{FIELDS} =~ /^\,/ ? $sql . $Params->{FIELDS} : 'SELECT ' . $Params->{FIELDS} );
        $select_fields = $Params->{FIELDS};
    }
    my $data_sql = '';
    #joined ext fields
    #push order fields into $Params->{Fields}
    my $order_sql;
    my $filter_sql = '';
    my $items_filter_sql = '';
    $Params->{Order} = [] if !exists( $Params->{Order} ) || !defined( $Params->{Order} ) || !ref( $Params->{Order} ) || ref( $Params->{Order} ) ne 'ARRAY';

    my $SQLParts = { Order => \$order_sql, Data => \$data_sql, Filter => \$filter_sql, ItemFilter => \$items_filter_sql, SelectFields => \$select_fields };
    for my $pair ( grep { ref( $_ ) eq 'HASH' } @{ $Params->{Order} } ) {
        my ( $nulls ) = ( grep { $_ =~ /^nulls$/i } keys %$pair );
        my ( $sort_field ) = ( grep { $_ !~ /^nulls$/i } keys %$pair );
        next unless defined( $sort_field );

        my ( $set, $field ) = ( split /\./, $sort_field );
        my $is_sys_field = 0;
        $is_sys_field = 1 if $set eq 'items' || $set =~ /^links\d+$/;

        next if !$is_sys_field && ( !defined( $set ) || !defined( $field ) || !exists( $self->{Fields}->{ $set }->{ $field } ) );

        my $sort_order = $pair->{ $sort_field };
        $sort_order =~ uc( $sort_order );
        $sort_order = 'ASC' unless $sort_order =~ /^(?:ASC|DESC)$/;

        my $sql = ( $is_sys_field ? '' : '"' ) . $sort_field . ( $is_sys_field ? '' : '"' ) . ' ' . $sort_order;

        if ( defined( $nulls ) ) {
            my $nulls_v = $pair->{nulls_v};
            $nulls_v = 'LAST' if !defined( $nulls_v ) || $nulls_v !~ /^(?:first|last)$/i;
            $nulls_v = uc( $nulls_v );
            $sql = ' NULLS ' . $nulls_v;
        }

        $order_sql .= ( defined( $order_sql ) && length( $order_sql ) ? ', ' : '' ) . $sql;

        if ( !$is_sys_field ) {
            $Params->{Fields} = [] if !exists( $Params->{Fields} ) || !defined( $Params->{Fields} ) || !ref( $Params->{Fields} ) || ref( $Params->{Fields} ) ne 'ARRAY';
            push @{ $Params->{Fields} }, $sort_field unless scalar( grep { $_ eq $sort_field } @{ $Params->{Fields} } );
        }
    }

    if ( exists( $Params->{Fields} ) && ref( $Params->{Fields} ) eq 'ARRAY' ) {
        my $i = 0;
        for my $f ( @{ $Params->{Fields} } ) {
            my ( $set, $field ) = ( split /\./, $f );
            next if !defined( $set ) || !defined( $field ) || !exists( $self->{Fields}->{ $set }->{ $field } );
            my $Field = $self->{Fields}->{ $set }->{ $field };
            $select_fields .= ', OutData'.$i.'."data" AS "'.$f.'"';
            $sql .= $select_fields;
            my $tbl = $self->{DataTables}->{ $Field->{type} }->[0];
            $data_sql .= ' INNER JOIN '.$tbl.' AS OutData'.$i.' ON items."id" = OutData'.$i.'."id" AND OutData'.$i.'."field_id" = '.$Field->{id};
            if ( exists( $Params->{Filter}->{$f} ) ) {
                $data_sql .= ' AND '.$self->_MakeFilterStatement( { value => $Params->{Filter}->{$f}, prefix => 'OutData'.$i.'."data"' } );
            }
            $i++;
        }
    }
    $sql .= ' FROM '.( exists( $Params->{INJECTION} ) ? $Params->{INJECTION} : '' ).' "public"."EAV_items" AS items '.( exists( $Params->{INJECTION} ) ? ' ON items."id" = INJECTION."id" ' : '' ).' ';
    my $i = 0;
    if ( exists( $Params->{Parents} ) && defined( $Params->{Parents} ) && ref( $Params->{Parents} ) ) {
        if ( ref( $Params->{Parents} ) eq 'HASH' ) {
            for my $p ( keys %{ $Params->{Parents} } ) {
                if ( !ref( $Params->{Parents}->{ $p } ) ) {
                    $sql .= ' INNER JOIN "public"."EAV_links" AS links'.$i.' ON links'.$i.'."id" = items."id" AND links'.$i.'."parent" = '.int( $p );
                    $sql .= ' AND links'.$i.'."distance" = '.int( $Params->{Parents}->{ $p } || 0 )
                }
                elsif ( ref( $p ) eq 'HASH' ) {
                    $sql .= ' INNER JOIN "public"."EAV_links" AS links'.$i.' ON links'.$i.'."id" = items."id" AND links'.$i.'."parent" = '.int( $p );
                    $sql .= ' AND links'.$i.'."distance" = '.int( $Params->{Parents}->{ $p }->{distance} );
#                    if ( exists( $Params->{Parents}->{ $p }->{SelfType} ) && $Params->{Parents}->{ $p }->{SelfType} ) {
#                        $sql .= ' INNER JOIN '
#                    };
                }
            }
        }
        elsif ( ref( $Params->{Parents} ) eq 'ARRAY' ) {
            for my $p ( @{ $Params->{Parents} } ) {
                $sql .= ' INNER JOIN "public"."EAV_links" AS links'.$i.' ON links'.$i.'."id" = items."id" AND links'.$i.'."parent" = '.int( $p );
            }
        }
        $i++;
    }
    $sql .= $data_sql;
    if ( exists( $Params->{Filter} ) && ref( $Params->{Filter} ) eq 'HASH' ) {
        my $i = 0;
        for my $f ( keys %{ $Params->{Filter} } ) {
            #already joined and filtered in $data_sql
            next if exists( $Params->{Fields} ) && ref( $Params->{Fields} ) eq 'ARRAY' && scalar( grep { $_ eq $f } @{ $Params->{Fields} } );
            if ( exists( $self->{ItemFields}->{ $f } ) ) {
                $items_filter_sql .= ' AND ' . $self->_MakeFilterStatement( { value => $Params->{Filter}->{$f}, prefix => 'items."' . $f . '"' } );
                next;
            }

            my ( $set, $field ) = ( split /\./, $f );
            next if !defined( $set ) || !defined( $field ) || !exists( $self->{Fields}->{ $set }->{ $field } );
            my $Field = $self->{Fields}->{ $set }->{ $field };

            my $tbl = $self->{DataTables}->{ $Field->{type} }->[0];
            $filter_sql .= ' INNER JOIN '.$tbl.' AS FilterData'.$i.' ON items."id" = FilterData'.$i.'."id" AND FilterData'.$i.'."field_id" = '.$Field->{id};
            $filter_sql .= ' AND '.$self->_MakeFilterStatement( { value => $Params->{Filter}->{$f}, prefix => 'FilterData'.$i.'."data"' } );
        }
    }
    $sql .= $filter_sql;
    $sql .= $Params->{JOIN} if exists( $Params->{JOIN} ) && defined( $Params->{JOIN} );
    $items_filter_sql .= ' AND has_childs = 0 ' if scalar( grep { $_ =~ /leaves/i } keys %$Params );
    $sql .= ' WHERE 1 = 1 ' . ( exists( $Params->{Filter}->{Type} ) ? ' AND ' . $self->_MakeFilterStatement( { value => $Params->{Filter}->{Type}, prefix => 'items."import_type"' } ) : '' ) . $items_filter_sql;
    #default - show only published items, if we want to look over all - should add ShowHidden => 1, if we want to look hidden only - should add ShowHiddenOnly
    if ( !scalar( grep { $_ eq 'ShowHidden' && defined( $Params->{$_} ) && $Params->{$_} } keys %$Params ) ) {
        $sql .= ' AND items.publish = true ';
    }
    elsif ( exists( $Params->{ShowHiddenOnly} ) && $Params->{ShowHiddenOnly} ) {
        $sql .= ' AND items.publish = false ';
    }
    #else - ShowHidden exists and it's true - so we are not use "publish" filter.

    $sql .= ' ' . $Params->{GROUP_BY} . ' ' if exists( $Params->{GROUP_BY} );

    $order_sql = ' items.id DESC ' unless defined( $order_sql );
    $sql .= ' ORDER BY ' . $order_sql;

    my $limit = exists( $self->{DefaultLimit} ) && int( $self->{DefaultLimit} || 0 ) ? int( $self->{DefaultLimit} ) : 50;

    if ( exists( $Params->{Limit} ) && defined( $Params->{Limit} ) ) {
        $limit = 'ALL' if $Params->{Limit} =~ /^all$/i;
        if ( $Params->{Limit} !~ /^null$/i ) {
            $limit =  int( $Params->{Limit} ) if int( $Params->{Limit} || 0 );
            $sql .= ' LIMIT '.$limit;
        }
    }

    my $offset = 0;
    $offset = int( $Params->{Offset} ) if exists( $Params->{Offset} ) && int( $Params->{Offset} || 0 );
    $sql .= ' OFFSET ' . $offset if $offset;

    return ( wantarray ? ( $sql, $SQLParts ) : $sql ) if exists( $Params->{SQLResult} ) && defined( $Params->{SQLResult} ) && $Params->{SQLResult};

    my $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();
    my $r = $sth->fetchall_arrayref({});
    $sth->finish();

    return $r;
}

sub getIDByImport {
    my $self = shift;

    return $self->{dbh}->selectrow_array( 'SELECT "id" FROM "public"."EAV_items" WHERE "import_id" = ' . $self->{dbh}->quote( $_[0] ) . ' AND "import_type" = ' . $self->{dbh}->quote( $self->{Type} ) );
}

sub getParentsInTree {
    my ( $self, $Params ) = @_;

    return undef() unless $self->{_item};
    return undef() unless defined( $Params );
    my $parent = ref( $Params ) && ref( $Params ) eq 'HASH' && exists( $Params->{parent} ) ? int( $Params->{parent} || 0 ): int( $Params || 0 );
    return undef() unless $parent;

    my $sth = $self->{dbh}->prepare(
        'SELECT l."parent", l."distance" FROM "public"."EAV_links" AS l '.
        'INNER JOIN "public"."EAV_links" AS l_control ON l_control."id" = l."parent" AND l_control."parent" = ' . $parent . ' ' .
        'WHERE l."id" = ' . int( $self->{_item}->{id} )
    );
    $sth->execute();
    my $r = $sth->fetchall_arrayref({});
    $sth->finish();

    return [ sort { $a->{distance} <=> $b->{distance} } @$r ];
}

sub Search {
    my ( $self, $Params ) = @_;

    return undef() unless $self->{Type};

    my $Set = $self->{Type};

    my $ItemsSubQuery = 'SELECT d."id" FROM ';
    if ( exists( $Params->{Field} ) ) {
        my $fields = $Params->{Field};
        $fields = [ $Params->{Field} ] unless ref( $Params->{Field} ) eq 'ARRAY';
        my $lt = undef();
        my $fields_sql = [];
        for my $f ( map { $self->{Fields}->{ $Set }->{ $_ } } grep { exists( $self->{Fields}->{ $Set }->{ $_ } ) } @$fields ) {
            return undef() if defined( $lt ) && $lt ne $f->{type};
            $lt = $f->{type};
            push @$fields_sql, $f->{id};
        }
        $ItemsSubQuery .= $self->{DataTables}->{ $lt }->[0] . ' AS d WHERE ';
        $ItemsSubQuery .= '( ' . join( ' OR ', map { 'd."field_id" = ' . $_ } @$fields_sql ) . ' ) AND ';
    }
    else {
        return undef() unless exists( $Params->{Type} ) && defined( $Params->{Type} );
        return undef() unless exists( $self->{DataTables}->{ $Params->{Type} } );
        $ItemsSubQuery .= $self->{DataTables}->{ $Params->{Type} }->[0].' AS d WHERE ';
    }
    $ItemsSubQuery .= $self->_MakeFilterStatement( { value => $Params->{Value}, prefix => exists( $Params->{Prefix} ) ? $Params->{Prefix} : 'd."data"' } );

    my $unions = [];
    for my $dt ( keys %{ $self->{DataTables} } ) {
        my $sql = 'SELECT "id", "field_id", "data"' . ( $dt eq 'string' ? '' : '::varchar(4096)' ) . ' FROM ' . $self->{DataTables}->{ $dt }->[0] . ' WHERE "id" IN ( ' . $ItemsSubQuery . ' ) ';
        push @$unions, $sql;
    }

    my $sql = join( ' UNION ', @$unions );
    return $sql if $Params->{SQLResult};

    my $rows = $self->{DBObject}->SelectAllHR( $sql );

    my $Result = [];
    my $lid = 0;
    my $i = -1;
    for my $r ( @$rows ) {
        if ( $$r{id} != $lid ) {
            push @$Result, { id => $$r{id} };
            $lid = $$r{id};
            $i++;
        }
        $Result->[ $i ]->{ $self->{FieldsById}->{ $$r{field_id} }->{alias} } = $$r{data};
    }

    return $Result;
}

sub BreadCrumbsArray {
    my ( $self, $Type ) = @_;

    my @Crumbs = ();
    return [] if !$self->id() && !$self->type();

    $Type //= $self->type();
    $Type = ucfirst($Type);

    @Crumbs = (
        grep { $_->parent() && $_->type ne 'location' }
        map { Freee::EAV->new( 'Auto', { id => $_ } ) }
        grep { $_ }
        map { $_->{parent} }
        sort { $a->{distance} <=> $b->{distance} }
        @{ $self->{_item}->{parents} }
    );
    unshift @Crumbs, $self;

    # Обрезаем путь на Группирующем Узле
    my $FilterIndex = 0;
    for my $c ( @Crumbs ) {
        last if $c->GroupLeader();
        ++$FilterIndex;
    }
    @Crumbs = @Crumbs[ 0..$FilterIndex ] if $FilterIndex <= $#Crumbs;
    @Crumbs = reverse( @Crumbs );

    @Crumbs = map {
        {
            'id'         => $_->id(),
            'owner_type' => $_->type(),
            'title'      => $_->GetTitle() ####$Title
        }
    } @Crumbs;

    return @Crumbs;
}

1;
