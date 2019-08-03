package Freee::Controller::Mentors;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'index'
        }
    );
}

sub setmentor {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'setmentor'
        }
    );
}

sub unsetmentor {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'unsetmentor'
        }
    );
}

sub tasks {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'tasks'
        }
    );
}

sub viewtask {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'viewtask'
        }
    );
}

sub addcomment {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'addcomment'
        }
    );
}

sub savecomment {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'savecomment'
        }
    );
}

sub setmark {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'mentors',
            'route'         => 'setmark'
        }
    );
}

1;