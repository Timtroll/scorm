package Kernel::System::EAV;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log',
);

sub new {
    my ( $Self, $Type, $Params ) = @_;
    return bless {}, $Self if scalar( @{ [ caller(1) ] } ) && @{ [ caller(1) ] }[0] eq 'Kernel::System::ObjectManager';

    if( $Type eq 'Auto' && defined( $Params->{id} ) ){
        $Type = _GetClassByID( $Params->{id} );
    }

    my $Class = __PACKAGE__ . '::' . $Type;

    $Kernel::OM->Get('Kernel::System::Main')->Require($Class);

    $Params = {} if !ref($Params) || ref($Params) ne 'HASH';
    $Params->{Type} = lc( $Type );

    return $Class->new( $Params );
}

sub _GetClassByID{
    my ( $ID ) = @_;

    my $CacheType = "EAVClass";
    my $CacheKey  = "ClassByItem::".$ID;
    my $TTL       = 60 * 60;
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    my $Type = $CacheObject->Get(
        Type => $CacheType,
        Key  => $CacheKey,
    );

    if( !$Type ){
        ( $Type ) = @{$Kernel::OM->Get('Kernel::System::DB')->SelectAll(
            SQL     => 'SELECT import_type FROM "EAV_items" WHERE id = ?',
            Bind    => [ \$ID ],
            Limit   => 1
        )};
        $Type = $Type->[0];

        $CacheObject->Set(
            Type => $CacheType,
            Key  => $CacheKey,
            Value => $Type,
            TTL   => $TTL,
        );
    }

    return ucfirst( $Type );
}

1;
