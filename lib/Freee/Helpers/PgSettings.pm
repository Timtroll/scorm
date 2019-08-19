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

    # очистка дефолтных настроек
    # my $true = $self->reset_setting();
    $app->helper( 'reset_setting' => sub {
        my $self = shift;

        $self->pg_dbh->do( 'TRUNCATE "public"."settings" RESTART IDENTITY' );

        return 1;
    });

    # получение списка настроек из базы в виде объекта как в Mock/Settings.pm
    # my $settings = $self->all_settings();
    $app->helper( 'all_settings' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT * FROM "public"."settings"', 'id');

        # запоминаем корневые элементы
        my $out = {};
        foreach my $parent (sort {$a <=> $b} keys %$list) {
            if ($$list{$parent}{'lib_id'} == 0) {
                # запоминаем корневые элементы и удаляем их
                $$out{$parent} = {
                    "label"     => $$list{$parent}{'label'},
                    "id"        => $$list{$parent}{'id'},
                    "component" => '',
                    "opened"    => 0,
                    "keywords"  => '',
                    "children"  => [],
                    "table"     => []
                };

                delete $$list{$parent};
            }
        }

        foreach my $id (sort {$a <=> $b} keys %$list) {
            next if $id == $$list{$id}{'lib_id'};

            my ($lst, $keys) = &children( $$list{$id}{'lib_id'}, $list );

            if ( $$out{ $$list{$id}{'lib_id'} } ) {
                $$out{ $$list{$id}{'lib_id'} }{'table'} = $lst;

                my %keys = map {$_, 1} split(' ', $keys);
                $$out{ $$list{$id}{'lib_id'} }{'keywords'} = join(' ', keys %keys);
            }
        }

        return $out;
    });

    # слежубная, для поиска наследников
    sub children {
        my ($parent, $hash) = @_;

        my @out = ();
        my $keys = '';
        foreach my $id (sort {$a <=> $b} keys %$hash ) {
            if ($$hash{$id}{'lib_id'} == $parent) {
                my %keys = map {$_, 1} split(' ', $$hash{$id}{'label'});
                $$hash{$id}{'keywords'} = join(' ', keys %keys);
                $keys .= "$$hash{$id}{'keywords'} ";

                # десериализуем поля vaue и selected
                foreach my $val ('value', 'selected') {
                    if ($$hash{$id}{$val} =~ s/^\"//) {
                        $$hash{$id}{$val} =~ s/\\\"/\"/g;
                        $$hash{$id}{$val} =~ s/\"$//;
                    }
                    if ($$hash{$id}{$val} =~ /^\[/) {
                        $$hash{$id}{$val} = JSON::XS->new->allow_nonref->decode($$hash{$id}{$val});
                    }
                }
                push @out, $$hash{$id};
            }
        }
        $keys =~ s/\s+/ /g;

        return \@out, $keys;
    }

    # для создания настройки
    # my $id = $self->insert_setting({
    #     "lib_id",   - обязательно
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
    #     "lib_id",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "readOnly",       - не обязательно, по умолчанию 0
    #     "editable" int,   - не обязательно, по умолчанию 1
    #     "removable" int,  - не обязательно, по умолчанию 1
    # });
    $app->helper( 'insert_setting' => sub {
        my ($self, $data) = @_;

        return unless $data;

        # сериализуем поля vaue и selected
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');

        $self->pg_dbh->do('INSERT INTO "public"."settings" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"');
        my $id = $self->pg_dbh->last_insert_id(undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' });

        return $id;
    });

    # для сохранения настройки
    # my $id = $self->insert_setting({
    #     "id",       - обязательно (должно быть больше 0)
    #     "lib_id",   - обязательно (должно быть больше 0)
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
    #     "lib_id",   - обязательно (если корень - 0, или owner id),
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
# print Dumper($row);
if ($$row{'value'} eq 'null') {
        $$row{'value'} = JSON::XS->new->allow_nonref->decode($$row{'value'});
        $$row{'selected'} = JSON::XS->new->allow_nonref->decode($$row{'selected'});
}
        return $row;
    });

}

1;
