package Freee::Helpers::PgGroups;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Groups

    # получение списка групп из базы в виде объекта как в Mock/Groups.pm
    # my $list = $self->_all_groups();
    # возвращает массив хэшей
    $app->helper( '_all_groups' => sub {
        my $self = shift;

        my $list;
        eval{
            $list = $self->pg_dbh->selectall_hashref('SELECT id,label FROM "public"."groups"', 'id');
        };
        warn $@ && return if ($@);

        return $list;
    });

    # читаем одну группу
    # my $row = $self->_get_group( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_group' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT * FROM "public"."groups" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ && return if ($@);

        return $row;
    });

    # добавление группы пользователей
    # my $id = $self->_insert_group({
    #     "id"          => '1',             - id элемента
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "status"      => 0,               - по умолчанию 1
    # });
    # возвращается id записи    
    $app->helper( '_insert_group' => sub {
        my ($self, $data, $push) = @_;

        return unless $data;

        my $id;
        eval {
            if ( $self->pg_dbh->do('INSERT INTO "public"."groups" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
            }
        };
        warn $@ && return if ($@);

        return $id;
    });

    # изменение группы пользователей
    # my $id = $self->_update_group({
    #     "id"          => '1',             - id элемента
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "status"      => 0,               - по умолчанию 1
    # });
    # возвращается true/false
    $app->helper( '_update_group' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $db_result;
        eval {
            $db_result = $self->pg_dbh->do('UPDATE "public"."groups" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};
        };
        warn $@ && return if ($@);

        return $db_result;
    });

    # удаление группы
    # my $true = $self->_delete_group( 99 );
    # возвращается true/false
    $app->helper( '_delete_group' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'DELETE FROM "public"."groups" WHERE "id"='.$id;
        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ && return if ($@);

        return 1;
    });

    # включение/отключение поля status в строке группы
    # my $true = $self->_toggle_setting( <id>, <field>, <val> );
    # <id>    - id записи 
    # <field> - имя поля в таблице
    # <val>   - 1/0
    # возвращается true/false
    $app->helper( '_toggle_group' => sub {
        my ($self, $data) = @_;

        return unless $data;
        return unless ($$data{'id'} || $$data{'value'} || $$data{'fieldname'});

        my $sql ='UPDATE "public"."groups" SET "'.$$data{'fieldname'}.'"='.$$data{'value'}.' WHERE "id"='.$$data{'id'};
        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ && return if ($@);

        return 1;
    });

}

1;
