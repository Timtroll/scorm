package Mojolicious::EAV::Default;

use parent 'Mojolicious::EAV::Base';

use strict;

sub new {
    my ( $Class, %Params ) = @_;

    $Params{Type} = 'Default';
    my $Object = $Class->SUPER::new(\%Params);

    return $Object;
}

1;
