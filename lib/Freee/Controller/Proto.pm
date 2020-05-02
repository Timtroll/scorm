package Freee::Controller::Proto;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use Encode;

# use Freee::Mock::Settings;
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    # { 'category' => 'settings', 'type' => 'folder', 'action' => 'add' }
    # { 'category' => 'settings', 'type' => 'leaf',   'action' => 'add' }
    # { 'category' => 'groups',   'type' => 'folder', 'action' => 'add' }
    # { 'category' => 'groups',   'type' => 'leaf',   'action' => 'add' }
    # { 'category' => 'user',     'type' => 'leaf',   'action' => 'add' }
}

# прототип настройки
# my $id = $self->proto_leaf();
# "parent" => 1, - обязательно (должно быть натуральным числом)
sub proto_leaf {
    my $self = shift;

    # read params
    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            # прототип настройки
            $data = {
                "folder" => 0,
                "parent" => $data->{'parent'} * 1,
                "tabs" => [
                    {
                        "label" => 'Основное',
                        "fields" => {
                            "name"          => '',
                            "placeholder"   => '',
                            "readonly"      => 0,
                            "required"      => 0,
                            "status"        => 1
                        }
                    },
                    {
                        "label" => 'Дополнительные поля',
                        "fields" => {
                            "label"       => '',
                            "mask"        => '',
                            "selected"    => [],
                            "type"        => 'InputText',
                            "value"       => ''
                        }
                    }
                ]
            };
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub proto_folder {
    my $self = shift;

    # read params
    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            # прототип настройки
            $data = {
                "folder"  => 0,
                "parent"  => $data->{'parent'} * 1,
                "name"    => '',
                "label"   => '',
                "status"  => 1
            };
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub proto_user {
    my $self = shift;

    # read params
    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            # прототип настройки
            $data = {
                'tabs' => [ # Вкладки 
                    {
                        'label'     => 'Основные',
                        'fields'    => {
                            'surname'       => '', # Фамилия
                            'name'          => '', # Имя
                            'patronymic'    => '', # Отчество
                            'place'         => '', # город
                            'country'       => '', # страна
                            'timezone'      => '', # часовой пояс
                            'birthday'      => '', # дата рождения (в секундах)
                            'status'        => '', # активный / не активный пользователь
                            'password'      => '', # пароль
                            'newpassword'   => '', # пароль
                            'avatar'        => '',
                            'type'          => ''                        # тип
                        }
                    },
                    {
                        'label' => 'Контакты',
                        'fields' => {
                            'email'           => '',           # email пользователя
                            'emailconfirmed'  => '',  # email подтвержден
                            'phone'           => '',           # номер телефона
                            'phoneconfirmed'  => '',  # телефон подтвержден
                        }
                    },
                    {
                        "label" => "Группы",
                        "fields" => {
                            "groups" => [],  # список ID групп
                        }
                    }
                ]
            };
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}


1;
