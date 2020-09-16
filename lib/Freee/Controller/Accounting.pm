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
            'publish'        => 'ok',
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
            'publish'        => 'ok',
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
            'publish'        => 'ok',
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
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;