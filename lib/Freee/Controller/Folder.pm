package Freee::Controller::Folder;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

# use Freee::Helpers::PgGraph;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'index'
        }
    );
}

sub list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'list'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'edit'
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'save'
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'activate'
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'hide'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'folder',
            'route'         => 'delete'
        }
    );
}

1;