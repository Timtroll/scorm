package Freee::Controller::Accounting;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'index',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub search {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'search',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'add',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub stat {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'accounting',
            'route'         => 'stat',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;