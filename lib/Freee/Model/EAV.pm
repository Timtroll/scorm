package Freee::Model::EAV;

use strict;
use warnings;

use Mojo::Base -base;
use Scalar::Util 'weaken';

use Data::Dumper;
use DDP;
our @EXPORT_OK = qw( AUTOLOAD );

has 'eav';

sub new {
    state $Self;
    my $Class = shift;

    if ( !defined( $Self ) ) {
        $Self = bless {}, __PACKAGE__;
        $Self->_init();
        return $Self if ( !defined( $Class ) );
    }

    # my $Other = bless { Type => $_[0]->{Type} }, $Class;
    # $Self->_init_copy( $Other, $_[0] );
    # return $Other if exists( $_[0]->{PreventCreate} ) && $_[0]->{PreventCreate};
    # return defined( $Other->_InitThisItem( $_[0] ) ) ? $Other : undef();

####################
    # my $class = shift;

    # if (ref $class && $class->isa(__PACKAGE__)) {
    #     scalar( @_ ) == 1 ? $_[0]->{eav} = $class->{eav} : push @_, eav => $class->{eav};
    # }

    # my $self = $class->SUPER::new(@_);
    # weaken $self->{eav};

    # return $self;
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $Self = shift;
    my $method = substr( $AUTOLOAD, rindex( $AUTOLOAD, '::' ) + 2 );

    return 1 if $method eq 'DESTROY';

    if (
        exists( $Self->{Fields}->{ $Self->{Type} }->{ $method } ) ||
        exists( $Self->{ItemFields}->{ $method } ) ||
        ( exists( $Self->{_item} ) && exists( $Self->{_item}->{ $method } ) ) ||
        exists( $Self->{Fields}->{ 'Default' }->{ $method } )
    ) {
        if ( scalar( @_ ) ) {
            return $Self->_store( $method, @_ );
        }
        elsif ( exists( $Self->{_item} ) ) {
            return $Self->{_item}->{ $method } if exists( $Self->{_item}->{ $method } );
            return $Self->_get_field( $method );
        }
        else {
            return undef();
        };
    }
    else {
#        return $Self->$method( @_ );
    }
}

sub _init {
    my $Self = shift;

    # $Self->{DBObject} = $Kernel::OM->Get('Kernel::System::DB');
    # $Self->{DBObject}->Connect() unless $Self->{DBObject}->{dbh};
    # $Self->{dbh} = $Self->{DBObject}->{dbh};

    # my $sth = $Self->{dbh}->prepare( 'SELECT * FROM "public"."EAV_fields"' );
    # $sth->execute();
    # my $fields = $sth->fetchall_arrayref({});
    # $sth->finish();

    # $Self->{FieldsAsArray} = $fields;
    # $Self->{Fields} = {};
    # foreach my $field ( @$fields ) {
    #     $Self->{Fields}->{ $field->{set} }->{ $field->{alias} } = $field;
    #     $Self->{FieldsById}->{ $$field{id} } = $field;
    # };

    # $Self->{ItemFields} = { map { ( $_, 1 ) } ( 'id', 'publish', 'import_id', 'type', 'import_type', 'title', 'date_created', 'date_updated', 'parent', 'has_childs' ) } ;

    # $Self->{DataTables} = {
    #     int => [ '"public"."EAV_data_int4"', '"EAV_data_int4_pkey"' ],
    #     string => [ '"public"."EAV_data_string"', '"EAV_data_string_pkey"' ],
    #     boolean => [ '"public"."EAV_data_boolean"', '"EAV_data_boolean_pkey"' ],
    #     datetime => [ '"public"."EAV_data_datetime"', '"EAV_data_datetime_pkey"' ]
    # };

    # $sth = $Self->{dbh}->prepare( 'SELECT i.* FROM "public"."EAV_links" AS l INNER JOIN "public"."EAV_items" AS i ON i."id" = l."id" WHERE l."parent" = 0 AND l."distance" = 0' );
    # $sth->execute();
    # $Self->{_roots} = $sth->fetchall_arrayref({});
    # $Self->{Roots} = {};

    # my $Base = __PACKAGE__;
    # $Base =~ s/::Base//;
    # my %Loaded;

    # foreach my $Type ( keys %{ $Self->{Fields} } ) {
    #     my $T = ucfirst($Type);
    #     my $Class = $Base.'::'.$T;
    #     if( !defined($Loaded{$Type}) ){
    #         $Kernel::OM->Get('Kernel::System::Main')->Require( $Class );
    #         $Loaded{$Type} = 1;
    #     }
    #     my ( $id ) = ( map { $_->{id} } grep { $_->{import_type} eq $Type } @{ $Self->{_roots} } );
    #     if ( !defined( $id ) ) {
    #         if ( $Type eq 'Default' ) {
    #              $Self->{Roots}->{ $Type } =  undef();
    #         } else {
    #              my $obj = $Class->new({ Type => $Type, parent => 0, publish => \1, import_id => undef(), title => $T });
    #              $Self->{Roots}->{ $Type } = $obj;
    #         };
    #     } else {
    #         my $obj = $Class->new( { Type => $Type } );
    #         $obj->{_item} = $obj->_get( $id );
    #         $Self->{Roots}->{ $Type } = $obj;
    #     };
    # };
    # $Self->{Root} = $Self->{Roots}->{ $Self->{Type} } if exists( $Self->{Type} );
    # $sth->finish();

    # $Self->{CacheType}   = "EAV";
    # $Self->{CacheTTL}    = 60 * 60 * 24 * 30;

    # $Self->{LogObject}    = $Kernel::OM->Get('Kernel::System::Log');
    # $Self->{Debug}        = $Kernel::OM->Get('Kernel::Config')->Get('EAV::Debug') || 0;
};

sub check {
    my ($self, $name, $pass) = @_;
warn 'Model::EAV sub check()';

}

1;