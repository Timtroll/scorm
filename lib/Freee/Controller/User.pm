package Freee::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
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

    # $self->render(
    #     'json'    => {
    #         'controller'    => 'User',
    #         'route'         => 'index',
    #         'status'        => 'ok',
    #         'params'        => $self->req->params->to_hash
    #     }
    # );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'add',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'edit',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'save',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub move {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'move',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'activate',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'hide',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'User',
            'route'         => 'delete',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;