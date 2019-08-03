package Freee::Controller::Cms;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'index'
        }
    );
}

sub listpages {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'listpages'
        }
    );
}

sub addpage {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'addpage'
        }
    );
}

sub editpage {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'editpage'
        }
    );
}

sub activatepage {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'activatepage'
        }
    );
}

sub hidepage {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'hidepage'
        }
    );
}

sub deletepage {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'cms',
            'route'         => 'deletepage'
        }
    );
}


1;