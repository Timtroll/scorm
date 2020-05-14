package Freee::EAV::Office;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

sub RefreshView{
    my ( $self ) = @_;

    $self->{dbh}->do("SELECT refresh_pbd_company_view()");
    $self->{dbh}->do("select refresh_manual_eav_view()" );

    return 1;
}

1;
