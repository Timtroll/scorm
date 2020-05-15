package Freee::Model;

use Mojo::Loader qw(find_modules load_class);
use Mojo::Base -base;
use Data::Dumper;
use Carp qw/ croak /;

has modules => sub { {} };

# конструктор
sub new {
    state $self;
    my ($class, %args) = @_;

    # создание класса через метод родителя mojo base
    $self = $class->SUPER::new( %args );

    # поиск и загрузка модулей через mojo loader
    for my $pm ( grep { $_ ne 'Freee::Model::Base' } find_modules('Freee::Model') ) {
        my $e = load_class( $pm );
        croak "Loading '$pm' failed: $e" if ref $e;
        my ( $basename ) = $pm =~ /Freee::Model::(.*)/;

        $self->modules->{$basename} = $pm->new( %args );
    }

    return $self;
}

# хэлпер для вывода
sub get_model {
    my ($self, $model) = @_;

    return $self->modules->{$model} || croak "Unknown model '$model'";
}

1;