package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            {
               "list" => {
                    "body" => [
                        {
                            "surname" =>  "Фамилия",
                            "name" =>  "Имя",
                            "patronymic" =>  "Отчество",
                            "place" =>  "Луна",
                            "country" =>  "Киргизия",
                            "timezone" =>  "+3",
                            "birthday" =>  "01.01.2020",
                            "password" =>  "password1",
                            "avatar" =>  1234,
                            "type" =>  1,
                            "email" =>  "email\@mail.ru",
                            "emailconfirmed" =>  1,
                            "phone" =>  "9873636363",
                            "phoneconfirmed" =>  1,
                            "status" =>  1
                        }
                    ],
                    "settings" => {
                        "editable" => 1,
                        "massEdit" => 0,
                        "page" => {
                            "current_page" => 1,
                            "per_page" => 100,
                            "total" => 0
                        },
                        "removable" => 1,
                        "sort" => {
                            "name" => "id",
                            "order" => "asc"
                        }
                    }
                },
               "status" => "ok"
            }
        }
    );
    return;

warn "index";

    my ($data, $list, $resp, @mess);

# my $OfficeHelper = $Self->{EAVObject}->new('Office');
# my $Childs       = $OfficeHelper->_list(
#     {
#         Parents => { $Param{Data}->{GroupNode} => 0 },
#         Filter  => { Type                      => 'office' },
#     }
# );
    $list = Freee::EAV->new( 'User' );
    $list = $list->_list(
        {
            Parents => { 1      => 0 },
            Filter  => { Type   => 'User' },
        }
    );
warn Dumper $list;


    $data = {
        'body' => [],
        'settings' => {
            'editable' => 1,
            'massEdit' => 0,
            'page' => {
                'current_page' => 1,
                'per_page' => 100,
                'total' => 0
            },
            'removable' => 1,
            'sort' => {
                'name' => 'id',
                'order' => 'asc'
            }
        }
    };

    # my @data;
    # foreach (1..10) {
    #     push @data, {
    #         'id'                => $_,
    #         'surname'           => 'Фамилия',           # Фамилия
    #         'name'              => 'Имя',               # Имя
    #         'patronymic'        => 'Отчество',          # Отчество
    #         'city'              => 'Санкт-Петербург',   # город
    #         'country'           => 'Россия',            # страна
    #         'timezone'          => '+3',                # часовой пояс
    #         'birthday'          => 123132131,           # дата рождения (в секундах)
    #         'email'             => 'username_'.$_.'@ya.ru',    # email пользователя
    #         'emailconfirmed'    => 1,                   # email подтвержден
    #         'phone'             => 79312445646,         # номер телефона
    #         'phoneconfirmed'    => 1,                   # телефон подтвержден
    #         'status'            => 1,                   # активный / не активный пользователь
    #         'groups'            => [1, 2, 3],           # список ID групп
    #         'password'          => 'khasdf',            # хеш пароля
    #         'avatar'            => 'https://thispersondoesnotexist.com/image'
    #     };
    # }
    # $data->{'body'} = \@data;
    # $data->{'settings'}->{'page'}->{'total'} = scalar(@data);
    $data->{'body'} = $list;
    $data->{'settings'}->{'page'}->{'total'} = scalar(@$list);

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            "data" => {
                "tabs" => [
                    {
                    "fields" => [
                       {"name" => "имя_right"},
                       {"patronymic" => "отчество_right"},
                       {"surname" => "фамилия_right"},
                       {"birthday" => "01.01.2000"},
                       {"avatar" => "1234"},
                       {"country" => "Россия"},
                       {"place" => "place"},
                       {"status" => "1"},
                       {"timezone" => '+3'},
                       {"type" => "1"}
                    ],
                    "label" => "Основные"
                },
                {
                    "fields" => [
                       {"email" => "emailright\@email.ru"},
                       {"emailconfirmed" => "emailright\@email.ru"},
                       {"phone" => '+79212222222'},
                       {"phoneconfirmed" => '+79212222222'}
                    ],
                    "label" => "Контакты"
                 },
                 {
                    "fields" => [
                        {"password" => "password1"},
                        {"newpassword" => "password1"}
                    ],
                    "label" => "Пароль"
                 },
                    {
                        "fields" => [
                           {"groups" => [] }
                        ],
                        "label" => "Группы"
                    }
                ]
            },
            "status" => "ok"
        }
    );
    return;

    $self->render(
        'json'    => {
            'message'   => 'error',
            'status'    => 'fail'
        }
    );

    my ($user, $data, $param, $resp, $error, $main, $contacts, $groups, @mess);

    unless (@mess) {
        # проверка данных
        ($param, $error) = $self->_check_fields();
        push @mess, $error unless $param;

        if ($param) {
            # получаем данные пользователя
            $user = Freee::EAV->new( 'User', { 'id' => $param->{'id'} } );
            $user = $user->GetUser($param->{'id'});

            $main = [
                { 'surname'       => $$user{'surname'} },       # Фамилия
                { 'name'          => $$user{'name'} },          # Имя
                { 'patronymic'    => $$user{'patronymic'} },    # Отчество
                { 'city'          => $$user{'city'} },          # город
                { 'country'       => $$user{'country'} },       # страна
#?                        { 'timezone'      => $$user{'timezone'} },    # часовой пояс
                { 'birthday'      => $$user{'birthday'} },      # дата рождения (в секундах)
#?                        { 'password'    => $$user{'password'} },      # пароль
#?                        { 'newpassword' => $$user{'newpassword'} },   # пароль
#?                        { 'type'          => 3 }                        # тип
            ];
            $contacts = [
                { 'email'           => $$user{'email'} },           # email пользователя
#?                        { 'emailconfirmed'  => $$user{'emailconfirmed'} },  # email подтвержден
                { 'phone'           => $$user{'phone'} },           # номер телефона
#?                        { 'phoneconfirmed'  => $$user{'phoneconfirmed'} }   # телефон подтвержден
            ];
            $groups = [
                { "groups" => 1 }  # список ID групп
            ];
        }
        else {
            push @mess, "Could not get '".$param->{'id'}."'";
        }
    }

    # $user = {
    #     'id'                => 1,
    #     'surname'           => 'Фамилия',           # Фамилия
    #     'name'              => 'Имя',               # Имя
    #     'patronymic'        => 'Отчество',          # Отчество
    #     'city'              => 'Санкт-Петербург',   # город
    #     'country'           => 'Россия',            # страна
    #     'timezone'          => '+3',                # часовой пояс
    #     'birthday'          => 123132131,           # дата рождения (в секундах)
    #     'email'             => 'username@ya.ru',    # email пользователя
    #     'emailconfirmed'    => 1,                   # email подтвержден
    #     'phone'             => 79312445646,         # номер телефона
    #     'phoneconfirmed'    => 1,                   # телефон подтвержден
    #     'status'            => 1,                   # активный / не активный пользователь
    #     'groups'            => [1, 2, 3],           # список ID групп
    #     'password'          => 'khasdf',            # хеш пароля
    #     'avatar'            => 'https://thispersondoesnotexist.com/image'
    # };

    # Так будет отдаваться на фронт:
    unless (@mess) {
        $data = {
            'id' => $$user{'id'},
            'tabs' => [ # Вкладки 
                {
                    'label' => 'Основные',
                    'fields'=> $main
                },
                {
                    'label' => 'Контакты',
                    'fields' => $contacts
                },
                {
                    "label" => "Группы",
                    "fields" => $groups  # список ID групп
                }
            ]
        };
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'id'        => 1,
            'status'    => 'ok'
        }
    );
    return;

    my ($data, $resp, $result, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем, - есть ли такой юзер в EAV и users
        # my $usr = Freee::EAV->new( 'User', { id => 2 } );
        my $user = {
            'email' => $$data{'email'},
            'phone' => $$data{'phone'}
        };
        ( $result, $error ) = $self->model('User')->_check_user( $user );

        # if ( $result ) {
        #     push @mess, "Email $$data{'email'} already used";
        # }
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # добавляем юзера в EAV и users
        $$data{'time_create'} = $self->_get_time();
        $$data{'time_access'} = $self->_get_time();
        $$data{'time_update'} = $self->_get_time();

        ( $result, $error ) = $self->model('User')->_insert_user( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @mess;

    $self->render( 'json' => $resp );
}

sub add_by_email {
    my $self = shift;

    $self->render(
        'json'    => {
            'id'        => 1,
            'status'    => 'ok'
        }
    );

    $self->render(
        'json'    => {
            'message'   => 'Email emailright@email.ru already used',
            'status'    => 'fail'
        }
    );
    return;

    my ( $data, $resp, $error, $result, $data_eav, $user, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем, - есть ли такой юзер в EAV и users

        # my $usr = Freee::EAV->new( 'User', { id => 2 } );
        my $user = {
            'email' => $$data{'email'}
        };

        ( $result, $error ) = $self->model('User')->_check_user( $user );

        if ( $result ) {
            push @mess, "Email $$data{'email'} already used";
        }
        push @mess, $error if $error;
    }

    # добавляем юзера в EAV и users
    unless ( @mess ) {
        $$data{'time_create'} = $self->_get_time();
        $$data{'time_access'} = $self->_get_time();
        $$data{'time_update'} = $self->_get_time();
        $$data{'phone'}       = ' ';

        ( $result, $error ) = $self->model('User')->_insert_user( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @mess;

    $self->render( 'json' => $resp );
}

sub add_by_phone {
    my $self = shift;

    $self->render(
        'json'    => {
            'id'        => 1,
            'status'    => 'ok'
        }
    );
    return;

    my ( $data, $resp, $error, $result, $data_eav, $user, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем, - есть ли такой юзер в EAV и users

        # my $usr = Freee::EAV->new( 'User', { id => 2 } );
        my $user = {
            'phone' => $$data{'phone'}
        };

        ( $result, $error ) = $self->model('User')->_check_user( $user );

        if ( $result ) {
            push @mess, "Phone $$data{'phone'} already used";
        }
        push @mess, $error if $error;
    }

    # добавляем юзера в EAV и users
    unless ( @mess ) {
        $$data{'time_create'} = $self->_get_time();
        $$data{'time_access'} = $self->_get_time();
        $$data{'time_update'} = $self->_get_time();
        $$data{'email'}       = ' ';

        ( $result, $error ) = $self->model('User')->_insert_user( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @mess;

    $self->render( 'json' => $resp );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'id'        => 1,
            'status'    => 'ok'
        }
    );
    return;

    my ($data, $resp, @mess);
    $data = {
        'id'                => 1,
        'surname'           => 'Фамилия',           # Фамилия
        'name'              => 'Имя',               # Имя
        'patronymic'        => 'Отчество',          # Отчество
        'city'              => 'Санкт-Петербург',   # город
        'country'           => 'Россия',            # страна
        'timezone'          => '+3',                # часовой пояс
        'birthday'          => 123132131,           # дата рождения (в секундах)
        'email'             => 'username@ya.ru',    # email пользователя
        'emailconfirmed'    => 1,                   # email подтвержден
        'phone'             => 79312445646,         # номер телефона
        'phoneconfirmed'    => 1,                   # телефон подтвержден
        'status'            => 1,                   # активный / не активный пользователь
        'groups'            => [1, 2, 3],           # список ID групп
        'password'          => 'khasdf',            # хеш пароля
        'avatar'            => 'https://thispersondoesnotexist.com/image'
    };

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}


# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    $self->render(
        'json'    => {
            'id'        => 1,
            'status'    => 'ok'
        }
    );
    return;

    my ($toggle, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            $$data{'table'} = 'settings';
            $toggle = $self->model('Utils')->_toggle( $data ) unless @mess;
            push @mess, "Could not toggle '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'status'    => 'ok'
        }
    );
    return;

    my ($data, $resp, @mess);
    $data = {};

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

1;