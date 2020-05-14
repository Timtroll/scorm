package Freee::EAV::User;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

use Data::Dumper;

sub store {
    my ($self, $data) = @_;

    warn "++ Here ++";
    warn Dumper $data;
    $self->_MultiStore( $data );
}

1;
