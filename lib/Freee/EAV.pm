package Freee::EAV;

use strict;
use warnings;

sub new {
    my $self = shift;
    my $type = shift;

    my $loc   = "Freee/EAV/$type\.pm";
    my $class = "Freee::EAV::$type";

    require $loc;

    my $p = $_[0];
    $p = {} if !ref( $p ) || ref( $p ) ne 'HASH';
    # $p->{Type} = lc( $type );
    $p->{Type} = $type;

    return $class->new( $p );               
}

1;
