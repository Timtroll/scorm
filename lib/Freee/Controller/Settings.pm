package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;

#####################
# Работа с фолдерами

# получить данные фолдера
sub get_folder {
    my $self = shift;


    my $id = $self->param('id');

    # проверка обязательных полей
    my @mess;
    $id = 0 unless $id =~ /\d+/;
    push @mess, "Id wrong or empty" unless $id;

    my $data;
    unless (@mess) {
        $data = $self->_get_folder( $id );
        push @mess, "Could not get '$id'" unless $data;
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

# получить дерево без листьев
sub get_tree {
    my $self = shift;

    my $list = $self->_get_tree(1);

    $self->render( 'json' => { 'status' => 'ok', 'list' => $list });
}

sub save_folder {
    my $self = shift;

# проверка обязательных полей
# ?????????
    my %params = {
        'id'          => $self->param('id'),
        'name'        => $self->param('name') || '',
        'placeholder' => $self->param('placeholder') || '',
        'label'       => $self->param('label') || '',
        'parent'      => $self->param('parent') || 0,
        'value'       => $self->param('value') || '',
        'type'        => $self->param('type') || 'InputText',
        'mask'        => $self->param('mask') || '',
        'selected'    => $self->param('selected'),

        'required'    => $self->param('required') || 1,
        'readonly'    => $self->param('readonly') || 0,
        'removable'   => $self->param('removable') || 1,
        'status'      => $self->param('status') || 1
    };

    # выбираем листья ветки дерева
    my $folder = $self->_save_folder(\%params);

    $self->render( 'json' => { 'status' => 'ok' } );
}

sub delete_folder {
    my $self = shift;

    my $id = $self->param('id');

    # проверка обязательных полей
    my @mess;
    $id = 0 unless $id =~ /\d+/;
    push @mess, "Id wrong or empty" unless $id;

    unless (@mess) {
        $id = $self->_delete_folder( $id );
        push @mess, "Could not deleted '$id'" unless $id;
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

#####################
# Работа с Настройками

# выбираем листья ветки дерева
sub get_leafs {
    my $self = shift;

    my $id = $self->param('id');

    # выбираем листья ветки дерева
    my $list = $self->_get_leafs($id);

    # данные для таблицы
    my $table = {
        "settings" => {
            "massEdit" => 1,    # групповое редактировани
            "sort" => {              # сотрировка по
                "name"    => "id",
                "order"   => "asc"
            },
            "page" => {
              "current_page"    => 1,
              "per_page"        => 100
              "total"           => scalar(@{$list->{'body'}})
            },
        },
        "body" => $list
    };

    $self->render( 'json' => { 'status' => 'ok', 'list' => $table });
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
        my $id = $self->_insert_setting($sub, []);
        push @mess, "Could not add setting Folder '$$folder{'label'}'" unless $id;

        foreach ( @{$$folder{'table'}->{'body'}} ) {
            # указываем родительский id
            $_->{'parent'} = $id;

            # сериализуем поля vaue и selected
            $_->{'value'} = JSON::XS->new->allow_nonref->encode($_->{'value'}) if (ref($_{'value'}) eq 'ARRAY');
            $_->{'selected'} = JSON::XS->new->allow_nonref->encode($_->{'selected'}) if (ref($_{'selected'}) eq 'ARRAY');

            my $newid = $self->_insert_setting($_, ['parent']);
            push @mess, "Could not add setting item '$_->{'label'}' in Folder '$$folder{'label'}'" unless $newid;
        }
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

# создание настройки
# my $id = $self->add({
#     "folder"      => 0,           - это запись настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
#     "value"       => "",            - строка или json
#     "type"        => "InputNumber", - тип поля из конфига
#     "placeholder" => 'это название',- название для отображения в форме
#     "mask"        => '\d+',         - регулярное выражение
#     "selected"    => "CKEditor",    - значение по-умолчанию для select
#     "required"    => 1              - обязательное поле
# });
# создание группы настроек
# my $id = $self->add({
#     "folder"      => 1,           - это группа настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
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
    $data{'readonly'} = $self->param('readonly') || 0;
    $data{'removable'} = $self->param('removable') || 1;

    # готовим запись настроек, если это не folder
    unless ($self->param('folder')) {
        my @fields = ("value", "type", "placeholder", "mask", "selected", "required");
        foreach (@fields) {
            $data{$_} = $self->param($_);
        }
    }

    my $id = $self->_insert_setting( \%data, [] );
    push @mess, "Could not new setting item '$data{'label'}'" unless $id;

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# получение настройки по id
# my $row = $self->edit(2)
sub edit {
    my $self = shift;

    my $id = $self->param('id');

    # проверка обязательных полей
    my @mess;
    $id = 0 unless $id =~ /\d+/;
    push @mess, "Id wrong or empty" unless $id;

    my $data;
    unless (@mess) {
        $data = $self->_get_setting( $id );
        push @mess, "Could not get '$id'" unless $data;
    }

    my $resp;
    $resp->{'type'} = 'settings';
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = $data ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

# сохранение настройки
# my $id = $self->save({
#     "folder"      => 0,           - это запись настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 1,           - не обязательно, по умолчанию 1
#     "value"       => "",            - строка или json
#     "type"        => "InputNumber", - тип поля из конфига
#     "placeholder" => 'это название',- название для отображения в форме
#     "mask"        => '\d+',         - регулярное выражение
#     "selected"    => "CKEditor",    - значение по-умолчанию для select
#     "required"    => 1              - обязательное поле
# });
# сохранение группы настроек
# my $id = $self->save({
#     "folder"      => 1,           - это группа настроек
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
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
    $data{'readonly'} = $self->param('readonly') || 0;
    $data{'removable'} = $self->param('removable') || 0;

    # готовим запись настроек, если это не folder
    unless ($self->param('folder')) {
        my @fields = ("value", "type", "placeholder", "mask", "selected", "required");
        foreach (@fields) {
            $data{$_} = $self->param($_);
        }
    }

    my $id = $self->_save_setting( \%data, [] );
    push @mess, "Could not update setting item '$data{'id'}: $data{'label'}'" unless $id;

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# удаление настройки
# my $true = $self->delete( 99 );
sub delete {
    my $self = shift;

    my $id = $self->param('id');

    # проверка обязательных полей
    my @mess;
    $id = 0 unless $id =~ /\d+/;
    push @mess, "Id wrong or empty" unless $id;

    unless (@mess) {
        $id = $self->_delete_setting( $id );
        push @mess, "Could not deleted '$id'" unless $id;
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
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

sub inputs {
    my $self = shift;

    $self->render( 'json' => $self->_input_components() );
}

1;
