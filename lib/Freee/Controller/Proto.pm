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
    my ( $id, $data, $hashref, $countries, $timezones, $resp );
    # push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # # проверка данных
        $data = $self->_check_fields();

        unless ( @! ) {
            $hashref = $self->_countries();
            foreach ( sort { uc( $$hashref{$a} ) cmp uc( $$hashref{$b} ) } keys %$hashref ) {
                push @$countries, [ $_, $$hashref{$_} ];
            }

            $hashref = $self->_time_zones();
            foreach ( sort { $a <=> $b } keys %$hashref ) {
                push @$timezones, [ $_, $$hashref{$_} ];
            }

            # прототип пользователя
            $data = {
                'tabs' => [ # Вкладки
                    {
                        'label'     => 'Основные',
                        'fields'    => [
                            {'surname'       => ''}, # Фамилия
                            {'name'          => ''}, # Имя
                            {'patronymic'    => ''}, # Отчество
                            {'place'         => ''}, # город
                            {'country'       =>      # страна
                                {
                                    "selected"  => $countries, 
                                    "value"     => ''
                                }
                            },
                            {'timezone'       =>     # часовой пояс
                                {
                                    "selected"  => $timezones, 
                                    "value"     => ''
                                }
                            },
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
                            {'phone'           => ''}  # номер телефона
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
