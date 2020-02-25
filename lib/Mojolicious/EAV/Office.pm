package Mojolicious::EAV::Office;

use parent 'Mojolicious::EAV::Base';
use strict;
use warnings;

sub RefreshView {
    my ( $Self ) = @_;

    $Self->{dbh}->do("SELECT refresh_pbd_company_view()");
    $Self->{dbh}->do("select refresh_manual_eav_view()" );

    return 1;
}

1;
