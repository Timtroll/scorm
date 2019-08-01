package Freee::Controller::Tasks;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'index'
        }
    );
}

sub list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'list'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'edit'
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'save'
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'activate'
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'hide'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'tasks',
            'route'         => 'delete'
        }
    );
}

1;