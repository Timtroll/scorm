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
    $app->helper( '_routes_list' => sub {
        my ($self, $parent) = @_;

        my $list;
        eval {
            # $list = $self->pg_dbh->selectall_hashref('SELECT * FROM "public"."routes" WHERE "parent" = '.$parent, 'id');
            my $sql = 'SELECT * FROM "public"."routes" WHERE "parent" = '.$parent;
            $list = $self->pg_dbh->selectall_arrayref( $sql, { Slice=> {} } );
        };
        warn $@ if $@;
        return if $@;

        return $list;
    });

    # читаем один роут
    # my $row = $self->_get_route( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_route' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT * FROM "public"."routes" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

        return $row;
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
        warn $@ if $@;
        return if $@;

        return $db_result;
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
            };
        };
        warn $@ if $@;
        return if $@;

        return $id;
    });


    # включение/отключение поля status в строке группы
    # my $true = $self->_toggle_route( <id>, <field>, <val> );
    # <id>    - id записи 
    # <field> - имя поля в таблице
    # <val>   - 1/0
    # возвращается true/false
    $app->helper( '_toggle_route' => sub {
        my ($self, $data) = @_;

        return unless $data;
        return unless ($$data{'id'} || $$data{'value'} || $$data{'fieldname'});

        my $sql ='UPDATE "public"."routes" SET "'.$$data{'fieldname'}.'"='.$$data{'value'}.' WHERE "id"='.$$data{'id'};
        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ if $@;
        return if $@;

        return 1;
    });

}

1;
