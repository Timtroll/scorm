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

# роут прототип настройки (Settings)
# $self->proto_leaf();
# "parent" => 1, - обязательно (должно быть натуральным числом) ???????????
sub proto_leaf {
    my $self = shift;

    # read params
    my ($id, $data, $resp );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # # проверка данных
        $data = $self->_check_fields();

        unless ( @! ) {
            # прототип настройки
            $data = {
                "folder" => 0,
                "parent" => $data->{'parent'} * 1,
                "tabs" => [
                    {
                        "label" => 'Основное',
                        "fields" => [
                            { "name"          => '' },
                            { "placeholder"   => '' },
                            { "readonly"      => 0 },
                            { "required"      => 0 },
                            { "status"        => 1 }
                        ]
                    },
                    {
                        "label" => 'Дополнительные поля',
                        "fields" => [
                            { "label"       => '' },
                            { "mask"        => '' },
                            { "selected"    => [] },
                            { "type"        => 'InputText' },
                            { "value"       => '' }
                        ]
                    }
                ]
            };
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @!;

    $self->render( 'json' => $resp );
}

# роут прототип папки  (Settings)
# "parent" => 1, - обязательно (должно быть натуральным числом) ???????????
sub proto_folder {
    my $self = shift;

    # read params
    my ( $id, $data, $resp );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # # проверка данных
        $data = $self->_check_fields();

        unless ( @! ) {
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

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @!;

    $self->render( 'json' => $resp );
}

sub proto_user {
    my $self = shift;

    # read params
    my ( $id, $data, $resp );
    # push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # # проверка данных
        $data = $self->_check_fields();

        unless ( @! ) {
            # прототип настройки
            $data = {
                'tabs' => [ # Вкладки
                    {
                        'label'     => 'Основные',
                        'fields'    => [
                            {'surname'       => ''}, # Фамилия
                            {'name'          => ''}, # Имя
                            {'patronymic'    => ''}, # Отчество
                            {'place'         => ''}, # город
                            {'country'       => ''}, # страна
                            {'timezone'      => ''}, # часовой пояс
                            {'birthday'      => ''}, # дата рождения (в секундах)
                            {'status'        => ''}, # активный / не активный пользователь
                            {'avatar'        => ''},
                            {'type'          => ''}                        # тип
                        ]
                    },
                    {
                        'label' => 'Контакты',
                        'fields' => [
                            {'email'           => ''}, # email пользователя
                            {'emailconfirmed'  => ''}, # email подтвержден
                            {'phone'           => ''}, # номер телефона
                            {'phoneconfirmed'  => ''}  # телефон подтвержден
                        ]
                    },
                    {
                        "fields" => [
                            {"password"        => ""},
                        ],
                        "label" => "Пароль"
                    },
                    {
                        "label" => "Группы",
                        "fields" => [
                            {"groups" => []}  # список ID групп
                        ]
                    }
                ]
            };
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @!;

    $self->render( 'json' => $resp );
}

sub proto_edit_user {
    my $self = shift;

    # read params
    my ( $id, $data, $resp );
    # push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # # проверка данных
        $data = $self->_check_fields();

        unless ( @! ) {
            # прототип настройки
            $data = {
                'id'     => '', # id Юзера
                'parent' => 0, # для юзеров равен 0
                'tabs' => [ # Вкладки
                    {
                        'label'     => 'Основные',
                        'fields'    => [
                            {'surname'       => ''}, # Фамилия
                            {'name'          => ''}, # Имя
                            {'patronymic'    => ''}, # Отчество
                            {'place'         => ''}, # город
                            {'country'       => ''}, # страна
                            {'timezone'      => ''}, # часовой пояс
                            {'birthday'      => ''}, # дата рождения (в секундах)
                            {'status'        => ''}, # активный / не активный пользователь
                            {'avatar'        => ''},
                            {'type'          => ''}                        # тип
                        ]
                    },
                    {
                        'label' => 'Контакты',
                        'fields' => [
                            {'email'           => ''}, # email пользователя
                            {'emailconfirmed'  => ''}, # email подтвержден
                            {'phone'           => ''}, # номер телефона
                            {'phoneconfirmed'  => ''}  # телефон подтвержден
                        ]
                    },
                    {
                        "fields" => [
                            {"password"        => ""},
                            {"newpassword"     => ""}
                        ],
                        "label" => "Пароль"
                    },
                    {
                        "label" => "Группы",
                        "fields" => [
                            {"groups" => []}  # список ID групп
                        ]
                    }
                ]
            };
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @!;

    $self->render( 'json' => $resp );
}


1;
