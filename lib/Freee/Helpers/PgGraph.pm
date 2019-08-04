package Freee::Helpers::PgGraph;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Postgress

    $app->helper( 'pg_dbh' => sub {
        unless ($dbh) {
            $dbh = DBI->connect(
                $config->{'dbs'}->{'databases'}->{'pg_main'}->{'dsn'},
                $config->{'dbs'}->{'databases'}->{'pg_main'}->{'username'},
                $config->{'dbs'}->{'databases'}->{'pg_main'}->{'password'},
                $config->{'dbs'}->{'databases'}->{'pg_main'}->{'options'}
            );
        }
        return $dbh;
    });

    $app->helper( 'pg_init' => sub {
        my $self = shift;

        my $sth = $self->pg_dbh->prepare( 'SELECT * FROM "public"."EAV_fields"' );
        $sth->execute();
        my $fields = $sth->fetchall_arrayref({});
        $sth->finish();
print "fields", Dumper($fields);
        $self->{FieldsAsArray} = $fields;
        $self->{Fields} = {};
        foreach my $field ( @$fields ) {
            $self->{Fields}->{ $field->{set} }->{ $field->{alias} } = $field;
            $self->{FeildsById}->{ $$field{id} } = $field;
        };

        $self->{DataTables} = {
            int => '"public"."EAV_data_int4"',
            string => '"public"."EAV_data_string"',
            boolean => '"public"."EAV_data_boolean"',
            datetime => '"public"."EAV_data_datetime"'
        };
    });

    $app->helper( 'pg_get' => sub {
        my $self = shift;
        my $id = int( $_[0] || 0 );

        my $item = $self->pg_dbh->selectrow_hashref( 'SELECT * FROM "public"."EAV_items" WHERE "id" = '.$id );
        #!!FIXIT
        $$item{type} = $$item{import_type};
        delete( $$item{import_type} );
        #!!FIXIT
        my $sth = $self->pg_dbh->prepare( 'SELECT "parent", "distance" FROM "public"."EAV_links" WHERE "id" = '.$id );
        $sth->execute();
        $item->{parents} = $sth->fetchall_arrayref({});
        $sth->finish();

        return $item
    });

    $app->helper( 'pg_get_all' => sub {
        my $self = shift;
        return undef() unless exists( $self->{_item} );

        $self->{_item}->{Childs} = $self->_get_childs( { Split => 1 } );
        
        my $types = { map { ( $self->{Fields}->{ $self->{_item}->{type} }->{ $_ }->{type}, 1 ) } keys %{ $self->{Fields}->{ $self->{_item}->{type} } } };

        foreach my $tbl ( map { $self->{DataTables}->{ $_ } } grep { exists( $types->{ $_ } ) } keys %{ $self->{DataTables} } ) {
            my $sth = $self->pg_dbh->prepare( 'SELECT "field_id", "data" FROM '.$tbl.' WHERE "id" = '.int( $self->{_item}->{id} ) );
            $sth->execute();
            my $rows = $sth->fetchall_arrayref({});
            $sth->finish();

            foreach my $r ( @$rows ) {
                my $alias = $self->{FeildsById}->{ $$r{field_id} };
                $self->{_item}->{ $alias } = $r->{data};
            };
        };

        return $self->{_item};
    });

    $app->helper( 'pg_get_field' => sub {
        my $self = shift;
        my $field = shift;

        return undef() unless exists( $self->{_item} );
        return undef() unless exists( $self->{Fields}->{ $self->{_item}->{type} }->{ $field } );

        my $val = $self->{Fields}->{ $self->{_item}->{type} }->{ $field };
        my $result = $self->pg_dbh->selectrow_array( 'SELECT "data" FROM '.$self->{DataTables}->{ $$val{type} }.' WHERE "id" = '.$self->{_item}->{id}.' AND "field_id" = '.$$val{id} );

        return $result;
    });

    $app->helper( 'pg_get_childs' => sub {
        my $self = shift;
        return undef() unless exists( $self->{_item} );

        my $id = int( $self->{_item}->{id} );

        my $Params = $_[0];

        my $sth = $self->pg_dbh->prepare( 'SELECT "id", "distance" FROM "public"."EAV_links" WHERE "parent" = '.$id.( exists( $Params->{Direct} ) ? ' AND "distance" = 0' : '' ) );
        $sth->execute();
        my $Childs = $sth->fetchall_arrayref({});
        $sth->finish();

        return [ map { $_->{id} } @{ $Childs } ] if !exists( $Params->{Split} ) || !$Params->{Split};

        return {
            Direct => [ map { $_->{id} } grep { !$_->{distance} } @{ $Childs } ],
            All => $Childs
        };
    });

    $app->helper( 'pg_store' => sub {
        my $self = shift;
        my ( $field, $data ) = @_;

print "-1--\n";
        return undef() unless exists( $self->{_item} );
print "-2--\n";
        return undef() unless exists( $self->{Fields}->{ $self->{_item}->{type} }->{ $field } );
print "-3--\n";
        my $val = $self->{Fields}->{ $self->{_item}->{type} }->{ $field };
print "-4--\n";
        if ( $$val{type} eq 'boolean' ) {
            my $value = 'true';
            $value = 'NULL' if !defined( $data );
            $value = 'false' if !$data || $data eq 'f' || $data eq 'false';
            $data = $value;
        } else {
            $data = $self->pg_dbh->quote( $data );
        };

        my $result = $self->pg_dbh->do( 
            'INSERT INTO '.$self->{DataTables}->{ $$val{type} }.'  ( "id", "field_id", "data" ) VALUES ( '.int( $self->{_item}->{id} ).', '.int( $$val{id} ).', '.$data.') '.
            'ON CONFLICT '.
            'ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "data" = '.$data 
        );

        return $result;
    });

    $app->helper( 'pg_create' => sub {
        my $self = shift;
        my $Item = $_[0];
print "-------------\n";
print "FieldsAsArray", Dumper($self);
# print "Item = ", Dumper($Item);
        # die unless exists( $$Item{type} ) && exists( $self->{Fields}->{ $$Item{type} } );
        die unless exists( $$Item{parent} ) && $$Item{parent} =~ /^\d+$/;
print "-------------\n";
        my $data = { 'publish' => 'false', 'import_type' => $self->pg_dbh->quote( $$Item{type} ) };
# print "data = ", Dumper($data);
        $$data{publish} = 'true' if exists( $$Item{publish} ) && $$Item{publish} && $$Item{publish} !~ /^(?:false|0)$/i;
        $$data{import_id} = $self->pg_dbh->quote( $$Item{import_id} ) if exists( $$Item{import_id} ) && defined( $$Item{import_id} );
        $$data{title} = $self->pg_dbh->quote( $$Item{title} );
# print "data = ", Dumper($data);
        # $self->pg_dbh->do( 'BEGIN TRANSACTION' );

        $self->pg_dbh->do( 'INSERT INTO "public"."EAV_items" ('.join( ',', map { '"'.$_.'"'} keys %$data ).') VALUES ('.join( ',', map { $$data{$_} } keys %$data ).') RETURNING "id"' );
# print "err = ", Dumper($data);
        # my $id = $$data{id} = $self->pg_dbh->last_insert_id();
        my $id = $$data{id} = $self->pg_dbh->last_insert_id(undef, 'public', 'EAV_items', undef, { sequence => 'eav_items_id_seq' });
# print "id = ", Dumper($id);
print "-------------\n";
print "FieldsAsArray = ", Dumper($self->{FieldsAsArray});

        foreach my $val ( grep { defined( $_->{default_value} ) } @{ $self->{FieldsAsArray} } ) {
            $self->pg_dbh->do( 'INSERT INTO '.$self->{DataTables}->{ $$val{type} }.' ( "id", "field_id", "data" ) VALUES ('.$id.', '.$$val{fieldid}.', '.$self->pg_dbh->quote( $$val{default_value} ).' )'  );
            $data->{ $$Item{type} }->{ $$val{alias} } = $$val{default_value};
        };

        $self->pg_dbh->do( 'INSERT INTO "public"."EAV_links" ("parent", "id", "distance") VALUES ('.$$Item{parent}.', '.$id.', 0)' );
        # $self->pg_dbh->do( 'COMMIT' );
        $data->{parents} = [ {distance => 0, parent => $$Item{parent} }, map { $_->{distance} += 1; $_ } sort { $a->{distance} <=> $b->{distance} } @{ $self->pg_get( $$Item{parent} )->{parents} } ];

        return $data;
    });

    $app->helper( 'pg_delete' => sub {
        my $self = shift;
        return undef() unless exists( $self->{_item} );
        return $self->pg_dbh->do( 'UPDATE "public"."EAV_items" SET "publish" = false WHERE "id" = '.int( $self->{_item}->{id} ) );
    });

    $app->helper( 'pg_move_childs' => sub {
        my $self = shift;
        my $Params = $_[0];
        return undef() unless exists( $Params->{NewParent} );
        my $id = int( $self->{_item}->{id} );

        my $Childs = $self->_get_childs();

        #move childs to parent of this node inside it's graph.
        my $sth = $self->pg_dbh->prepare( 'SELECT "parent", "distance" FROM "public"."EAV_links" WHERE "id" = '.$id );
        my $parents = $sth->fetchall_arrayref({});
        $sth->finish();
        foreach my $parent ( @$parents ) {
            $self->pg_dbh->do( 'DELETE FROM "public"."EAV_links" WHERE "parent" = '.$parent->{parent}.' AND "id" IN ('.join( ', ', @$Childs ).')' );
        };

        foreach my $child ( @$Childs ) {
            $self->pg_dbh->do( 
                'INSERT INTO "public"."EAV_links" ( "id", "parent", "distance" ) VALUES ( '.$child.', '.int( $Params->{NewParent} ).', 0 ) '.
                'ON CONFLICT ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "distance" = 0' 
            );
        };

        return 1;
    });

    $app->helper( 'pg_real_delete' => sub {
        my $self = shift;
        return undef() unless exists( $self->{_item} );

        my $id = int( $self->{_item}->{id} );
        return undef() if !$id;#use truncates..

        my $Params = $_[0];

        my $items = [ $id ];

        my $Childs = $self->_get_childs();

        if ( !exists( $Params->{SaveChilds} ) || !$Params->{SaveChilds} ) {
            push @$items, @$Childs;
        } else {
            my $dParent = $self->pg_dbh->selectrow_array( 'SELECT "parent" FROM "public"."EAV_links" WHERE "id" = '.$id.' AND distance = 0' );
            $self->_move_childs( $dParent );
        };
        $self->pg_dbh->do( 'DELETE FROM "public"."EAV_links" WHERE "id" IN ('.join( ',', @$items ).') ' );
        $self->pg_dbh->do( 'DELETE FROM "public"."EAV_links" WHERE "parent" IN ('.join( ',', @$items ).') ' );
        $self->pg_dbh->do( 'DELETE FROM "public"."EAV_items" WHERE "id" IN ('.join( ',', @$items ).')' );
        foreach my $tbl ( map { $self->{DataTables}->{ $_ } } keys %{ $self->{DataTables} } ) {
            $self->pg_dbh->do( 'DELETE FROM '.$tbl.' WHERE "id" IN ('.join( ',', @$items ).')' );
        };

        delete( $self->{_item} );

        return 1;
    });

    $app->helper( 'pg_make_filter_statement' => sub {
        my ( $self, $Params ) = @_ ;

        my $v = $Params->{value};
        my $prefix = $Params->{prefix};

        my $res = '';
        if ( !defined( $v ) ) {
            $res .= ' AND '.$prefix.' IS NULL ';
        } elsif ( !ref( $v ) ) {
            $res .= ' AND '.$prefix.' = '.$self->pg_dbh->quote( $v )
        } elsif ( ref( $v ) eq 'SCALAR' && $v == \0 || $v == \1 ) {
            $res .= ' AND '.$prefix.' = '.( $v == \0 ? 'false' : 'true' )
        } elsif ( ref( $v ) eq 'ARRAY' && scalar( @$v ) ) {
            if ( scalar( @$v ) <= 10 ) {
                $res .= ' AND ( '.join( ' OR ', map { $prefix.' = '.$self->pg_dbh->quote( $_ ) } @$v ).' )';
            } elsif ( scalar( @$v ) <= 1000 ) {
                $res .= ' AND '.$prefix.' IN ( '.join( ', ', map { $self->pg_dbh->quote( $_ ) } @$v ).' )';
            } else {
                $res .= ' AND '.$prefix.' = ANY ( VALUES( '.join( ', ', map { $self->pg_dbh->quote( $_ ) } @$v ).' )';
            }
        } elsif ( ref( $v ) eq 'HASH' ) {
            $res .= ' AND '.$prefix.' > '.$self->pg_dbh->quote( $v->{gt} ) if exists( $v->{gt} ) && defined( $v->{gt} );
            $res .= ' AND '.$prefix.' >= '.$self->pg_dbh->quote( $v->{gt} ) if exists( $v->{gt_or_eq} ) && defined( $v->{gt_or_eq} );
            $res .= ' AND '.$prefix.' < '.$self->pg_dbh->quote( $v->{gt} ) if exists( $v->{lt} ) && defined( $v->{lt} );
            $res .= ' AND '.$prefix.' <= '.$self->pg_dbh->quote( $v->{gt} ) if exists( $v->{lt_or_eq} ) && defined( $v->{lt_or_eq} );
        }
    });

    $app->helper( 'pg_list' => sub {
        my ( $self, $Params ) = @_ ;

        my $sql = 'SELECT i.*';
        my $data_sql = '';
        #fields
        if ( exists( $Params->{Fields} ) && ref( $Params->{Fields} ) eq 'ARRAY' ) {
            my $i = 0;
            foreach my $f ( @{ $Params->{Fields} } ) {
                my ( $set, $field ) = ( split /\./, $f );
                next if !defined( $set ) || !defined( $field ) || !exists( $self->{Fields}->{ $set }->{ $field } );
                my $Field = $self->{Fields}->{ $set }->{ $field };
                $sql .= ', OutData'.$i.'."data" AS "'.$f.'"';
                my $tbl = $self->{DataTables}->{ $Field->{type} };
                $data_sql .= ' INNER JOIN '.$tbl.' AS OutData'.$i.' ON i."id" = OutData'.$i.'."id" AND OutData'.$i.'."field_id" = '.$Field->{id};
                if ( exists( $Params->{Filter}->{$f} ) ) {
                    $data_sql .= $self->_make_filter_statement( { value => $Params->{Filter}->{$f}, prefix => 'OutData'.$i.'."data"' } );
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
                next if !defined( $set ) || !defined( $field ) || !exists( $self->{Fields}->{ $set }->{ $field } );
                my $Field = $self->{Fields}->{ $set }->{ $field };

                my $tbl = $self->{DataTables}->{ $Field->{type} };
                $filter_sql .= ' INNER JOIN '.$tbl.' AS FilterData'.$i.' ON i."id" = FilterData'.$i.'."id" AND FilterData'.$i.'."field_id" = '.$Field->{id};
                $filter_sql .= $self->_make_filter_statement( { value => $Params->{Filter}->{$f}, prefix => 'FilterData'.$i.'."data"' } );
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
    });


    ###################################################################
    # служебные
    ###################################################################

    # список полей
    # $self->list_fields();
    $app->helper( 'list_fields' => sub {
        my $self = shift;
        # return $self->pg_dbh->selectrow_hashref('SELECT id, title, alias, type FROM "public"."EAV_fields" WHERE 1 = 1'); #, {Slice=>{}}, undef);
        return $self->pg_dbh->selectall_arrayref('SELECT id, title, alias, type FROM "public"."EAV_fields"', { Slice=> {} } );
    });

    # создание полей
    # $self->create_field(
    # {
        #     id      => 1,
        #     alias   => 'theme',
        #     title   => 'Тема',
        #     type    => 'string',
        #     set     => 'user'
    # });
    $app->helper( 'create_field' => sub {
        my $self = shift;
        my $data = shift;
        return $self->pg_dbh->do( 'INSERT INTO "public"."EAV_fields" ("id", "title", "alias", "type", "set") VALUES '."( '$$data{id}', '$$data{title}', '$$data{alias}', '$$data{type}', '$$data{set}' ) RETURNING \"id\"" );
    });

    # update поля
    # $self->update_field(
    # {
    #     id      => 1,
    #     alias   => 'theme',
    #     title   => 'Тема',
    #     type    => 'string',
    #     set     => 'lesson'
    # }));
    $app->helper( 'update_field' => sub {
        my $self = shift;
        my $data = shift;
        return $self->pg_dbh->do('UPDATE "public"."EAV_fields" SET '.join( ', ', map { "$_='$$data{$_}'" } keys %$data )." WHERE id=$$data{id} RETURNING id") if $$data{id};
    });

    # удаление поля
    # $self->delete_field(5);
    $app->helper( 'delete_field' => sub {
        my $self = shift;
        my $id = shift;
        return $self->pg_dbh->do( 'DELETE FROM "public"."EAV_fields" WHERE "id"='.$id );
    });

    # очистка базы 
    # $self->tranc_bases();
    $app->helper( 'tranc_bases' => sub {
        my $self = shift;
        
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_boolean" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_datetime" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_int4" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_string" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_fields" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_items" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_links" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_sets" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_submodules_subscriptions" RESTART IDENTITY' );

        return 1;
    });
}

1;
