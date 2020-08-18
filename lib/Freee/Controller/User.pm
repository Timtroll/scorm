package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

# список юзеров по группам (обязательно id группы)
# id - Id группы
# status - показывать группы только с этим статусом
sub index {
    my $self = shift;

    my ( $data, $list, $resp, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # получаем список пользователей группы
        $result = $self->model('User')->_get_list( $data );
    }

    unless ( @! ) {
        $list = {
            'settings' => {
                'editable' => 1,
                'massEdit' => 0,
                'page' => {
                    'current_page' => 1,
                    'per_page'     => 100
                },
                'removable' => 1,
                'sort' => {
                    'name' => 'id',
                    'order' => 'asc'
                }
            }
        };

        if ( $result ) {
            $list->{'body'} = $result;
            $list->{'settings'}->{'page'}->{'total'} = scalar(@$result);
        }
        else {
            $list->{'body'} = [];
            $list->{'settings'}->{'page'}->{'total'} = 0;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# редактирование юзера
# id - Id пользователя
sub edit {
    my $self = shift;

    my ( $user, $data, $param, $resp, $result_eav, $result, $hashref, $countries, $timezones );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # получаем данные пользователя
        $result_eav = $self->model('User')->_get_user( $data );
    }

    # получение значений для selected
    unless ( @! ) {
        $hashref = $self->_countries();
        foreach ( sort { uc( $$hashref{$a} ) cmp uc( $$hashref{$b} ) } keys %$hashref ) {
            push @$countries, [ $_, $$hashref{$_} ];
        }

        $hashref = $self->_time_zones();
        foreach ( sort { $a <=> $b } keys %$hashref ) {
            push @$timezones, [ $_, $$hashref{$_} ];
        }
    }

    unless ( @! ) {
        # перевод времени в секунды
        $$result_eav{'birthday'} = $self->model('Utils')->_date2sec( $$result_eav{'birthday'} );
        $result = {
            'tabs' => [ # Вкладки 
                {
                    'label' => 'Основные',
                    'fields'=> [
                        {"name"       => $$result_eav{'name'} },
                        {"patronymic" => $$result_eav{'patronymic'} },
                        {"surname"    => $$result_eav{'surname'} },
                        {"birthday"   => $$result_eav{'birthday'} },
                        {"avatar"     => $$result_eav{'import_source'} },
                        {"country"    =>  
                            {
                                "selected" => $countries, 
                                "value"    => $$result_eav{'country'}
                            }
                        },
                        {"place"      => $$result_eav{'place'} },
                        {"status"     => $$result_eav{'publish'} ? 1 : 0 },
                        {"timezone"    =>  
                            {
                                "selected" => $timezones, 
                                "value"    => $$result_eav{'timezone'}
                            }
                        },
                        {"type"       => 'User' }
                    ]
                },
                {
                    'label' => 'Контакты',
                    'fields' => [
                       {"email"          => $$result_eav{'email'} },
                       {"emailconfirmed" => 1 },
                       {"phone"          => $$result_eav{'phone'} },
                       {"phoneconfirmed" => 1 }
                    ]
                },
                {
                    'label' => 'Пароль',
                    'fields' => [
                       {"password"       => $$result_eav{'password'} }
                    ]
                },
                {
                    "label" => "Группы",
                    "fields" => [
                       { "groups" => $$result_eav{'groups'} }
                    ]
                }
            ]
        };
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавлением нового пользователя в EAV и таблицу users
# ( $user_id ) = $self->model('User')->_insert_user( $data );
# $data = {
#     'place'       => 'place',                         # кладется в EAV
#     'country'     => 'country',                       # кладется в EAV
#     'birthday'    => '1972-01-06 00:00:00',           # кладется в EAV
#     'surname'     => 'test',                          # кладется в EAV
#     'name'        => 'name',                          # кладется в EAV
#     'patronymic'  => 'patronymic',                    # кладется в EAV
#     'email'       => 'test@test.com',                 # кладется в users
#     'phone'       => '+7(999) 222-2222',              # кладется в users
#     'password'    => 'password',                      # кладется в users
#     'timezone'    => '10',                            # кладется в users
# }
sub add {
    my ($self);
    $self = shift;

    my ($data, $resp, $result, $groups );
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
        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }
        else {
            $$data{'birthday'}    = '';
        }

        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     = $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

        # добавляем юзера в EAV и users
        $result = $self->model('User')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавлением нового пользователя в EAV и таблицу users
# ( $user_id ) = $self->model('User')->_insert_user( $data );
# $data = {
#     'place'       => 'place',                         # кладется в EAV
#     'country'     => 'country',                       # кладется в EAV
#     'birthday'    => '1972-01-06 00:00:00',           # кладется в EAV
#     'surname'     => 'test',                          # кладется в EAV
#     'name'        => 'name',                          # кладется в EAV
#     'patronymic'  => 'patronymic',                    # кладется в EAV
#     'email'       => 'test@test.com',                 # кладется в users
#     'password'    => 'password',                      # кладется в users
#     'timezone'    => '10',                            # кладется в users
# }
sub add_by_email {
    my $self = shift;

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
        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }
        else {
            $$data{'birthday'}    = '';
        }

        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     = $$data{'status'};
        $$data{'phone'}       = '';
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

        $result = $self->model('User')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавлением нового пользователя в EAV и таблицу users
# ( $user_id ) = $self->model('User')->_insert_user( $data );
# $data = {
#     'place'       => 'place',                         # кладется в EAV
#     'country'     => 'country',                       # кладется в EAV
#     'birthday'    => '1972-01-06 00:00:00',           # кладется в EAV
#     'surname'     => 'test',                          # кладется в EAV
#     'name'        => 'name',                          # кладется в EAV
#     'patronymic'  => 'patronymic',                    # кладется в EAV
#     'phone'       => '+7(999) 222-2222',              # кладется в users
#     'password'    => 'password',                      # кладется в users
#     'timezone'    => '10',                            # кладется в users
# }
sub add_by_phone {
    my $self = shift;

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
        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }
        else {
            $$data{'birthday'}    = '';
        }

        $$data{'time_create'} = $self->model('Utils')->_get_time();
        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'email'}       = '';
        $$data{'publish'}     = $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};

        $result = $self->model('User')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранение данных о пользователе
# $result = $self->model('User')->_save_user( $data );
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
sub save {
    my $self = shift;

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
        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }
        else {
            $$data{'birthday'}    = '';
        }

        $$data{'time_access'} = $self->model('Utils')->_get_time();
        $$data{'time_update'} = $self->model('Utils')->_get_time();
        $$data{'publish'}     =  $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
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
# my $true = $self->toggle( $data );
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

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

# удаление пользователя
# $result = $self->model('User')->_delete_user( $data );
# 'id'    - id записи 
sub delete {
    my $self = shift;

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