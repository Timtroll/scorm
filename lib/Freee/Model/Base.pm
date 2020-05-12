package Freee::Model::Base;

use Mojo::Base -base;

has 'app';

sub new {
    state $self;
    my $class = shift;

    if (ref $class && $class->isa(__PACKAGE__)) {
        scalar( @_ ) == 1 ? $_[0]->{eav} = $class->{eav} : push @_, eav => $class->{eav};
    }

    $self = $class->SUPER::new(@_) unless defined $self; 

    return $self;
}

1;