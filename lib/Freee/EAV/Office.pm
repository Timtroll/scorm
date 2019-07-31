package Kernel::Modules::EAV::Office;

use base Kernel::Modules::EAV::Base;

sub new {
    my $class = shift;
    my $params = shift;

    my $base = Kernel::Modules::EAV::Base->new();

    my $obj = { _base => $base };
    if ( exists( $$params{id} ) ) {
        $obj->{_item} = $base->_get( $$params{id} );
    } elsif ( exists( $$params{parent} ) && exists( $$params{type} ) ) {
        $obj->{_item} = $base->_create( $params );
    };

    my $self = bless $obj, $class;

    return $self;
};

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method = substr( $AUTOLOAD, rindex( $AUTOLOAD, '::' ) + 2 );
    
    return 1 if $method eq 'DESTROY';

    if ( defined $self->{_item}->{type} && $method && exists( $self->{_base}->{Fields}->{ $self->{_item}->{type} }->{ $method } ) ) {
        if ( scalar( @_ ) ) {
            return $self->_store( $method, @_ );
        } else {
            return $self->{_item}->{ $method } if exists( $self->{_item}->{ $method } );
            return $self->_get_field( $method );
        };
    } else {
        return $self->$method( @_ );
    };
};

1;