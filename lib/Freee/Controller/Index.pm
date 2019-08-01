package Freee::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub doc {
    my ($self);
    $self = shift;

print Dumper($self->list_fields);

    $self->render(
        'template'    => 'index',
        'title'       => 'Описание роутов'
    );
}


1;