package Freee::Controller::Mentors;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'index',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub setmentor {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'setmentor',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub unsetmentor {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'unsetmentor',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub tasks {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'tasks',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub viewtask {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'viewtask',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub addcomment {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'addcomment',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub savecomment {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'savecomment',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub setmark {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Mentors',
            'route'         => 'setmark',
            'publish'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;