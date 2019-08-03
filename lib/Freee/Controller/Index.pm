package Freee::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

use Freee::Helpers::PgEAV;

use Data::Dumper;

sub doc {
    my ($self);
    $self = shift;

# print Dumper( $self->delete_field(5) );

# print Dumper($self->create_field({
#     id      => 7,
#     title   => 'name',
#     alias   => 'название',
#     type    => 'string',
#     set     => 'user'
# }));

print Dumper( $self->list_fields() );

    $self->render(
        'template'    => 'index',
        'title'       => 'Описание роутов'
    );
}


1;