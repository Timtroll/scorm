package Freee::Helpers::PgRoutes;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Routes

    # получение списка рутов из базы в массив хэшей
    # my $routes = $self->_routes_values();
    $app->helper( '_routes_values' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT id, label FROM "public"."routes"', 'id');

        return $list;
    });

    # обновление роута
    # my $id = $self->_update_route({
    #      "id"         => 1,           - id обновляемого элемента ( >0 )
    #     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "value"       => "",          - строка или json
    #     "required"    => 0,           - не обязательно, по умолчанию 0
    #     "status"      => 0            - по умолчанию 1
    # });
    # возвращается true/false
    $app->helper( '_update_route' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $db_result;
        eval {
            $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};
        };

        if ($@) { 
            print $DBI::errstr . "\n";
        }

        return $db_result;
    });

    # проверка корректности наследования
    # my $true = $self->_parent_check_route( 99 );
    # возвращается true/false
    $app->helper( '_parent_check_route' => sub {

        my ($self, $parent) = @_;

        my $db_result = 0;

        # родитель задан?
        if ( $parent ) {
            # родитель существует?
            if ( $self->pg_dbh->selectrow_array( 'SELECT * FROM "public"."groups" WHERE "id"='.$parent ) ) {
                 $db_result = 1;   
            }
        }

        return $db_result;
    });

    # синхронизация между роутами в системе и таблицей
    $app->helper( '_sync_routes' => sub {
        my $self = shift;

        my ($list, $id, $name, @result, $hashlist);

        eval {
            $list = $self->pg_dbh->selectall_hashref('SELECT id, label, name FROM "public"."routes"', 'id');
        };
        if ($@) { 
            return "Can't select from DB";
        }

        eval {
            foreach $id (sort {$a <=> $b} keys %$list) {
                unless ( exists $$routs{ $$list{$id}{'name'} } ) {
                    $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ); 
                }
                $$hashlist{ $$list{ $id }{'name'} } = $id;      
            }
        };
        if ($@) { 
            return "Can't delete from DB";
        }

        eval {
            foreach $name (keys %$routs) {
                unless ( exists $$hashlist{ $name } ) {
                    if ( $self->pg_dbh->do( 'INSERT INTO "public"."routes" ("label","name") VALUES ('."'".$$routs{$name}."','".$name."')" ) ) {
                         print "\n";
                         print $name;
                    }
                }
            }
        };
        if ($@) { 
            return "Can't add to the DB";
        }

        return "ok";

    });


    # добавление роута
    # my $id = $self->_insert_route({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
    #     "status"      => 0                - активность элемента, по умолчанию 1
    # });
    # возвращается id роута
    $app->helper( '_insert_route' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $id;
        eval{
            if ( $self->pg_dbh->do('INSERT INTO "public"."routes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'routes', undef, { sequence => 'routes_id_seq' } );
            }
        };

        if ($@) { 
            print $DBI::errstr . "\n";
        }

        return $id;
    });


    # проверка на наличие в бд строки с таким системным названием
    # my $true = $self->_name_check_route ( /cms/item );
    # возвращается true/false
    $app->helper( '_name_check_route' => sub {

        my ($self, $name) = @_;

        return unless $name;

        my $db_result = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."routes" WHERE "name"='.$name);

        return $db_result;
    });
}

1;
