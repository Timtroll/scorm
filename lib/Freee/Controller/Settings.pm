package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::File;

use Freee::Mock::Settings;
use Data::Dumper;

# Список настроек из базы в виде объекта как в Mock/Settings.pm
sub index {
    my $self = shift;

    # читаем настройки из базы
    my $list = $self->all_settings();

    my $settings = {};
    foreach my $id (sort {$a <=> $b} keys %$list) {
        # формируем данные для таблицы
        $$list{$id}{'table'} = $self->table_obj({
            'settings'  => {},
            'header'    => [
                { "key" => "name", "label" => "Название" },
                { "key" => "type", "label" => "Тип" },
            ],
            'body'      => $$list{$id}{'table'}
        });
        push @{$$settings{'settings'}}, $$list{$id};
    }

    # показываем все настройки
    $self->render( json => $settings );
}

sub set_tab_list {
    my $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_tab_list'
        }
    );
}

sub set_addtab {
    my $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_addtab'
        }
    );
}

sub set_savetab {
    my $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_savetab'
        }
    );
}

sub set_deletetab {
    my $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_deletetab'
        }
    );
}

# для создания настройки
# my $id = $self->insert_setting({
#     "lib_id",   - обязательно (добно быть больше 0)
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
#     "name",     - обязательно
#     "readOnly",       - не обязательно, по умолчанию 0
#     "editable" int,   - не обязательно, по умолчанию 1
#     "removable" int,  - не обязательно, по умолчанию 1
#     "massEdit" int    - не обязательно, по умолчанию 0
# });
sub set_add {
    my ($self) = shift;

    # read params
    my %data;
    $data{'lib_id'} = $self->param('lib_id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');

    # проверка обязательных полей
    my @mess;
    $data{'lib_id'} = 0 unless $data{'lib_id'};
    $data{'label'} = '' unless $data{'label'};
    $data{'name'} = '' unless $data{'name'};
    unless (
        (($data{'lib_id'} == 0) && $data{'label'}) ||
        (($data{'lib_id'} > 0) && $data{'label'} && $data{'name'})
    ) {
        push @mess, 'Not exists required fields';
    }

    my $id = $self->insert_setting( \%data, [] );
    push @mess, "Could not new setting item '$data{'label'}'" unless $id;

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# загрузка данных в таблицу настроек из /Mock/Settings.pm
sub set_load_default {
    my ($self) = shift;

    # очистка таблицы и сброс счетчика
    $self->reset_setting();

    my @mess;
    foreach my $folder ( @{$settings->{'settings'}} ) {
        my $sub = {
            'label' => $$folder{'label'},
            'name'  => $$folder{'label'},
            'lib_id'=> 0
        };
        my $id = $self->insert_setting($sub, []);
        push @mess, "Could not add setting Folder '$$folder{'label'}'" unless $id;

        foreach ( @{$$folder{'table'}->{'body'}} ) {
            $_->{'lib_id'} = $id;
            my $newid = $self->insert_setting($_, ['lib_id']);
            push @mess, "Could not add setting item '$_->{'label'}' in Folder '$$folder{'label'}'" unless $newid;
        }
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

# для сохранения настройки
# my $ = $self->insert_setting({
#     "id",       - обязательно (добно быть больше 0)
#     "lib_id",   - обязательно (добно быть больше 0)
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
#     "id",       - обязательно (добно быть больше 0),
#     "lib_id",   - обязательно (если корень - 0, или owner id),
#     "label",    - обязательно
#     "name",     - обязательно
#     "readOnly",       - не обязательно, по умолчанию 0
#     "editable" int,   - не обязательно, по умолчанию 1
#     "removable" int,  - не обязательно, по умолчанию 1
#     "massEdit" int    - не обязательно, по умолчанию 0
# });
sub set_save {
    my ($self) = shift;

    # read params
    my %data;
    $data{'id'} = $self->param('id');
    $data{'lib_id'} = $self->param('lib_id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');

    # проверка обязательных полей
    my @mess;
    $data{'id'} = 0 unless $data{'id'};
    $data{'lib_id'} = 0 unless $data{'lib_id'};
    $data{'label'} = '' unless $data{'label'};
    $data{'name'} = '' unless $data{'name'};
    unless (
        (($data{'lib_id'} == 0) && $data{'id'} && $data{'label'}) ||
        (($data{'lib_id'} > 0) && $data{'id'} && $data{'label'} && $data{'name'})
    ) {
        push @mess, 'Not exists required fields';
    }

    my $id = $self->save_setting( \%data, [] );
    push @mess, "Could not update setting item '$data{'label'}'" unless $id;

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# для удаления настройки
# my $true = $self->delete_setting( 99 );
sub set_delete {
    my $self = shift;

    # read params
    my $id = $self->param('id');

    # проверка обязательных полей
    my @mess;
    $id = 0 unless $id =~ /\d+/;
    push @mess, "Could not id for deleting" unless $id;

    $id = $self->delete_setting( $id );
    push @mess, "Could not deleted '$id'" unless $id;

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

1;