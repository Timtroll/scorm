package Freee::Controller::Exam;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'index',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub start {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'start',
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
            'controller'    => 'exam',
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
            'controller'    => 'exam',
            'route'         => 'save',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub finish {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'finish',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;