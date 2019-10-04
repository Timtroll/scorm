package Freee::Helpers::PgRoutes;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;
use experimental 'smartmatch';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Routes


    # получение списка рутов из базы в виде объекта
    # my $list = $self->_all_routes();
    # возвращает массив хэшей
    $app->helper( '_routes_values' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT id,label FROM "public"."routes"', 'id');

        return $list;
    });


    # для создания возможностей групп пользователей
    # my $id = $self->_insert_route({
    #       "folder"      => 0,           - это возможности пользователя
    #     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    #     "value"       => "",            - строка или json
    #     "required"    => 0            - не обязательно, по умолчанию 0
    # });
    # для создания группы пользователей
    # my $id = $self->_insert_route({
    #     "folder"      => 1,           - это группа пользователей
    #     "parent"      => 0,           - обязательно 0 (должно быть натуральным числом) 
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    # });
    # возвращается id записи    
    $app->helper( '_insert_route' => sub {
        my ($self, $data) = @_;
        return unless $data;
        my $id;

        if ( $self->pg_dbh->do('INSERT INTO "public"."routes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
            $id = $self->pg_dbh->last_insert_id( undef, 'public', 'routes', undef, { sequence => 'routes_id_seq' } );
        }
 
        return $id;
    });


    # для создания возможностей групп пользователей
    # my $id = $self->_insert_route({
    #     "folder"      => 0,           - это возможности пользователя
    #     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    #     "value"       => "",            - строка или json
    #     "required"    => 0            - не обязательно, по умолчанию 0
    # });
    # для создания группы пользователей
    # my $id = $self->_insert_route({
    #     "folder"      => 1,           - это группа пользователей
    #     "parent"      => 0,           - обязательно 0 (должно быть натуральным числом) 
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    # });
    # возвращается true/false
    $app->helper( '_update_route' => sub {
        my ($self, $data) = @_;
        return unless $data;

        my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};

        return $db_result;
    });


    # для удаления группы пользователей
    # my $true = $self->_delete_route( 99 );
    # возвращается true/false
    $app->helper( '_delete_route' => sub {
        my ($self, $id) = @_;
        return unless $id;
        my $db_result = 0;
        
        if ( ( $db_result = $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ) ) == "0E0" ) { 
            print "Row for deleting doesn't exist \n";
            $db_result = 0;
        }   

        return $db_result;
    });


    # для изменения параметра status на 0
    # возвращается true/false
    $app->helper( '_hide_route' => sub {
        my ($self, $id) = @_;
        return unless $id;

        my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET "status" = 0 WHERE "id"='.$id );

        return $db_result;
    });


    # для изменения параметра status на 1
    # возвращается true/false
    $app->helper( '_activate_route' => sub {
        my ($self, $id) = @_;
        return unless $id;

        my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET "status" = 1 WHERE "id"='.$id );

        return $db_result;
    });


    # для проверки корректности наследования
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


    # для проверки существования строки с данным id
    # my $true = $self->_id_check_route( 99 );
    # возвращается true/false
    $app->helper( '_id_check_route' => sub {
        my ($self, $id) = @_;
        return unless $id;

        my $db_result = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."routes" WHERE "id"='.$id);
        return $db_result;
    });
}

1;
