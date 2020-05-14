package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;

use Data::Dumper;

sub edit {
    my ($self);
    $self = shift;

    my ($user, $data, $resp, @mess);
    $user = {
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

    # Так будет отдаваться на фронт:
    my $groups = [1];
    $data = {
        'id' => $$user{'id'},
        'tabs' => [ # Вкладки 
            {
                'label'     => 'Основные',
                'fields'    => [
                    { 'surname'       => $$user{'surname'} },       # Фамилия
                    { 'name'          => $$user{'name'} },          # Имя
                    { 'patronymic'    => $$user{'patronymic'} },    # Отчество
                    { 'place'         => $$user{'place'} },         # город
                    { 'country'       => $$user{'country'} },       # страна
                    { 'timezone'      => $$user{'timezone'} },      # часовой пояс
                    { 'birthday'      => $$user{'birthday'} },      # дата рождения (в секундах)
                    { 'status'        => $$user{'status'} },        # активный / не активный пользователь
                    { 'password'      => $$user{'password'} },      # пароль
                    { 'newpassword'   => $$user{'newpassword'} },   # пароль
                    { 'avatar'        => $$user{'avatar'} },
                    { 'type'          => 3 }                        # тип
                ]
            },
            {
                'label' => 'Контакты',
                'fields' => [
                    { 'email'           => $$user{'email'} },           # email пользователя
                    { 'emailconfirmed'  => $$user{'emailconfirmed'} },  # email подтвержден
                    { 'phone'           => $$user{'phone'} },           # номер телефона
                    { 'phoneconfirmed'  => $$user{'phoneconfirmed'} }   # телефон подтвержден
                ]
            },
            {
                "label" => "Группы",
                "fields" => [
                    { "groups" => $groups }  # список ID групп
                ]
            }
        ]
    };

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

        unless (@mess) {
            $user_data = {
#                 'id'                => '',
                'email'             => '',  # email пользователя
                'password'          => '',  # хеш пароля
                'time_create'       => '',  # время создания
                'time_access'       => '',  # время последней активности
                'time_update'       => '',  # время последих изменений
                'timezone'          => '',  # часовой пояс
            };
            $eav_data = {
#                 'id'                => $$data{'id'},
                'users_id'          => $$user_data{'id'},
                'surname'           => $$data{'surname'},       # Фамилия
                'name'              => $$data{'name'},          # Имя
                'patronymic'        => $$data{'patronymic'},    # Отчество
                'city'              => $$data{'city'},          # город
                'country'           => $$data{'country'},       # страна
                'birthday'          => $$data{'birthday'},      # дата рождения (в секундах)
                'emailconfirmed'    => $$data{'emailconfirmed'},# email подтвержден
                'phone'             => $$data{'phone'},         # номер телефона
                'phoneconfirmed'    => $$data{'phoneconfirmed'},# телефон подтвержден
                'status'            => $$data{'status'},        # активный / не активный пользователь
                'groups'            => [],                      # список ID групп
                'avatar'            => $$data{'avatar'}
            };

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
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub index {
    my ($self);
    $self = shift;

    my ($data, $resp, @mess);
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

    my @data;
    foreach (1..10) {
        push @data, {
            'id'                => $_,
            'surname'           => 'Фамилия',           # Фамилия
            'name'              => 'Имя',               # Имя
            'patronymic'        => 'Отчество',          # Отчество
            'city'              => 'Санкт-Петербург',   # город
            'country'           => 'Россия',            # страна
            'timezone'          => '+3',                # часовой пояс
            'birthday'          => 123132131,           # дата рождения (в секундах)
            'email'             => 'username_'.$_.'@ya.ru',    # email пользователя
            'emailconfirmed'    => 1,                   # email подтвержден
            'phone'             => 79312445646,         # номер телефона
            'phoneconfirmed'    => 1,                   # телефон подтвержден
            'status'            => 1,                   # активный / не активный пользователь
            'groups'            => [1, 2, 3],           # список ID групп
            'password'          => 'khasdf',            # хеш пароля
            'avatar'            => 'https://thispersondoesnotexist.com/image'
        };
    }
    $data->{'body'} = \@data;
    $data->{'settings'}->{'page'}->{'total'} = scalar(@data);

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $data if $data;

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