package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

sub index {
    my $self = shift;

#     $self->render(
#         'json'    => {
#             {
#                "list" => {
#                     "body" => [
#                         {
#                             "surname" =>  "Фамилия",
#                             "name" =>  "Имя",
#                             "patronymic" =>  "Отчество",
#                             "place" =>  "Луна",
#                             "country" =>  "Киргизия",
#                             "timezone" =>  "+3",
#                             "birthday" =>  "01.01.2020",
#                             "password" =>  "password1",
#                             "avatar" =>  1234,
#                             "type" =>  1,
#                             "email" =>  "email\@mail.ru",
#                             "emailconfirmed" =>  1,
#                             "phone" =>  "9873636363",
#                             "phoneconfirmed" =>  1,
#                             "status" =>  1
#                         }
#                     ],
#                     "settings" => {
#                         "editable" => 1,
#                         "massEdit" => 0,
#                         "page" => {
#                             "current_page" => 1,
#                             "per_page" => 100,
#                             "total" => 0
#                         },
#                         "removable" => 1,
#                         "sort" => {
#                             "name" => "id",
#                             "order" => "asc"
#                         }
#                     }
#                 },
#                "status" => "ok"
#             }
#         }
#     );
#     return;

# warn "index";

# my $OfficeHelper = $Self->{EAVObject}->new('Office');
# my $Childs       = $OfficeHelper->_list(
#     {
#         Parents => { $Param{Data}->{GroupNode} => 0 },
#         Filter  => { Type                      => 'office' },
#     }
# );

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

    my ( $data, $list, $resp, $error, $result, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # unless ( @mess ) {

    #     $usr = Freee::EAV->new( 'User' );
    #     # $list = $list->_list(
    #     #     {
    #     #         Parents => { 1      => 0 },
    #     #         Filter  => { Type   => 'User' },
    #     #     }
    #     # );
    #     $list = $usr->_list( $dbh, { Filter => { 'User.parent' => $$data{'id'} } } );

    # warn Dumper $list;
    # }

    unless ( @mess ) {
        # получаем список пользователей группы
        ( $result, $error ) = $self->model('User')->_get_list( $data );
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        $list = {
            'list' => {
                'settings' => {
                    'editable' => 1,
                    'massEdit' => 0,
                    'page' => {
                        'current_page' => 1,
                        'per_page' => 100
                    },
                    'removable' => 1,
                    'sort' => {
                        'name' => 'id',
                        'order' => 'asc'
                    }
                }
            }
        };

        if ( $result ) {
            $list->{'list'}->{'body'} = $result;
            $list->{'list'}->{'settings'}->{'page'}->{'total'} = scalar(@$result);
        }
        else {
            $list->{'list'}->{'body'} = [];
            $list->{'list'}->{'settings'}->{'page'}->{'total'} = 0;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @mess;

    $self->render( 'json' => $resp );
}

sub edit {
    my $self = shift;

    # $self->render(
    #     'json'    => {
    #         "data" => {
    #             "tabs" => [
    #                 {
    #                 "fields" => [
    #                    {"name" => "имя_right"},
    #                    {"patronymic" => "отчество_right"},
    #                    {"surname" => "фамилия_right"},
    #                    {"birthday" => "01.01.2000"},
    #                    {"avatar" => "1234"},
    #                    {"country" => "Россия"},
    #                    {"place" => "place"},
    #                    {"status" => "1"},
    #                    {"timezone" => '+3'},
    #                    {"type" => "1"}
    #                 ],
    #                 "label" => "Основные"
    #             },
    #             {
    #                 "fields" => [
    #                    {"email" => "emailright\@email.ru"},
    #                    {"emailconfirmed" => "emailright\@email.ru"},
    #                    {"phone" => '+79212222222'},
    #                    {"phoneconfirmed" => '+79212222222'}
    #                 ],
    #                 "label" => "Контакты"
    #              },
    #              {
    #                 "fields" => [
    #                     {"password" => "password1"},
    #                     {"newpassword" => "password1"}
    #                 ],
    #                 "label" => "Пароль"
    #              },
    #                 {
    #                     "fields" => [
    #                        {"groups" => [] }
    #                     ],
    #                     "label" => "Группы"
    #                 }
    #             ]
    #         },
    #         "status" => "ok"
    #     }
    # );
    # return;

    # $self->render(
    #     'json'    => {
    #         'message'   => 'error',
    #         'status'    => 'fail'
    #     }
    # );

    my ( $user, $data, $param, $resp, $error, $main, $contacts, $password, $groups, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # получаем данные пользователя
        ( $main, $contacts, $password, $groups, $error ) = $self->model('User')->_get_user( $data );
        push @mess, $error if $error;
    }

        # $user = Freee::EAV->new( 'User', { 'id' => $$data{'id'} } );
        # $user = $user->GetUser( $$data{'id'} );

    # unless ( @mess ) {
#             $main = [
#                 { 'surname'       => $$user{'surname'} },       # Фамилия
#                 { 'name'          => $$user{'name'} },          # Имя
#                 { 'patronymic'    => $$user{'patronymic'} },    # Отчество
#                 { 'city'          => $$user{'city'} },          # город
#                 { 'country'       => $$user{'country'} },       # страна
# #?                        { 'timezone'      => $$user{'timezone'} },    # часовой пояс
#                 { 'birthday'      => $$user{'birthday'} },      # дата рождения (в секундах)
# #?                        { 'password'    => $$user{'password'} },      # пароль
# #?                        { 'newpassword' => $$user{'newpassword'} },   # пароль
# #?                        { 'type'          => 3 }                        # тип
#             ];
#             $contacts = [
#                 { 'email'           => $$user{'email'} },           # email пользователя
# #?                        { 'emailconfirmed'  => $$user{'emailconfirmed'} },  # email подтвержден
#                 { 'phone'           => $$user{'phone'} },           # номер телефона
# #?                        { 'phoneconfirmed'  => $$user{'phoneconfirmed'} }   # телефон подтвержден
#             ];
#             $groups = [
#                 { "groups" => 1 }  # список ID групп
#             ];
    # }

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

# warn Dumper( $contacts );
# warn Dumper( $password );
    # Так будет отдаваться на фронт:
    unless ( @mess ) {
        $data = {
            # 'id' => $$user{'id'},   ????????????????????????????????????????????????????
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
                    'label' => 'Пароль',
                    'fields' => $password
                },
                {
                    "label" => "Группы",
                    "fields" => $groups
                }
            ]
        };
    }

    # Так будет отдаваться на фронт:
    # unless ( @mess ) {
    #     $data = {
    #         "tabs" => [
    #             {
    #             "fields" => [
    #                {"name" => "имя_right"},
    #                {"patronymic" => "отчество_right"},
    #                {"surname" => "фамилия_right"},
    #                {"birthday" => "01.01.2000"},
    #                {"avatar" => "1234"},
    #                {"country" => "Россия"},
    #                {"place" => "place"},
    #                {"status" => "1"},
    #                {"timezone" => '+3'},
    #                {"type" => "1"}
    #             ],
    #             "label" => "Основные"
    #         },
    #         {
    #             "fields" => [
    #                {"email" => "emailright\@email.ru"},
    #                {"emailconfirmed" => "emailright\@email.ru"},
    #                {"phone" => '+79212222222'},
    #                {"phoneconfirmed" => '+79212222222'}
    #             ],
    #             "label" => "Контакты"
    #          },
    #          {
    #             "fields" => [
    #                 {"password" => "password1"},
    #                 {"newpassword" => "password1"}
    #             ],
    #             "label" => "Пароль"
    #          },
    #             {
    #                 "fields" => [
    #                    {"groups" => [] }
    #                 ],
    #                 "label" => "Группы"
    #             }
    #         ]
    #     };
    # }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @mess;

    $self->render( 'json' => $resp );
}

sub add {
    my ($self);
    $self = shift;

    # $self->render(
    #     'json'    => {
    #         'id'        => 1,
    #         'status'    => 'ok'
    #     }
    # );
    # return;

    my ($data, $resp, $result, $error, $groups, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # unless ( @mess ) {
    #     # проверяем, - есть ли такой юзер в EAV и users
    #     # my $usr = Freee::EAV->new( 'User', { id => 2 } );
    #     # my $user = {
    #     #     'email' => $$data{'email'},
    #     #     'phone' => $$data{'phone'}
    #     # };
    #     # ( $result, $error ) = $self->model('User')->_check_user( $user );
    #     # if ( $result ) {
    #     #     push @mess, "Email $$data{'email'} already used";
    #     # }

    #     # проверяем, используется ли емэйл или телефон другим пользователем
    #     ( $result, $error ) = $self->model('User')->_check_user( $data );
    #     push @mess, $error unless $result;
    # }

    unless ( @mess ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @mess, "email '$$data{ email }' already used"; 
        }

        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'} ) ) {
            push @mess, "phone '$$data{ phone }' already used"; 
        }
    }

    unless ( @mess ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @mess, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @mess ) {
        # добавляем юзера в EAV и users
        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     = $$data{'status'};

# warn Dumper( $$data{'groups'} );
#         $$data{'groups'}      = from_json( $$data{'groups'} );
# warn Dumper( $$data{'groups'} );

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

    # $self->render(
    #     'json'    => {
    #         'id'        => 1,
    #         'status'    => 'ok'
    #     }
    # );

    # $self->render(
    #     'json'    => {
    #         'message'   => 'Email emailright@email.ru already used',
    #         'status'    => 'fail'
    #     }
    # );
    # return;

    my ( $groups, $data, $resp, $error, $result, $data_eav, $user, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @mess, "email '$$data{ email }' already used"; 
        }
    }

    unless ( @mess ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @mess, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    # добавляем юзера в EAV и users
    unless ( @mess ) {
        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     = $$data{'status'};
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

    # $self->render(
    #     'json'    => {
    #         'id'        => 1,
    #         'status'    => 'ok'
    #     }
    # );
    # return;

    my ( $data, $resp, $error, $result, $data_eav, $user, $groups, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'} ) ) {
            push @mess, "phone '$$data{ phone }' already used"; 
        }
    }

    unless ( @mess ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @mess, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    # добавляем юзера в EAV и users
    unless ( @mess ) {
        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'email'}       = ' ';
        $$data{'publish'}     = $$data{'status'};

        ( $result, $error ) = $self->model('User')->_insert_user( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @mess;

    $self->render( 'json' => $resp );
}

sub save {
    my $self = shift;

    # $self->render(
    #     'json'    => {
    #         'id'        => 1,
    #         'status'    => 'ok'
    #     }
    # );
    # return;

    # $data = {
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

    my ( $data, $resp, $groups, $result, $error, $mess, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        unless ( $$data{'phone'} || $$data{'email'} ) {
            push @mess, 'No email and no phone';
        }

        if ( $$data{'password'} && !$$data{'newpassword'} ) {
            push @mess, 'No newpassword';
        }
        elsif ( !$$data{'password'} && $$data{'newpassword'} ) {
            push @mess, 'No password';
        }
        elsif ( $$data{'password'} && $$data{'password'} eq $$data{'newpassword'} ) {
            push @mess, 'Password and newpassword are the same';
        }
    }

    unless ( @mess ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $$data{'email'} && $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'}, $$data{'id'} ) ) {
            push @mess, "email '$$data{ email }' already used"; 
        }

        # проверяем, используется ли телефон другим пользователем
        if ( $$data{'phone'} && $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'}, $$data{'id'} ) ) {
            push @mess, "phone '$$data{ phone }' already used"; 
        }
    }

    unless ( @mess ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @mess, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @mess ) {
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'} =  $$data{'status'};

        ( $result, $error ) = $self->model('User')->_save_user( $data );
        push @mess, $error if $error;
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    $resp->{'message'} = $mess if $mess;
    $resp->{'status'} = $mess ? 'fail' : 'ok';
    $resp->{'id'} = $result unless $mess;

    $self->render( 'json' => $resp );
}


# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    # $self->render(
    #     'json'    => {
    #         'id'        => 1,
    #         'status'    => 'ok'
    #     }
    # );
    # return;

    my ( $toggle, $resp, $data, $result, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        $$data{'status'} = $$data{'status'} ? 'true' : 'false';
        ( $result, $error ) = $self->model('User')->_toggle_user( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @mess;

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    # $self->render(
    #     'json'    => {
    #         'status'    => 'ok'
    #     }
    # );
    # return;

    my ( $data, $resp, $result, $error, @mess );

    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # удаление пользователя из EAV и из Users
    unless ( @mess ) {
        ( $result, $error ) = $self->model('User')->_delete_user( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

1;