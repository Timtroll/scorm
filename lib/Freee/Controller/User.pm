package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );
use Digest::SHA qw( sha256 );

# список юзеров по группам (обязательно id группы)
# $self->index($data)
# $data = { 
# id - Id группы
# status - показывать группы только с этим статусом
# page - вывести список начиная с этой страницы ( по умолчанию 1 )
# }
sub index {
    my $self = shift;

    my ( $data, $list, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();
    
    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};

        $$data{'limit'}  = $self->{'app'}->{'settings'}->{'list_limit'};
        $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};

        # получаем список пользователей группы
        $result = $self->model('User')->_get_list( $data );

        unless ( @! ) {
            $list = {
                'settings' => {
                    'editable' => 1,
                    'massEdit' => 0,
                    'page' => {
                        'current_page' => $$data{'page'},
                        'per_page'     => $$data{'limit'}
                    },
                    'removable' => 1,
                    'sort' => {
                        'name' => 'id',
                        'order' => 'asc'
                    }
                }
            };

            $list->{'body'} = $result;
            $list->{'settings'}->{'page'}->{'total'} = scalar(@$result);
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# редактирование юзера
# $self->edit($data)
# $data = { 
#     id => 123 - Id пользователя
# }
sub edit {
    my $self = shift;

    my ( $user, $data, $param, $resp, $user_data, $result, $hashref, $countries, $timezones );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем данные пользователя
        $user_data = $self->model('User')->_get_user( $data );

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
    }

    unless ( @! ) {
        # перевод времени в секунды
        $$user_data{'birthday'} = $self->model('Utils')->_date2sec( $$user_data{'birthday'} );
        $result = {
            'id'   => $$user_data{'id'},
            'tabs' => [ # Вкладки 
                {
                    'label' => 'Основные',
                    'fields'=> [
                        {"name"       => $$user_data{'name'} },
                        {"patronymic" => $$user_data{'patronymic'} },
                        {"surname"    => $$user_data{'surname'} },
                        {"birthday"   => $$user_data{'birthday'} },
                        {"avatar"     => $$user_data{'import_source'} },
                        {"country"    =>  
                            {
                                "selected" => $countries, 
                                "value"    => $$user_data{'country'}
                            }
                        },
                        {"place"      => $$user_data{'place'} },
                        {"status"     => $$user_data{'publish'} ? 1 : 0 },
                        {"timezone"    =>  
                            {
                                "selected" => $timezones, 
                                "value"    => $$user_data{'timezone'}
                            }
                        },
                        {"type"       => 'User' }
                    ]
                },
                {
                    'label' => 'Контакты',
                    'fields' => [
                       {"email"          => $$user_data{'email'} },
                       {"emailconfirmed" => 1 },
                       {"phone"          => $$user_data{'phone'} },
                       {"phoneconfirmed" => 1 }
                    ]
                },
                {
                    'label' => 'Пароль',
                    'fields' => [
                       {"password"          => '' },
                       {"newpassword"       => '' }
                    ]
                },
                {
                    "label" => "Группы",
                    "fields" => [
                       { "groups" => $$user_data{'groups'} }
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

# Добавить пустой объект пользователя
# ( $user_id ) = $self->add();
sub add {
    my $self = shift;

    my ( $resp, $result, $data );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! || !$$data{'parent'} ) {
        # проверка существования родителя
        unless( $self->model('User')->_exists_in_user( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in user";
        }
    }

    unless ( @! ) {
        # создание пустого объекта пользователя
        $result = $self->model('User')->_empty_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавлением нового пользователя в EAV и таблицу users
# ( $user_id ) = $self->add_user( $data );
# $data = {
#     'place'       => 'place',                         # кладется в EAV
#     'country'     => 'country',                       # кладется в EAV
#     'birthday'    => '1972-01-06 00:00:00',           # кладется в EAV
#     'surname'     => 'test',                          # кладется в EAV
#     'name'        => 'name',                          # кладется в EAV
#     'patronymic'  => 'patronymic',                    # кладется в EAV
#     'groups'      => [1,2,100],                       # кладется в EAV может быть []
#     'email'       => 'test@test.com',                 # кладется в users
#     'phone'       => '+7(999) 222-2222',              # кладется в users
#     'password'    => 'password',                      # кладется в users
#     'timezone'    => '10',                            # кладется в users
# }
sub add_user {
    my $self = shift;

    my ( $data, $salt, $resp, $result, $groups );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @!, "email '$$data{ email }' already used"; 
        }
        # проверяем, используется ли телефон другим пользователем
        elsif ( $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'} ) ) {
            push @!, "phone '$$data{ phone }' already used"; 
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
            unless ( @! ) {
                # получение соли из конфига
                $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

                # шифрование пароля
                $$data{'password'} = sha256( $$data{'password'}, $salt );
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

        $$data{'publish'}     = $$data{'status'};
        $$data{'patronymic'}  = '' unless $$data{'patronymic'};
        $$data{'place'}       = '' unless $$data{'place'};
        $$data{'avatar'}      = '' unless $$data{'avatar'};
        $$data{'groups'}      = '' unless $$data{'groups'};

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
# $self->add_by_email( $data );
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

    my ( $groups, $data, $salt, $resp, $result, $data_eav, $user );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @!, "email '$$data{ email }' already used"; 
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
            unless ( @! ) {
                # получение соли из конфига
                $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

                # шифрование пароля
                $$data{'password'} = sha256( $$data{'password'}, $salt );
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
# $self->add_by_phone( $data );
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

    my ( $data, $resp, $result, $data_eav, $user, $groups, $salt );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'} ) ) {
            push @!, "phone '$$data{ phone }' already used"; 
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
            unless ( @! ) {
                # получение соли из конфига
                $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

                # шифрование пароля
                $$data{'password'} = sha256( $$data{'password'}, $salt );
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
# $self->save( $data );
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

    my ( $data, $salt, $resp, $groups, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        unless ( $$data{'phone'} || $$data{'email'} ) {
            push @!, 'No email and no phone';
        }
        elsif ( $$data{'password'} && !$$data{'newpassword'} && !scalar(@!) ) {
            push @!, 'No newpassword';
        }
        elsif ( !$$data{'password'} && $$data{'newpassword'} ) {
            push @!, 'No password';
        }
        elsif ( $$data{'password'} && $$data{'password'} eq $$data{'newpassword'} ) {
            push @!, 'Password and newpassword are the same';
        }

        unless ( @! ) {
            # проверяем, используется ли емэйл другим пользователем
            if ( $$data{'email'} && $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'}, $$data{'id'} ) ) {
                push @!, "email '$$data{ email }' already used"; 
            }
            # проверяем, используется ли телефон другим пользователем
            elsif ( $$data{'phone'} && $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'}, $$data{'id'} ) ) {
                push @!, "phone '$$data{ phone }' already used"; 
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
        }
    }

    unless ( @! ) {
        if ( $$data{'password'} ) {
            # получение соли из конфига
            $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

            # шифрование пароля
            $$data{'password'} = sha256( $$data{'newpassword'}, $salt );
        }

        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }
        else {
            $$data{'birthday'}    = '';
        }

        $$data{'time_access'} = 'now';
        $$data{'time_update'} = 'now';
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
# $data = {
# $self->toggle( $data );
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
#}
sub toggle {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table( 'users', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $$data{'table'}     = 'users';
            $$data{'fieldname'} = 'publish';
            $$data{'value'}     = $$data{'status'} ? 'true' : 'false';
            $toggle = $self->model('Utils')->_toggle( $data );
            push @!, "Could not toggle User '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удаление пользователя
# $self->delete( $data );
# $data = {
# 'id'    - id записи
#} 
sub delete {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

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