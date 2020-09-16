package Freee::Controller::Scheduler;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'index',
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
            'controller'    => 'Scheduler',
            'route'         => 'add',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'edit',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'save',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub move {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'move',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'activate',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'hide',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Scheduler',
            'route'         => 'delete',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;