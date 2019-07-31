package Freee::Controller::Cmssubject;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::Dbase;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmssubject',
            'route'         => 'index'
        }
    );
}

sub addsubject {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmssubject',
            'route'         => 'addsubject'
        }
    );
}

sub editsubject {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmssubject',
            'route'         => 'editsubject'
        }
    );
}

sub activatesubject {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmssubject',
            'route'         => 'activatesubject'
        }
    );
}

sub hidesubject {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmssubject',
            'route'         => 'hidesubject'
        }
    );
}

sub deletesubject {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmssubject',
            'route'         => 'deletesubject'
        }
    );
}

1;