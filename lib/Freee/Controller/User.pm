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

    my ( $data, $list, $resp, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    # unless ( @! ) {

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

    unless ( @! ) {
        # получаем список пользователей группы
        $result = $self->model('User')->_get_list( $data );
    }

    unless ( @! ) {
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

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub edit {
    my $self = shift;

    my ( $user, $data, $param, $resp, $main, $contacts, $password, $groups );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # получаем данные пользователя
        ( $main, $contacts, $password, $groups ) = $self->model('User')->_get_user( $data );
    }

    # Так будет отдаваться на фронт:
    unless ( @! ) {
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
    # unless ( @! ) {
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

    # получение значений для select
    my ( $hashref, $countries, $timezones );
    unless ( @! ) {
        $hashref = $self->_countries();
        foreach ( sort { $a cmp $b } keys %$hashref ) {
            push @$countries, [ $_, $$hashref{$_} ];
        }

        $hashref = $self->_time_zones();
        foreach ( sort { $a cmp $b } keys %$hashref ) {
            push @$timezones, [ $_, $$hashref{$_} ];
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @!;

    @! = ();

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

    my ($data, $resp, $result, $groups );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    # unless ( @! ) {
    #     # проверяем, - есть ли такой юзер в EAV и users
    #     # my $usr = Freee::EAV->new( 'User', { id => 2 } );
    #     # my $user = {
    #     #     'email' => $$data{'email'},
    #     #     'phone' => $$data{'phone'}
    #     # };
    #     # ( $result, $error ) = $self->model('User')->_check_user( $user );
    #     # if ( $result ) {
    #     #     push @!, "Email $$data{'email'} already used";
    #     # }

    #     # проверяем, используется ли емэйл или телефон другим пользователем
    #     ( $result, $error ) = $self->model('User')->_check_user( $data );
    #     push @!, $error unless $result;
    # }

    unless ( @! ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @!, "email '$$data{ email }' already used"; 
        }

        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'} ) ) {
            push @!, "phone '$$data{ phone }' already used"; 
        }
    }

    unless ( @! ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @!, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! ) {
        # добавляем юзера в EAV и users
        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     = $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'birthday'}    = '' unless $$data{'birthday'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

# warn Dumper( $$data{'groups'} );
#         $$data{'groups'}      = from_json( $$data{'groups'} );
# warn Dumper( $$data{'groups'} );

        $result = $self->model('User')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

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

    my ( $groups, $data, $resp, $result, $data_eav, $user );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @!, "email '$$data{ email }' already used"; 
        }
    }

    unless ( @! ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @!, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    # добавляем юзера в EAV и users
    unless ( @! ) {
        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     = $$data{'status'};
        $$data{'phone'}       = '';
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'birthday'}    = '' unless $$data{'birthday'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

        $result = $self->model('User')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

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

    my ( $data, $resp, $result, $data_eav, $user, $groups );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'} ) ) {
            push @!, "phone '$$data{ phone }' already used"; 
        }
    }

    unless ( @! ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @!, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    # добавляем юзера в EAV и users
    unless ( @! ) {
        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'email'}       = '';
        $$data{'publish'}     = $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'birthday'}    = '' unless $$data{'birthday'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

        $result = $self->model('User')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

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

    my ( $data, $resp, $groups, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        unless ( $$data{'phone'} || $$data{'email'} ) {
            push @!, 'No email and no phone';
        }

        if ( $$data{'password'} && !$$data{'newpassword'} ) {
            push @!, 'No newpassword';
        }
        elsif ( !$$data{'password'} && $$data{'newpassword'} ) {
            push @!, 'No password';
        }
        elsif ( $$data{'password'} && $$data{'password'} eq $$data{'newpassword'} ) {
            push @!, 'Password and newpassword are the same';
        }
    }

    unless ( @! ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $$data{'email'} && $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'}, $$data{'id'} ) ) {
            push @!, "email '$$data{ email }' already used"; 
        }

        # проверяем, используется ли телефон другим пользователем
        if ( $$data{'phone'} && $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'}, $$data{'id'} ) ) {
            push @!, "phone '$$data{ phone }' already used"; 
        }
    }

    unless ( @! ) {
        # проверка существования групп пользователя
        $groups = from_json( $$data{'groups'} );
        foreach ( @$groups ) {
            unless( $self->model('Utils')->_exists_in_table('groups', 'id', $_ ) ) {
                push @!, "group with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! ) {
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     =  $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'birthday'}    = '' unless $$data{'birthday'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

        $result = $self->model('User')->_save_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

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

    my ( $toggle, $resp, $data, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        $$data{'status'} = $$data{'status'} ? 'true' : 'false';
        $result = $self->model('User')->_toggle_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

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

    my ( $data, $resp, $result );

    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    # удаление пользователя из EAV и из Users
    unless ( @! ) {
        $result = $self->model('User')->_delete_user( $data );
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();

    $self->render( 'json' => $resp );
}

1;