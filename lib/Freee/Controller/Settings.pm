package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;

#####################
# Работа с фолдерами

sub proto_folder {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'proto_folder'
        }
    );
}

sub get_folder {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'get_folder'
        }
    );
}

# получить дерево без листьев
sub get_tree {
    my $self = shift;

   # читаем настройки из базы
    my $list = $self->_get_tree();

    foreach my $id (sort {$a <=> $b} keys %$list) {
    }

    $self->render(
        'json'    => {
            'status'  => 'ok',
            'list'    => $list
        }
    );
}

sub save_folder {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'save_folder'
        }
    );
}

sub delete_folder {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'delete_folder'
        }
    );
}

#####################
# Работа с Настройками

# Список настроек из базы в виде объекта как в Mock/Settings.pm
sub get_leafs {
    my $self = shift;

#    # читаем настройки из базы
#    my $list = $self->all_settings();

#     my $set = {};
#     foreach my $id (sort {$a <=> $b} keys %$list) {
#         # формируем данные для таблицы
#         $$list{$id}{'table'} = $self->_table_obj({
#             'settings'  => {},
#             'header'    => [
#                 { "key" => "id", "label" => "id" },
#                 { "key" => "label", "label" => "Название" },
#                 # { "key" => "type", "label" => "Тип поля" },
#                 { "key" => "value", "label" => "Значение" },
#             ],
#             'body'      => $$list{$id}{'table'}
#         });
#         push @{$$set{'settings'}}, $$list{$id};
#     }

#     $$set{'status'} = 'ok';
# print Dumper($set);

#     # показываем все настройки
#     $self->render( json => $set );
#     # $self->render( json => $settings );

use Freee::Mock::GetLeafs;
    $self->render( json => $get_leafs );
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
            'parent'=> 0
        };
        my $id = $self->insert_setting($sub, []);
        push @mess, "Could not add setting Folder '$$folder{'label'}'" unless $id;

        foreach ( @{$$folder{'table'}->{'body'}} ) {
            # указываем родительский id
            $_->{'parent'} = $id;

            # сериализуем поля vaue и selected
            $_->{'value'} = JSON::XS->new->allow_nonref->encode($_->{'value'}) if (ref($_{'value'}) eq 'ARRAY');
            $_->{'selected'} = JSON::XS->new->allow_nonref->encode($_->{'selected'}) if (ref($_{'selected'}) eq 'ARRAY');

            my $newid = $self->insert_setting($_, ['parent']);
            push @mess, "Could not add setting item '$_->{'label'}' in Folder '$$folder{'label'}'" unless $newid;
        }
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

sub proto_leaf {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'proto_leaf'
        }
    );
}

# для создания настройки
# my $id = $self->add({
#     "folder"      => 0,           - это запись настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 1,           - не обязательно, по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
#     "value"       => "",            - строка или json
#     "type"        => "InputNumber", - тип поля из конфига
#     "placeholder" => 'это название',- название для отображения в форме
#     "mask"        => '\d+',         - регулярное выражение
#     "selected"    => "CKEditor",    - значение по-умолчанию для select
#     "required"    => 1              - обязательное поле
# });
# для создания группы настроек
# my $id = $self->add({
#     "folder"      => 1,           - это группа настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 1,           - не обязательно, по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
# });
sub add {
    my ($self, $data) = @_;

    # read params
    my %data;
    $data{'parent'} = $self->param('parent');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');

    # проверка обязательных полей
    my @mess;
    $data{'parent'} = 0 unless $data{'parent'};
    $data{'label'} = '' unless $data{'label'};
    $data{'name'} = '' unless $data{'name'};
    unless (
        (($data{'parent'} == 0) && $data{'label'}) ||
        (($data{'parent'} > 0) && $data{'label'} && $data{'name'})
    ) {
        push @mess, 'Not exists required fields';
    }

    # поля для группы настроек
    $data{'editable'} = $self->param('editable') || 1;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 1;

    # готовим запись настроек, если это не folder
    unless ($self->param('folder')) {
        my @fields = ("value", "type", "placeholder", "mask", "selected", "required");
        foreach (@fields) {
            $data{$_} = $self->param($_);
        }
    }

    my $id = $self->insert_setting( \%data, [] );
    push @mess, "Could not new setting item '$data{'label'}'" unless $id;

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# получение настройки по id
# my $row = $self->edit(2)
sub edit {
    my $self = shift;

    my $id = $self->param('id');

    my $row = $self->get_row( $id );

    my $resp;
    $resp->{'status'} = $row ? 'ok' : 'fail';
    $resp->{'data'} = $row if $row;

    $self->render( 'json' => $resp );
}

# для сохранения настройки
# my $id = $self->save({
#     "folder"      => 0,           - это запись настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 1,           - не обязательно, по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
#     "value"       => "",            - строка или json
#     "type"        => "InputNumber", - тип поля из конфига
#     "placeholder" => 'это название',- название для отображения в форме
#     "mask"        => '\d+',         - регулярное выражение
#     "selected"    => "CKEditor",    - значение по-умолчанию для select
#     "required"    => 1              - обязательное поле
# });
# для сохранения группы настроек
# my $id = $self->save({
#     "folder"      => 1,           - это группа настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 1,           - не обязательно, по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
# });
sub save {
    my ($self) = shift;

    # read params
    my %data;
    $data{'id'} = $self->param('id');
    $data{'parent'} = $self->param('parent');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');

    # проверка обязательных полей
    my @mess;
    $data{'id'} = 0 unless $data{'id'};
    $data{'parent'} = 0 unless $data{'parent'};
    $data{'label'} = '' unless $data{'label'};
    $data{'name'} = '' unless $data{'name'};
    unless (
        (($data{'parent'} == 0) && $data{'id'} && $data{'label'}) ||
        (($data{'parent'} > 0) && $data{'id'} && $data{'label'} && $data{'name'})
    ) {
        push @mess, 'Not exists required fields';
    }

    # поля для группы настроек
    $data{'editable'} = $self->param('editable') || 0;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 0;

    # готовим запись настроек, если это не folder
    unless ($self->param('folder')) {
        my @fields = ("value", "type", "placeholder", "mask", "selected", "required");
        foreach (@fields) {
            $data{$_} = $self->param($_);
        }
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
# my $true = $self->delete( 99 );
sub delete {
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

sub activate {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'activate'
        }
    );
}

sub hide {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'hide'
        }
    );
}

1;
