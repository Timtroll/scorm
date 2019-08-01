package Freee::Controller::Lesson;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'index'
        }
    );
}

sub video {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'video'
        }
    );
}

sub text {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'text'
        }
    );
}

sub examples {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'examples'
        }
    );
}

sub tasks {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'lesson',
            'route'         => 'tasks'
        }
    );
}

1;