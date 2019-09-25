package Freee::Helpers::PgSettings;

use strict;
use warnings;
use utf8;

use base 'Mojolicious::Plugin';
use JSON::XS;

use DBD::Pg;
use DBI;
use experimental 'smartmatch';

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

    # очистка дефолтных настроек
    # my $true = $self->reset_setting();
    $app->helper( '_reset_setting' => sub {
        my $self = shift;

        $self->pg_dbh->do( 'TRUNCATE "public"."settings" RESTART IDENTITY' );

        return 1;
    });

    # выбираем листья ветки дерева по id парента
    # my $true = $self->_get_leafs(11);
    $app->helper( '_get_leafs' => sub {
        my ($self, $id) = @_;

        my $list = $self->pg_dbh->selectall_arrayref( 'SELECT * FROM "public".settings WHERE "parent"='.$id.' ORDER by id', { Slice=> {} } );

        return $list;
    });

    # получение списка настроек из базы в виде объекта как в Mock/Settings.pm
    $app->helper( '_all_settings' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_arrayref('SELECT * FROM "public".settings ORDER by id', { Slice=> {} } );

        $list = $self->_list_to_tree($list, 'id', 'parent', 'children');

        return $list;
    });

    # для создания настройки
    # my $id = $self->insert_setting({
    #     "parent",   - обязательно
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "value",
    #     "type",
    #     "placeholder",
    #     "editable",
    #     "mask"
    #     "selected",
    # });
    # для создания группы настроек
    # my $id = $self->insert_setting({
    #     "parent",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "readOnly",       - не обязательно, по умолчанию 0
    #     "editable" int,   - не обязательно, по умолчанию 1
    #     "removable" int,  - не обязательно, по умолчанию 1
    # });
    $app->helper( 'insert_setting' => sub {
        my ($self, $data) = @_;

        return unless $data;

        # сериализуем поля vaue и selected
        $$data{'value'} = '' if ($$data{'value'} eq 'null');
        $$data{'selected'} = '' if ($$data{'selected'} eq 'null');
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');

        $self->pg_dbh->do('INSERT INTO "public"."settings" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"');
        my $id = $self->pg_dbh->last_insert_id(undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' });

        return $id;
    });

    # для сохранения настройки
    # my $id = $self->insert_setting({
    #     "id",       - обязательно (должно быть больше 0)
    #     "parent",   - обязательно (должно быть больше 0)
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "value",
    #     "type",
    #     "placeholder",
    #     "editable",
    #     "mask"
    #     "selected",
    # });
    # для создания группы настроек
    # my $id = $self->insert_setting({
    #     "id",       - обязательно (должно быть больше 0),
    #     "parent",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "readOnly",       - не обязательно, по умолчанию 0
    #     "editable" int,   - не обязательно, по умолчанию 1
    #     "removable" int,  - не обязательно, по умолчанию 1
    # });
    # возвращается id записи
    $app->helper( 'save_setting' => sub {
        my ($self, $data) = @_;

        return unless $data;

        # сериализуем поля vaue и selected
        $$data{'value'} = '' if ($$data{'value'} eq 'null');
        $$data{'selected'} = '' if ($$data{'selected'} eq 'null');
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');

        my $rv = $self->pg_dbh->do('UPDATE "public"."settings" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};

        return $rv;
    });

    # для удаления настройки
    # my $true = $self->delete_setting( 99 );
    # возвращается true/false
    $app->helper( 'delete_setting' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $rv = $self->pg_dbh->do('DELETE FROM "public"."settings" WHERE "id"='.$id);

        return $rv;
    });

    # читаем одну настройку
    # my $row = $self->get_row( 99 );
    # возвращается строка в виде объекта
    $app->helper( 'get_row' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $row = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."settings" WHERE "id"='.$id);

        # десериализуем поля vaue и selected
        $$row{'value'} = '' if ($$row{'value'} eq 'null');
        $$row{'selected'} = '' if ($$row{'selected'} eq 'null');
        $$row{'value'} = JSON::XS->new->allow_nonref->decode($$row{'value'}) if (ref($$row{'value'}) eq 'ARRAY');
        $$row{'selected'} = JSON::XS->new->allow_nonref->decode($$row{'selected'}) if (ref($$row{'selected'}) eq 'ARRAY');
        
        return $row;
    });
}

1;
