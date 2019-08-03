package Freee::Controller::Scheduler;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'scheduler',
            'route'         => 'index'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'scheduler',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'scheduler',
            'route'         => 'edit'
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'scheduler',
            'route'         => 'save'
        }
    );
}

sub move {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'scheduler',
            'route'         => 'move'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'scheduler',
            'route'         => 'delete'
        }
    );
}

1;