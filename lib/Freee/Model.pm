package Freee::Model;

use Mojo::Loader qw(find_modules load_class);
use Mojo::Base -base;

use Carp qw/ croak /;

has modules => sub { {} };

sub new {
    state $self;
    my ($class, %args) = @_;

    $self = $class->SUPER::new(%args);
    for my $pm ( grep { $_ ne 'Freee::Model::Base' } find_modules('Freee::Model') ) {
        my $e = load_class( $pm );
        croak "Loading '$pm' failed: $e" if ref $e;
        my ($basename) = $pm =~ /Freee::Model::(.*)/;
        $self->modules->{$basename} = $pm->new( %args );
    }

    return $self;
}

sub get_model {
    my ($self, $model) = @_;

    return $self->modules->{$model} || croak "Unknown model '$model'";
}

1;