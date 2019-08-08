package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::File;

use Freee::Mock::S
use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    # показываем все настройки
    $self->render(
        json    => $settings
    );
}

sub set_tab_list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_tab_list'
        }
    );
}

sub set_addtab {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_addtab'
        }
    );
}

sub set_savetab {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_savetab'
        }
    );
}

sub set_deletetab {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_deletetab'
        }
    );
}

sub set_add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_add'
        }
    );
}

sub set_save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_save'
        }
    );
}

sub set_delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_delete'
        }
    );
}

1;