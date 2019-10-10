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


    # синхронизация между роутами в системе и таблицей
    $app->helper( '_sync_routes' => sub {
        my $self = shift;

        my ($list, $id, $name, $groups, $parent, $hashlistName, $hashlistParent);

        eval {
            $groups = $self->_all_groups();
        };
        if ($@) { 
            return "Can't connect to the Groups DB";
        }

        eval {
            $list = $self->pg_dbh->selectall_hashref('SELECT id, label, name, parent FROM "public"."routes"', 'id');
        };
        if ($@) { 
            return "Can't select from DB";
        }

        foreach $parent (sort {$a <=> $b} keys %$groups) {

            foreach $id (sort {$a <=> $b} keys %$list) {
                unless ( ( exists $$routs{ $$list{$id}{'name'} } ) && ( exists $$groups{ $$list{$id}{'parent'} } ) ) {
                    $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ); 
                }
                $$hashlistName{ $$list{ $id }{'name'} } = $id;
                $$hashlistParent{ $$list{ $id }{'parent'} } = $id;
            }

            foreach $name (keys %$routs) {
                unless ( ( exists $$hashlistName{ $name } ) && ( exists $$hashlistParent{ $parent } ) ) {
                    $self->pg_dbh->do( 'INSERT INTO "public"."routes" ("label","name","parent") VALUES ('."'".$$routs{$name}."','".$name."','".$parent."')" );
                }
            }
        }

        return 1;


        #my $hashlist;
        # eval {
        #     foreach $id (sort {$a <=> $b} keys %$list) {
        #         unless ( exists $$routs{ $$list{$id}{'name'} } ) {
        #             $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ); 
        #         }
        #         # $$hashlist{ $$list{ $id }{'name'} } = $id;      
        #     }
        # };
        # if ($@) { 
        #     return "Can't delete from DB";
        # }

        # eval {
        #     foreach $name (keys %$routs) {
        #         unless ( exists $$hashlist{ $name } ) {
        #             $self->pg_dbh->do( 'INSERT INTO "public"."routes" ("label","name") VALUES ('."'".$$routs{$name}."','".$name."')" );
        #         }
        #     }
        # };
        # if ($@) { 
        #     return "Can't add to the DB";
        # }


        # foreach my $parent (sort {$a <=> $b} keys %$groups) {

        #     foreach $id (sort {$a <=> $b} keys %$list) {
        #             $$hashlistName{ $$list{ $id }{'name'} } = $id;
        #             $$hashlistParent{ $$list{ $id }{'parent'} } = $id;
        #     }

        #     foreach $name (keys %$routs) {
        #         unless ( ( exists $$hashlistName{ $name } ) && ( exists $$hashlistParent{ $parent } ) ) {
        #             $self->pg_dbh->do( 'INSERT INTO "public"."routes" ("label","name","parent") VALUES ('."'".$$routs{$name}."','".$name."','".$parent."')" );
        #         }
        #     }
        # }
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


    # # удаление роута
    # # my $true = $self->_delete_route( 99 );
    # # возвращается true/false
    # $app->helper( '_delete_route' => sub {
    #     my ($self, $id) = @_;

    #     return unless $id;

    #     my $db_result = 0;
        
    #     if ( ( $db_result = $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ) ) == "0E0" ) { 
    #         print "Row for deleting doesn't exist \n";
    #         $db_result = 0;
    #     }   

    #     return $db_result;
    # });


    # # изменение параметра status на 0
    # # возвращается true/false
    # $app->helper( '_hide_route' => sub {

    #     my ($self, $id) = @_;

    #     return unless $id;

    #     my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET "status" = 0 WHERE "id"='.$id );

    #     return $db_result;
    # });


    # # изменение параметра status на 1
    # # возвращается true/false
    # $app->helper( '_activate_route' => sub {

    #     my ($self, $id) = @_;

    #     return unless $id;

    #     my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET "status" = 1 WHERE "id"='.$id );

    #     return $db_result;
    # });

}

1;
