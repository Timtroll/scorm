package Mojolicious::EAV::Default;

# use parent 'Kernel::System::EAV::Base';
use parent 'Mojolicious::EAV::Base';

use strict;
# our @ObjectDependencies = (
#     'Kernel::Config',
#     'Kernel::System::Cache',
#     'Kernel::System::DB',
#     'Kernel::System::Log',
# );

sub new {
    my ( $Class, %Params ) = @_;

    $Params{Type} = 'Default';
    my $Object = $Class->SUPER::new(\%Params);

    return $Object;
}

1;
