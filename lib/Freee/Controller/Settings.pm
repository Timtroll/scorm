package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
# use Mojo::JSON qw(decode_json encode_json);
use JSON::XS;
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;
use common;

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

    my ($id, %data, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

        unless (@mess) {
            # проверка записываемых данных
            my $data = $self->_check_fields();
            push @mess, "Not correct folder item data '$$data{'id'}'" unless $data;
            # устанавляваем обязательные поля для фолдера
            $$data{'placeholder'} = '';
            $$data{'type'} = '';
            $$data{'mask'} = '';
            $$data{'value'} = '';
            $$data{'selected'} = '';
            $$data{'required'} = 0;
            $$data{'readonly'} = 0;
            $$data{'status'} = $self->param('status') // 0;

            $id = $self->_save_folder( $data, [] ) unless @mess;
            push @mess, "Could not save folder item '$$data{'id'}'" unless $id;
        }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# создание группы настроек
# my $id = $self->add({
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "folder"      => 1,           - это группа настроек
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
# });
sub add_folder {
    my ($self, $data) = @_;

    my ($id, %data, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка записываемых данных
        my $data = $self->_check_fields();
        push @mess, "Not correct folder item data '$$data{'id'}'" unless $data;
        # устанавляваем обязательные поля для фолдера
        $$data{'placeholder'} = '';
        $$data{'type'} = '';
        $$data{'mask'} = '';
        $$data{'value'} = '';
        $$data{'selected'} = '';
        $$data{'required'} = 0;
        $$data{'readonly'} = 0;
        $$data{'status'} = 1;

        $id = $self->_insert_folder( $data, [] ) unless @mess;
        push @mess, "Could not create new folder item '$$data{'id'}'" unless $id;
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
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
            "sort" => {         # сотрировка по
                "name"    => "id",
                "order"   => "asc"
            },
            "page" => {
              "current_page"    => 1,
              "per_page"        => 100,
              # "total"           => scalar(@{$list->{'body'}})
            }
        },
        "body" => $list
    };

    $self->render( 'json' => { 'status' => 'ok', 'list' => $table });
}

# загрузка данных в таблицу настроек из /Mock/Settings.pm
sub load_default {
    my $self = shift;

    # очистка таблицы и сброс счетчика
    $self->_reset_settings();

    my @mess;
    foreach my $folder ( @{$settings->{'settings'}} ) {
        my $sub = {
            "name"          => $$folder{'name'},
            "placeholder"   => $$folder{'placeholder'} || '',
            "label"         => $$folder{'label'},
            "mask"          => $$folder{'mask'} || '',
            "type"          => $$folder{'type'} || '',
            "value"         => $$folder{'value'} || '',
            "selected"      => $$folder{'selected'} || '',
            "required"      => $$folder{'required'} || 0,
            "readonly"      => 0,
            "status"        => 1,
            "parent"        => 0
        };
        my $id = $self->_insert_setting($sub, []);
        push @mess, "Could not add setting Folder '$$folder{'label'}'" unless $id;

        if (@{$$folder{'children'}}) {
            foreach my $children ( @{$$folder{'children'}} ) {
                $sub = {
                    "name"          => $$children{'name'},
                    "placeholder"   => $$children{'placeholder'} || '',
                    "label"         => $$children{'label'},
                    "mask"          => $$children{'mask'} || '',
                    "type"          => $$children{'type'} || '',
                    "value"         => ref( $$children{'value'} ) eq 'ARRAY' ? JSON::XS->new->allow_nonref->encode( $$children{'value'} ) : '',
                    "selected"      => ref( $$children{'selected'} ) eq 'ARRAY' ? JSON::XS->new->allow_nonref->encode( $$children{'selected'} ) : '[]',
                    "required"      => $$children{'required'} || 0,
                    "readonly"      => 0,
                    "status"        => 1,
                    "parent"        => $id  # указываем родительский id
                };

                my $chldid = $self->_insert_setting($sub, []);
                push @mess, "Could not add setting item '$$children{'label'}' in Folder '$$children{'label'}'" unless $chldid;
            }
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
#     "value"       => "",            - строка или json
#     "type"        => "InputNumber", - тип поля из конфига
#     "placeholder" => 'это название',- название для отображения в форме
#     "mask"        => '\d+',         - регулярное выражение
#     "selected"    => "CKEditor",    - значение по-умолчанию для select
#     "required"    => 1              - обязательное поле
# });
sub add {
    my ($self, $data) = @_;

    # read params
    my ($id, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка записываемых данных
        my $data = $self->_check_fields();
        push @mess, "Not correct setting item data '$$data{'id'}'" unless $data;

        $id = $self->_insert_setting( $data, [] ) unless @mess;
        push @mess, "Could not create new setting item '$$data{'id'}'" unless $id;
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# получение настройки по id
# my $row = $self->edit(2)
sub edit {
    my $self = shift;

    my ($id, $data, @mess, $resp);
    unless ( $id = $self->param('id') ) {
        push @mess, "id is empty or 0";
    }
    else {
        # проверка обязательных полей
        $id = 0 unless $id =~ /\d+/;
        push @mess, "Id is wrong" unless $id;

        unless (@mess) {
            $data = $self->_get_setting( $id );
            push @mess, "Could not get '$id'" unless $data;
        }
    }

    $resp->{'type'} = 'settings';
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
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
#     "value"       => "",            - строка или json
#     "type"        => "InputNumber", - тип поля из конфига
#     "placeholder" => 'это название',- название для отображения в форме
#     "mask"        => '\d+',         - регулярное выражение
#     "selected"    => "CKEditor",    - значение по-умолчанию для select
#     "required"    => 1              - обязательное поле
# });
sub save {
    my $self = shift;

    # read params
    my ($id, @mess, $data);

    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};
    unless (@mess) {
        # проверка записываемых данных
        my $data = $self->_check_fields();
        push @mess, "Not correct setting item data '$$data{'id'}'" unless $data;

        $id = $self->_save_setting( $data, [] ) unless @mess;
        push @mess, "Could not update setting item '$$data{'id'}'" unless $id;
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok' ;
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# удаление настройки
# my $true = $self->delete( 99 );
sub delete {
    my $self = shift;

    my ($id, $resp, @mess);
    unless ( $id = $self->param('id') ) {
        push @mess, "id is empty or 0";
    }
    else {
        # проверка обязательных полей
        $id = 0 unless $id =~ /\d+/;
        push @mess, "Id wrong or empty" unless $id;

        unless (@mess) {
            $id = $self->_delete_setting( $id );
            push @mess, "Could not deleted '$id'" unless $id;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

sub activate {
    my $self = shift;

    my ($id, $resp, @mess);
    unless ( $id = $self->param('id') ) {
        push @mess, "id is empty or 0";
    }
    else {
        # проверка обязательных полей
        $id = 0 unless $id =~ /\d+/;
        push @mess, "Id wrong or empty" unless $id;

        unless (@mess) {
            $id = $self->_delete_setting( $id );
            push @mess, "Could not deleted '$id'" unless $id;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
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
