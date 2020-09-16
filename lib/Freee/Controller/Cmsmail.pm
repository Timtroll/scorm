package Freee::Controller::Cmsmail;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Cmsmail',
            'route'         => 'index',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash,
            'test'          => $test
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Cmsmail',
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
            'controller'    => 'Cmsmail',
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
            'controller'    => 'Cmsmail',
            'route'         => 'save',
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
            'controller'    => 'Cmsmail',
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
            'controller'    => 'Cmsmail',
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
            'controller'    => 'Cmsmail',
            'route'         => 'delete',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;