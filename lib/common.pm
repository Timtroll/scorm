package common;

use utf8;
use warnings;
use strict;

use Mojo::Home;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $config $clear $tokens $log $routes $permissions);

use Data::Dumper;

our $config = {};
our $tokens = {};
our $routes = {};
our $permissions = {};
our $log = '';

# for validate input and set errors
our $clear = {};

BEGIN {
    # set not verify ssl connection
    IO::Socket::SSL::set_ctx_defaults(
        'SSL_verify_mode' => 0 #'SSL_VERIFY_NONE'
    );
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = '0';
};

@ISA = qw( Exporter );
@EXPORT = qw( &rel_file &error $config $clear $tokens $log $sockevnt $wsclients $routes $permissions);

# Find and manage the project root directory
my $home = Mojo::Home->new;
$home->detect;

sub rel_file { $home->rel_file(shift); }

sub error {
    my $self = shift;

    $self->res->code(301);
    $self->redirect_to('/500.html');
    return;
}

1;
