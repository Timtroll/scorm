package Freee::Helpers::PgForum;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Forum

    # получение списка тем из базы в массив хэшей
    $app->helper( '_list_themes' => sub {
        my ($self) = @_;

        my $list;
        eval {
            my $sql = 'SELECT * FROM "public"."forum_themes"';
            $list = $self->pg_dbh->selectall_arrayref( $sql, { Slice => {} } );
        };
        warn $@ if $@;
        return if $@;

        return $list;
    });

    # читаем один роут
    # my $row = $self->_get_theme( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_theme' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT * FROM "public"."forum" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

        return $row;
    });

    # обновление роута
    # my $id = $self->_update_theme({
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
    $app->helper( '_update_theme' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $db_result;
        eval {
            $db_result = $self->pg_dbh->do('UPDATE "public"."forum" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};
        };
        warn $@ if $@;
        return if $@;

        return $db_result;
    });

    # добавление роута
    # my $id = $self->_insert_theme({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/theme":1}',  - строка или json для записи или '' - для фолдера
    #     "status"      => 0                - активность элемента, по умолчанию 1
    # });
    # возвращается id роута
    $app->helper( '_insert_theme' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $id;
        eval{
            if ( $self->pg_dbh->do('INSERT INTO "public"."forum" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'forum', undef, { sequence => 'forum_id_seq' } );
            };
        };
        warn $@ if $@;
        return if $@;

        return $id;
    });

    # новое сообщение форума
    # my $id = $self->_insert_message();
    # "theme id"
    # "user id"
    # "anounce"
    # "date_created"
    # "msg"
    # "rate"
    # "status"
    $app->helper( '_insert_message' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $id;
        eval{
            if ( $self->pg_dbh->do('INSERT INTO "public"."forum_messages" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'forum_messages', undef, { sequence => 'forum_messages_id_seq' } );
            };
        };
        warn $@ if $@;
        return if $@;

        return $id;
    });
}

1;
