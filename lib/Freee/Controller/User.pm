package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

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
    $data = {
        'folder'    => 0,
        'id'        => $$user{'id'},
        'parent'    => 0,
        'tabs' => [ # Вкладки 
            {
            'label'     => 'Основные',
            'fields'    => [
                'surname'       => $$user{'surname'},   # Фамилия
                'name'          => $$user{'name'},      # Имя
                'patronymic'    => $$user{'patronymic'},# Отчество
                'city'          => $$user{'city'},      # город
                'country'       => $$user{'country'},   # страна
                'timezone'      => $$user{'timezone'},  # часовой пояс
                'birthday'      => $$user{'birthday'},  # дата рождения (в секундах)
                'status'        => $$user{'status'},    # активный / не активный пользователь
                'groups'        => $$user{'groups'},    # список ID групп
                'password'      => $$user{'password'},  # хеш пароля
                'avatar'        => $$user{'avatar'},
                'type'          => 3                    # тип
            ]
            },
            {
                'label' => 'Контакты',
                'fields' => [
                    'email'           => $$user{'email'},           # email пользователя
                    'emailconfirmed'  => $$user{'emailconfirmed'},  # email подтвержден
                    'phone'           => $$user{'phone'},           # номер телефона
                    'phoneconfirmed'  => $$user{'phoneconfirmed'},  # телефон подтвержден
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

    my ($data, $resp, @mess);
    $data = {
        'id'                => '',
        'surname'           => '',  # Фамилия
        'name'              => '',  # Имя
        'patronymic'        => '',  # Отчество
        'city'              => '',  # город
        'country'           => '',  # страна
        'timezone'          => '',  # часовой пояс
        'birthday'          => 0,   # дата рождения (в секундах)
        'email'             => '',  # email пользователя
        'emailconfirmed'    => 0,   # email подтвержден
        'phone'             => 0,   # номер телефона
        'phoneconfirmed'    => 0,   # телефон подтвержден
        'status'            => 0,   # активный / не активный пользователь
        'groups'            => [],  # список ID групп
        'password'          => '',  # хеш пароля
        'avatar'            => ''
    };

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub index {
    my ($self);
    $self = shift;

    my ($data, $resp, @mess);
    foreach (1..10) {
        push @$data,         {
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

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


sub activate {
    my ($self);
    $self = shift;

    my ($data, $resp, @mess);
    $data = {};

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub hide {
    my ($self);
    $self = shift;

    my ($data, $resp, @mess);
    $data = {};

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

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