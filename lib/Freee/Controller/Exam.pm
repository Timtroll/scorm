package Freee::Controller::Exam;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'index'
        }
    );
}

sub list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'list'
        }
    );
}

sub start {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'start'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'edit'
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'save'
        }
    );
}

sub finish {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'exam',
            'route'         => 'finish'
        }
    );
}

1;