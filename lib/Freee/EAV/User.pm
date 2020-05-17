package Freee::EAV::User;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

use Data::Dumper;

sub StoreUser {
    my ( $self, $params ) = @_;

    return undef() unless $self->{_item};
    return undef() unless defined( $params );

    my $dataset = {};
    foreach my $key ( keys %$params ) {
        if ( ref( $params->{ $key } ) && ref( $params->{ $key } ) eq 'HASH' ) {
            $dataset->{ $key } = $params->{ $key }
        }
        else {
            $self->_store( $key, $params->{ $key } );
        }
    }

    $self->_MultiStore( $dataset ) if scalar( keys %$dataset );

    return 1
}

sub GetUser {
    my ( $self, $id ) = @_;

    return undef() unless $self->{_item};
    return undef() unless $id || $id != /^\d+$/ ;

    my $data = $self->_getAll( $id );

    return $data;
}

1;
