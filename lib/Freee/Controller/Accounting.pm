package Freee::Controller::Accounting;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'index'
        }
    );
}

sub search {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'search'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'add'
        }
    );
}

sub stat {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'stat'
        }
    );
}

1;