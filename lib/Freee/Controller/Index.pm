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


1;