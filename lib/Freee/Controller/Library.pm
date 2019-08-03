package Freee::Controller::Library;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'index'
        }
    );
}

sub list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'list'
        }
    );
}

sub search {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'search'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'edit'
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'save'
        }
    );
}

sub upload {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'upload'
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'activate'
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'hide'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'library',
            'route'         => 'delete'
        }
    );
}

1;