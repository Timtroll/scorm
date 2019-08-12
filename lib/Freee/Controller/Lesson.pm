package Freee::Controller::Lesson;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'index',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub video {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'video',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub text {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'text',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub examples {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'examples',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub tasks {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'tasks',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub finished {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'finished',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;