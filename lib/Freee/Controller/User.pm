package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use Data::Dumper;
use Mojo::JSON qw( decode_json encode_json );
use Digest::SHA qw( sha256_hex );
use DBI qw(:sql_types);
use common;

use Data::Dumper;

# список юзеров по группам (обязательно id группы)
# $self->index($data)
# $data = { 
#   id - Id группы
#   publish - показывать группы только с этим статусом
#   page - вывести список начиная с этой страницы ( по умолчанию 1 )
# }
sub index {
    my $self = shift;

    my ( $data, $list, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};
        $$data{'limit'}  = $settings->{'per_page'};
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
                        {"login"      => $$user_data{'login'} },
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
                       {"emailconfirmed" => 0 },
                       {"phone"          => $$user_data{'phone'} },
                       {"phoneconfirmed" => 0 }
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
                       { "groups" => $$user_data{'groups'} ? decode_json( $$user_data{'groups'} ) : [] }
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

# Добавить пустой объект пользователя,
# после добавления пустышки должен вызываться сразу роут /user/edit
# Добавляется новый пользователь в EAV и таблицу users
# $self->add();
# возвращается:
#   id пользователя:
#   eav_id пользователя:
sub add {
    my $self = shift;

    my ( $resp, $id, $eav_id );

    # создание пустого объекта пользователя
    ( $id, $eav_id ) = $self->model('User')->_empty_user();

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

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
#     'place'             => 'Санкт-Петербург',   # город
#     'country'           => 'Россия',            # страна
#     'timezone'          => '+3',                # часовой пояс
#     'birthday'          => 1598723713,          # дата рождения (в секундах)
#     'email'             => 'username@ya.ru',    # email пользователя
#     'emailconfirmed'    => 1,                   # email подтвержден
#     'phone'             => 79312445646,         # номер телефона
#     'phoneconfirmed'    => 1,                   # телефон подтвержден
#     'publish'            => 1,                   # активный / не активный пользователь
#     'groups'            => [1, 2, 3],           # список ID групп
#     'password'          => 'khasdf',            # хеш пароля
#     'avatar'            => 'https://thispersondoesnotexist.com/image'
# };
sub save {
    my $self = shift;

    my ( $data, $salt, $resp, $groups, $result );

    # проверка данных
    $data = $self->_check_fields();
p $data;

    unless ( @! ) {
        if ( $$data{'password'} && !$$data{'newpassword'} ) {
            push @!, 'Empty newpassword';
        }
        elsif ( !$$data{'password'} && $$data{'newpassword'} ) {
            push @!, 'Empty password';
        }
        elsif ( $$data{'password'} && $$data{'password'} ne $$data{'newpassword'} ) {
            push @!, 'Password and newpassword are not the same';
        }

        unless ( @! ) {
            # проверяем, используется ли логин другим пользователем
            if ( $$data{'login'} && $self->model('Utils')->_exists_in_table('users', 'login', $$data{'login'}, $$data{'id'} ) ) {
                push @!, "login '$$data{ login }' already used"; 
            }
            # проверяем, используется ли емэйл другим пользователем
            elsif ( $$data{'email'} && $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'}, $$data{'id'} ) ) {
                push @!, "email '$$data{ email }' already used"; 
            }
            # проверяем, используется ли телефон другим пользователем
            elsif ( $$data{'phone'} && $self->model('Utils')->_exists_in_table('users', 'phone', $$data{'phone'}, $$data{'id'} ) ) {
                push @!, "phone '$$data{ phone }' already used"; 
            }

            unless ( @! ) {
                # проверка существования групп пользователя
                $groups = decode_json( $$data{'groups'} );
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
            $$data{'password'} = sha256_hex( $$data{'newpassword'}, $salt );
        }

        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }

        $data = {
            'id'     => $$data{'id'},
            'groups' => $$data{'groups'},
            'data_user' => {
                'publish'       => $$data{'status'} ? 'true' : 'false',
                'login'         => $$data{'login'},
                'email'         => $$data{'email'},
                'phone'         => $$data{'phone'},
                'password'      => $$data{'password'}
            },
            'data_eav' => {
                'publish'       => $$data{'publish'} ? 'true' : 'false',
                'birthday'      => $$data{'birthday'},
                'surname'       => $$data{'surname'}    // '',
                'name'          => $$data{'name'}       // '',
                'patronymic'    => $$data{'patronymic'} // '',
                'place'         => $$data{'place'}      // '',
                'country'       => $$data{'country'}    // 'RU',
                'import_source' => $$data{'avatar'}     // ''
            }
        };
warn Dumper('save controller');
        $result = $self->model('User')->_save_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# регистрация пользователя
# $self->registration( $data );
# $data = {
#     'id'                => 1,
#     'surname'           => 'Фамилия',           # Фамилия
#     'name'              => 'Имя',               # Имя
#     'patronymic'        => 'Отчество',          # Отчество
#     'place'             => 'Санкт-Петербург',   # город
#     'country'           => 'Россия',            # страна
#     'timezone'          => '+3',                # часовой пояс
#     'birthday'          => 1598723713,          # дата рождения (в секундах)
#     'email'             => 'username@ya.ru',    # email пользователя
#     'phone'             => 79312445646,         # номер телефона
#     'password'          => 'khasdf',            # хеш пароля
# };
sub registration {
    my $self = shift;

    my ( $data, $salt, $resp, $groups, $id, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        unless ( $$data{'phone'} || $$data{'email'} ) {
            push @!, 'No email or no phone';
        }
        elsif ( !$$data{'password'} ) {
            push @!, 'No password';
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
            # проверяем, используется ли логин другим пользователем
            elsif ( $$data{'login'} && $self->model('Utils')->_exists_in_table('users', 'login', $$data{'login'}, $$data{'id'} ) ) {
                push @!, "login '$$data{ login }' already used"; 
            }
        }
    }

    unless ( @! ) {
        if ( $$data{'password'} ) {
            # получение соли из конфига
            $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

            # шифрование пароля
            $$data{'password'} = sha256_hex( $$data{'password'}, $salt );
        }

        # переводим секунды в дату рождения
        if ( $$data{'birthday'} ) {
            $$data{'birthday'} = $self->model('Utils')->_sec2date( $$data{'birthday'} );
        }

# ?????????? почему [5] 
        $data = {
            'groups' => encode_json( [ 5 ] ),
            'data_user' => {
                'publish'       => 'false',
                'login'         => $$data{'login'},
                'email'         => $$data{'email'},
                'phone'         => $$data{'phone'},
                'password'      => $$data{'password'}
            },
            'data_eav' => {
                'publish'       => 'false',
                'birthday'      => $$data{'birthday'},
                'surname'       => $$data{'surname'}    // '',
                'name'          => $$data{'name'}       // '',
                'patronymic'    => $$data{'patronymic'} // '',
                'place'         => $$data{'place'}      // '',
                'country'       => $$data{'country'}    // 'RU',
                'import_source' => $$data{'avatar'}     // ''
            }
        };
        # добавляем пустышку с группой "Нераспределенные"
        ( $$data{'id'}, $$data{'eav_id'} ) = $self->model('User')->_empty_user( $data );

        # если пустышка добавлена успешно, сохраняем данные пользователя
        if ( $$data{'id'} && ! @! ) {
            # добавляем в пустышку регистрационные данные не меняя группу
            $result = $self->model('User')->_save_user( $data );
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}


# изменение поля на 1/0
# $data = {
# $self->toggle( $data );
#   'id'    => <id>,        - id записи 
#   'field' =>'<имя_поля>', - имя поля в таблице
#   'val'   1,              - 1/0
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
            $$data{'value'}     = $$data{'publish'} ? 'true' : 'false';
            $toggle = $self->model('User')->_toggle_user( $data );
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
#   'id' => <id>   - id записи
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