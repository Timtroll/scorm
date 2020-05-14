package Freee::EAV::Default;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

sub new {
    my ( $class, %params ) = @_;

    $params{Type} = 'Default';
    my $object = $class->SUPER::new(\%params);

    return $object;
}

1;
