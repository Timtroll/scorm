package Freee::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub doc {
    my ($self);
    $self = shift;

    $self->render(
        'template'    => 'index',
        'title'       => 'Описание роутов'
    );
}

sub fields {
    my ($self, $fields);
    $self = shift;

    $fields = $self->list_fields;
    $self->render(
        'json' => {
            'fields' => $fields
        }
    );
}


1;