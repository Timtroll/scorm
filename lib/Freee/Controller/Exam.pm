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
            'status'        => 'ok',
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
            'controller'    => 'exam',
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
            'controller'    => 'exam',
            'route'         => 'save',
            'status'        => 'ok',
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
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;