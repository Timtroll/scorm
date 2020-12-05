package common;

use utf8;
use warnings;
use strict;

use Mojo::Home;
use IO::All;

binmode(STDOUT);
binmode(STDERR);

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $config $settings $codes $clear $tokens $log $routs $vfields $permissions $websockets $beans $dbh $FieldsAsArray $Fields $DataTables $FeildsById );

use Data::Dumper;

my $config = {};
our $settings = {};
our $codes = {};
my $tokens = {};
my $permissions = {};
my $websockets = {};
my $beans = {};
my $routs = {};
our $vfields = {};

# vars for Graph database
my $dbh = {};
my $FieldsAsArray = {};
my $Fields = {};
my $DataTables = {};
my $FeildsById = {};

my $log = '';

# for validate input and set errors
my $clear = {};

# BEGIN {
#     # set not verify ssl connection
#     IO::Socket::SSL::set_ctx_defaults(
#         'SSL_verify_mode' => 0 #'SSL_VERIFY_NONE'
#     );
#     $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = '0';
# };

@ISA = qw( Exporter );
@EXPORT = qw( &rel_file &read_file &write_file $config $settings $codes $clear $tokens $log $sockevnt $wsclients $routs $vfields $permissions $websockets $beans $dbh $FieldsAsArray $Fields $DataTables $FeildsById );
@EXPORT_OK = qw( &rel_file &read_file &write_file $config $settings $codes $clear $tokens $log $sockevnt $wsclients $routs $vfields $permissions $websockets $beans $dbh $FieldsAsArray $Fields $DataTables $FeildsById );

# Find and manage the project root directory
my $home = Mojo::Home->new;
$home->detect;

sub rel_file { $home->rel_file(shift); }

sub read_file {
    my ( $path ) = shift;

    my $data < io $path;

    return $data;
}

sub write_file {
    my ( $path, $option, $data ) = @_;

    # my $data < io $path;
    open ( FILE, '>', $path ) or push @!, "Can't open file $path";
        print FILE $data;
    close ( FILE );

    return @! ? undef : 1;
}

1;
