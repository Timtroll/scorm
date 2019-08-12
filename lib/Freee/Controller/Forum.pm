package Freee::Controller::Forum;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'index',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub listthemes {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'listthemes',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub theme {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'theme',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub addtext {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'addtext',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub deltext {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'deltext',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;