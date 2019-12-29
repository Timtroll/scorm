package Kernel::System::EAV::Office;

use parent 'Kernel::System::EAV::Base';
use strict;
use warnings;

sub RefreshView{
    my ( $Self ) = @_;
    $Self->{dbh}->do("SELECT refresh_pbd_company_view()");

    return 1;
}

1;
