package common;

use utf8;
use warnings;
use strict;

use Mojo::Home;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $config $clear $tokens $log $routs $vfields $permissions $websockets $beans $dbh $FieldsAsArray $Fields $DataTables $FeildsById );

use Data::Dumper;

my $config = {};
my $tokens = {};
my $permissions = {};
my $websockets = {};
my $beans = {};
my $routs = {};
my $vfields = {};

# vars for Graph database
my $dbh = {};
my $FieldsAsArray = {};
my $Fields = {};
my $DataTables = {};
my $FeildsById = {};

my $log = '';

# for validate input and set errors
my $clear = {};

BEGIN {
    # set not verify ssl connection
    IO::Socket::SSL::set_ctx_defaults(
        'SSL_verify_mode' => 0 #'SSL_VERIFY_NONE'
    );
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = '0';
};

@ISA = qw( Exporter );
@EXPORT = qw( &rel_file $config $clear $tokens $log $sockevnt $wsclients $routs $vfields $permissions $websockets $beans $dbh $FieldsAsArray $Fields $DataTables $FeildsById );


# Find and manage the project root directory
my $home = Mojo::Home->new;
$home->detect;

sub rel_file { $home->rel_file(shift); }

1;
