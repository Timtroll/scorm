package Freee::Helpers::PgSettings;

use strict;
use warnings;
use utf8;

use base 'Mojolicious::Plugin';
use JSON::XS;

use DBD::Pg;
use DBI;
# use experimental 'smartmatch';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    ###################################################################
    # таблица настроек
    ###################################################################

    # получить дерево настроек без листьев
    # my $true = $self->_get_tree();
    $app->helper( '_get_tree' => sub {
        my $self = shift;
        my $no_children = shift;

        my $list;
        if ($no_children) {
            $list = $self->pg_dbh->selectall_arrayref('SELECT id, label, name, parent, 1 as folder FROM "public".settings where id IN (SELECT DISTINCT parent FROM "public".settings) ORDER by id', { Slice=> {} } );
        }
        else {
            $list = $self->pg_dbh->selectall_arrayref('SELECT id, label, name, parent FROM "public".settings ORDER by id', { Slice=> {} } );
        }

        $list = $self->_list_to_tree($list, 'id', 'parent', 'children');

        return $list;
    });

    # читаем данные фолдера
    # my $row = $self->_get_folder( 99 );
    # возвращается объект
    $app->helper( '_get_folder' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $row = $self->pg_dbh->selectrow_hashref('SELECT id, parent, folder, keywords, name, label, opened FROM "public"."settings" WHERE "id"='.$id);

        # десериализуем поля vaue и selected
        if ($row) {
            $$row{'value'} = '' if ($$row{'value'} eq 'null');
            $$row{'selected'} = '' if ($$row{'selected'} eq 'null');
        }

        return $row;
    });

    # сохранить данные фолдера настроек
    # my $true = $self->_save_folder({<data>});
    # <data> - хэш редактируемых полей
    $app->helper( '_save_folder' => sub {
        my ($self, $data) = @_;

        my $fields = join( ', ', map { '"'.$_.'"='.$$data{$_} =~ /^\d+$/ ? $$data{$_} : $self->pg_dbh->quote( $$data{$_} ) } keys %$data );
        my $rv = $self->pg_dbh->do(
            'UPDATE "public"."settings" SET '.$fields.' WHERE "id"='.$self->pg_dbh->quote( $$data{id} ).' RETURNING "id"'
        ) if $$data{id};

        return $rv;
    });

    # удаление фолдера
    # my $true = $self->_delete_folder( 99 );
    # возвращается true/false
    $app->helper( '_delete_folder' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $rv = $self->pg_dbh->do('DELETE FROM "public"."settings" WHERE "id"='.$id);

        return $rv;
    });

    # выбираем листья ветки дерева по id парента
    # my $true = $self->_get_leafs(11);
    $app->helper( '_get_leafs' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $list = $self->pg_dbh->selectall_arrayref( 'SELECT * FROM "public".settings WHERE "parent"='.$id.' ORDER by id', { Slice=> {} } );

        return $list;
    });

    # создание настройки
    # my $id = $self->_insert_setting({
    #     "parent",   - обязательно
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "value",
    #     "type",
    #     "placeholder",
    #     "mask"
    #     "selected",
    # });
    # создание группы настроек
    # my $id = $self->_insert_setting({
    #     "parent",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "readonly",       - не обязательно, по умолчанию 0
    #     "removable" int,  - не обязательно, по умолчанию 1
    # });
    $app->helper( '_insert_setting' => sub {
        my ($self, $data) = @_;

        return unless $data;

        # сериализуем поля vaue и selected
        $$data{'value'} = $$data{'value'} ? $$data{'value'} : '';
        $$data{'selected'} =  $$data{'selected'} ? $$data{'selected'} : '';
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');

        my $sql ='INSERT INTO "public"."settings" ('.
            join( ',', map { '"'.$_.'"' } keys %$data ).
            ') VALUES ('.
            join( ',', map { $$data{$_} =~/^\d+$/ ? $$data{$_} : $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).
            ') RETURNING "id"';
        $self->pg_dbh->do($sql);

        my $id = $self->pg_dbh->last_insert_id(undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' });

        return $id;
    });

    # сохранение настройки
    # my $id = $self->_save_setting({
    #     "id",       - обязательно (должно быть больше 0)
    #     "parent",   - обязательно (должно быть больше 0)
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "value",
    #     "type",
    #     "placeholder",
    #     "mask"
    #     "selected",
    # });
    # сохранение группы настроек
    # my $id = $self->_save_setting({
    #     "id",       - обязательно (должно быть больше 0),
    #     "parent",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "readonly",       - не обязательно, по умолчанию 0
    #     "removable" int,  - не обязательно, по умолчанию 1
    # });
    # возвращается id записи
    $app->helper( '_save_setting' => sub {
        my ($self, $data) = @_;

        return unless $data;

        # сериализуем поля vaue и selected
        $$data{'value'} = '' if ($$data{'value'} eq 'null');
        $$data{'selected'} = '' if ($$data{'selected'} eq 'null');
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');

        my $fields = join( ', ', map {
            if ($$data{$_}) {
                '"'.$_.'"='.$$data{$_} =~ /^\d+$/ ? $$data{$_} : $self->pg_dbh->quote( $$data{$_} );
            }
            else {
                "\"".$_."\"=''";
            }
        } keys %$data );
warn $fields;
        my $rv = $self->pg_dbh->do(
            'UPDATE "public"."settings" SET '.$fields." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\""
        ) if $$data{id};

        return $rv;
    });

    # удаление настройки
    # my $true = $self->_delete_setting( 99 );
    # возвращается true/false
    $app->helper( '_delete_setting' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $rv = $self->pg_dbh->do('DELETE FROM "public"."settings" WHERE "id"='.$id);

        return $rv;
    });

    # читаем одну настройку
    # my $row = $self->_get_setting( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_setting' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $row = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."settings" WHERE "id"='.$id);

        # десериализуем поля vaue и selected
        my $out = [];
        if ($row) {
            $$row{'label'}      = $$row{'label'} ? $$row{'label'} : '';
            $$row{'mask'}       = $$row{'mask'} ? $$row{'mask'} : '';
            $$row{'name'}       = $$row{'name'} ? $$row{'name'} : '';
            $$row{'parent'}     = $$row{'parent'} || 0;
            $$row{'placeholder'} = $$row{'placeholder'} ? $$row{'placeholder'} : '';
            $$row{'readonly'}   = $$row{'readonly'} || 0;
            $$row{'removable'}  = $$row{'removable'} || 0;
            $$row{'required'}   = $$row{'required'} || 0;
            $$row{'type'}       = $$row{'type'} ? $$row{'type'} : '';
            $$row{'value'}      = ($$row{'value'} && $$row{'value'} =~ /^\[/) ? JSON::XS->new->allow_nonref->decode($$row{'value'}) : '';
            $$row{'selected'}   = $$row{'selected'} ? JSON::XS->new->allow_nonref->decode($$row{'selected'}) : [] ;
            $$row{'status'}     = $$row{'status'} || 0;
        }
        
        return $row;
    });

    # очистка дефолтных настроек
    # my $true = $self->_reset_settings();
    $app->helper( '_reset_settings' => sub {
        my $self = shift;

        $self->pg_dbh->do( 'TRUNCATE "public"."settings" RESTART IDENTITY' );
        $self->pg_dbh->do( 'ALTER SEQUENCE settings_id_seq RESTART;' );

        return 1;
    });

    # получение списка настроек из базы в виде объекта как в Mock/Settings.pm
    $app->helper( '_all_settings' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_arrayref('SELECT * FROM "public".settings ORDER by id', { Slice=> {} } );

        $list = $self->_list_to_tree($list, 'id', 'parent', 'children');

        return $list;
    });

}

1;
