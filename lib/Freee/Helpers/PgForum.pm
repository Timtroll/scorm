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
        my ($self, $id) = @_;

        return unless $id;

        my $list;
        eval {
            my $sql = 'SELECT * FROM "public"."forum_themes" WHERE "group_id"='.$id.' ORDER BY date_created DESC';
            $list = $self->pg_dbh->selectall_arrayref( $sql, { Slice => {} } );
        };
        warn $@ if $@;
        return if $@;

        return $list;
    });

    # получение списка сообщений из базы в массив хэшей
    $app->helper( '_list_messages' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $list;
        eval {
            my $sql = 'SELECT * FROM "public"."forum_messages" WHERE "theme_id"='.$id.' ORDER BY date_created DESC';
            $list = $self->pg_dbh->selectall_arrayref( $sql, { Slice => {} } );
        };
        warn $@ if $@;
        return if $@;

        return $list;
    });

    # получение списка групп из базы в массив хэшей
    $app->helper( '_list_groups' => sub {
        my ($self) = @_;

        my $list;
        eval {
            my $sql = 'SELECT * FROM "public"."forum_groups" ORDER BY date_created DESC';
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

        my $sql = 'SELECT * FROM "public"."forum_themes" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

        return $row;
    });

    # читаем одну группу
    # my $row = $self->_get_theme( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_group' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT * FROM "public"."forum_groups" WHERE "id"='.$id;
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
            $db_result = $self->pg_dbh->do('UPDATE "public"."forum_themes" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};
        };
        warn $@ if $@;
        return if $@;

        return $db_result;
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
    $app->helper( '_update_group' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $db_result;
        eval {
            $db_result = $self->pg_dbh->do('UPDATE "public"."forum_groups" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};
        };
        warn $@ if $@;
        return if $@;

        return $db_result;
    });
    

    # добавление роута
    # my $id = $self->_insert_group({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/theme":1}',  - строка или json для записи или '' - для фолдера
    #     "status"      => 0                - активность элемента, по умолчанию 1
    # });
    # возвращается id роута
    $app->helper( '_insert_group' => sub {
        my ($self, $data) = @_;
        return unless $data;

        my $id;
        eval{
            if ( $self->pg_dbh->do('INSERT INTO "public"."forum_groups" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'forum_groups', undef, { sequence => 'forum_groups_id_seq' } );
            };
        };
        warn $@ if $@;
        return if $@;

        return $id;
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
            if ( $self->pg_dbh->do('INSERT INTO "public"."forum_themes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'forum_themes', undef, { sequence => 'forum_themes_id_seq' } );
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

    # обновление сообщения
    # my $id = $self->_update_message({
    # "theme id"
    # "user id"
    # "anounce"
    # "date_created"
    # "msg"
    # "rate"
    # "status"
    # });
    # возвращается true/false
    $app->helper( '_update_message' => sub {
        my ($self, $data) = @_;

        return unless $$data{id};

        my $result;
        my $sql = 'UPDATE "public"."forum_messages" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"";
        eval {
            $result = $self->pg_dbh->do( $sql ) + 0;
        };

        warn $@ if $@;
        return if $@;

        return $result;
    });

    # удаление сообщения
    # my $true = $self->_delete_message( 99 );
    # возвращается true/false
    $app->helper( '_delete_message' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $result;
        my $sql = 'DELETE FROM "public"."forum_messages" WHERE "id"='.$id;
        eval {
            $result = $self->pg_dbh->do( $sql ) + 0;
        };

        warn $@ if $@;
        return if $@;

        return $result;
    });

    # удаление темы
    # my $true = $self->_delete_theme( 99 );
    # возвращается true/false
    $app->helper( '_delete_theme' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $result;
        my $sql = 'DELETE FROM "public"."forum_themes" WHERE "id"='.$id;
        eval {
            $result = $self->pg_dbh->do( $sql ) + 0;
        };

        warn $@ if $@;
        return if $@;

        return $result;
    });

    # удаление группы
    # my $true = $self->_delete_theme( 99 );
    # возвращается true/false
    $app->helper( '_delete_group' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $result;
        my $sql = 'DELETE FROM "public"."forum_groups" WHERE "id"='.$id;
        eval {
            $result = $self->pg_dbh->do( $sql ) + 0;
        };

        warn $@ if $@;
        return if $@;

        return $result;
    });
    

    # читаем одно сообщение
    # my $row = $self->_get_message( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_message' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT id, msg, status, theme_id FROM "public"."forum_messages" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

        return $row;
    });

    # получение значения поля status по id
    # my $true = folder_check( <id> );
    # возвращается 1/0
    $app->helper('_status_check' => sub {
        # my $id = shift;
        my ($self, $id) = @_;

        return unless $id;

        my $result;
        my $sql = 'SELECT status FROM "public"."forum_messages" WHERE "id"='.$id;
        eval {
            $result = $self->pg_dbh->selectrow_array($sql);
        };
        warn $@ if $@;
        
        return $result;
    });
}

1;