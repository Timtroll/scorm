package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;

sub index {
    my ($self);
    $self = shift;
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
    my ($self, );
    $self = shift;

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

    my ($data, $resp, $error, @mess);

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless ( @mess ) {
            # проверяем, - есть ли такой юзер

            # таблица users
            my $user_data = {
                'email'             => '',  # email пользователя
                'password'          => '',  # хеш пароля
                'time_create'       => '',  # время создания
                'time_access'       => '',  # время последней активности
                'time_update'       => '',  # время последих изменений
                'timezone'          => ''  # часовой пояс
            };

            # таблица users_social
            # my $user_data = {
            #     "user_id" int4 NOT NULL,
            #     "social" "public"."social" NOT NULL,
            #     "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
            #     "social_id",     => 123123123,
            #     "social_profile" => "{}"
            # };

            # таблица media (аватарка)
            my $media_data = {
                "path"      => 'local',
                "filename"  => 'local',
                "title"     => 'Название файла',
                "size"      => 'local',
#?                "type" varchar(32) COLLATE "default",
                "mime"      => 'local',
                "description"      => 'local',
                "order"      => 'local',
                "flags"     => 0
            };

            # таблицы EAV
            my $eav_data = {
            };

            # делаем запись в EAV
            my $user = Freee::EAV->new( 'User', { 'publish' => $$data{'status'} ? \1 : \0, 'parent' => 1 } );
            $user->StoreUser({
                'title' => join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) ),
                'User' => {
                    'Surname'       => $$data{'surname'},
                    'Name'          => $$data{'name'},
                    'Patronymic'    => $$data{'patronymic'},
                    'City'          => $$data{'city'},
                    'Country'       => $$data{'country'},
                    'Birthday'      => $$data{'birthday'},
                    'Phone'         => $$data{'phone'},
                    'Flags'         => 0,
                }
            });

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
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub add_by_email {
    my ($self);
    $self = shift;

    my ($data, $resp, $error, $result, $data_eav, $user, @mess);

    unless ( @mess ) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;
    }

    unless ( @mess ) {
        $$data{'time_create'} = $self->_get_time();
        $$data{'time_access'} = $self->_get_time();
        $$data{'time_update'} = $self->_get_time();

# print Dumper( $data );

        $data_eav = {
            'publish'     => $$data{'status'} ? \1 : \0, 
            'parent'      => 1,
            'email'       => $$data{'email'},
            'password'    => $$data{'password'},
            'time_create' => $$data{'time_create'},
            'time_access' => $$data{'time_access'},
            'time_update' => $$data{'time_update'},
            'timezone'    => $$data{'timezone'}
        };

        $user = Freee::EAV::User->new( 'User', $data_eav );
        # $user = Freee::EAV::User->new( $data_eav );
    }


#     unless ( @mess ) {
#         # $$data{'time_create'} = 1;
#         # $$data{'time_create'} = time();
#         $$data{'time_create'} = gmtime();
#         # $$data{'time_access'} = 1;
#         $$data{'time_access'} = gmtime();
#         # $$data{'time_access'} = gmtime();
#         # $$data{'time_access'} = 1;
#         $$data{'time_update'} = gmtime();
#         # $$data{'status'} = 1;
#         $$data{'eav_id'} = 123;
# warn Dumper( $$data{'time_create'} );
# warn Dumper( $$data{'time_access'} );
# warn Dumper( $$data{'time_update'} );
#         ( $result, $error ) = $self->_insert_user( $data );
#         push @mess, $error unless $result;
#     }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $result if $result;

    $self->render( 'json' => $resp );
}

sub save {
    my ($self);
    $self = shift;

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

    my ($toggle, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            $$data{'table'} = 'settings';
            $toggle = $self->_toggle( $data ) unless @mess;
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

    my ($data, $resp, @mess);
    $data = {};

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

1;