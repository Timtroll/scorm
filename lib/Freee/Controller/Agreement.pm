package Freee::Controller::Agreement;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'index'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'edit'
        }
    );
}

sub request {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'request'
        }
    );
}

sub reject {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'reject'
        }
    );
}

sub approve {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'approve'
        }
    );
}

sub comment {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'comment'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'agreement',
            'route'         => 'delete'
        }
    );
}

1;