package Freee::Controller::Forum;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'index'
        }
    );
}

sub listthemes {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'listthemes'
        }
    );
}

sub theme {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'theme'
        }
    );
}

sub addtext {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'addtext'
        }
    );
}

sub deltext {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'deltext'
        }
    );
}

1;