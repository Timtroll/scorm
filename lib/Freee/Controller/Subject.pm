package Freee::Controller::Subject;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

# use Freee::Helpers::TableObj;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'index',
            'params'        => $self->req->params->to_hash,
            'test'          => $test
        }
    );
}

sub list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'list',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'add',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'edit',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'save',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'activate',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'hide',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Subject',
            'route'         => 'delete',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;