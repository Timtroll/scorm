package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;

# Список настроек из базы в виде объекта как в Mock/Settings.pm
sub get_leafs {
    my $self = shift;

#    # читаем настройки из базы
#    my $list = $self->all_settings();

#     my $settings = {};
#     foreach my $id (sort {$a <=> $b} keys %$list) {
#         # формируем данные для таблицы
#         $$list{$id}{'table'} = $self->table_obj({
#             'settings'  => {},
#             'header'    => [
#                 { "key" => "id", "label" => "id" },
#                 { "key" => "label", "label" => "Название" },
#                 # { "key" => "type", "label" => "Тип поля" },
#                 { "key" => "value", "label" => "Значение" },
#             ],
#             'body'      => $$list{$id}{'table'}
#         });
#         push @{$$settings{'settings'}}, $$list{$id};
#     }

#     $$settings{'status'} = 'ok';
# print Dumper($settings);

    # показываем все настройки
    $self->render( json => $settings );
}

sub set_tab_list {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'set_tab_list'
        }
    );
}

sub set_addtab {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'set_addtab'
        }
    );
}

sub set_savetab {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'set_savetab'
        }
    );
}

sub set_deletetab {
    my $self = shift;

    $self->render(
        'json'    => {
            'status'        => 'ok',
            'controller'    => 'Settings',
            'route'         => 'set_deletetab'
        }
    );
}

# получение настройки по id
# my $row = $self->set_get_one(2)
sub set_get_one {
    my $self = shift;

    my $id = $self->param('id');

    my $row = $self->get_row( $id );

    my $resp;
    $resp->{'status'} = $row ? 'ok' : 'fail';
    $resp->{'data'} = $row if $row;

    $self->render( 'json' => $resp );
}

# для создания настройки
# my $id = $self->insert_setting({
#     "folder"      => 0,           - это запись настроек
#     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
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
# my $id = $self->insert_setting({
#     "folder"      => 1,           - это группа настроек
#     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 1,           - не обязательно, по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
# });
sub set_add {
    my ($self, $data) = @_;

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
            # указываем родительский id
            $_->{'lib_id'} = $id;

            # сериализуем поля vaue и selected
            $_->{'value'} = JSON::XS->new->allow_nonref->encode($_->{'value'}) if (ref($_{'value'}) eq 'ARRAY');
            $_->{'selected'} = JSON::XS->new->allow_nonref->encode($_->{'selected'}) if (ref($_{'selected'}) eq 'ARRAY');

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
# my $id = $self->insert_setting({
#     "folder"      => 0,           - это запись настроек
#     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
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
# my $id = $self->insert_setting({
#     "folder"      => 1,           - это группа настроек
#     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 1,           - не обязательно, по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
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
print Dumper(\%data);
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
