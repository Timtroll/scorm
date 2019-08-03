package Freee::Controller::Cmsitems;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'index'
        }
    );
}

sub listitems {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'listitems'
        }
    );
}

sub additem {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'additem'
        }
    );
}

sub edititem {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'edititem'
        }
    );
}

sub activateitem {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'activateitem'
        }
    );
}

sub hideitem {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'hideitem'
        }
    );
}

sub delitem {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cmsitems',
            'route'         => 'delitem'
        }
    );
}

1;