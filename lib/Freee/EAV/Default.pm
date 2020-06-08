package Freee::EAV::Default;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

sub new {
    my ( $Class, %Params ) = @_;

    $Params{Type} = 'Default';
    my $Object = $Class->SUPER::new(\%Params);

    return $Object;
}

1;
