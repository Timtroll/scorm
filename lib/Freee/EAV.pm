package Freee::EAV;

use strict;
use warnings;

sub new {
    my ( $Self, $Type, $Params ) = @_;

    my $Class = __PACKAGE__ . '::' . $Type;
    my $xClass = $Class.'.pm';
    $xClass =~ s/\:\:/\//g;

    require $xClass;

    $Params = {} if !ref($Params) || ref($Params) ne 'HASH';
    # $Params->{Type} = lc( $Type );

    return $Class->new( $Params );
}

1;
