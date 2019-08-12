package Freee::Controller::Lections;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

# use Freee::Helpers::TableObj;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'index',
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
            'controller'    => 'Lections',
            'route'         => 'add',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'edit',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'save',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub move {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'move',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'activate',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'hide',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Lections',
            'route'         => 'delete',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;