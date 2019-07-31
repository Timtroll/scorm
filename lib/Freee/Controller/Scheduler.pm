package Freee::Controller::Scheduler;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::Dbase;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'index'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'edit'
        }
    );
}

sub move {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'move'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'delete'
        }
    );
}

1;