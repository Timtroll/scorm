package Freee;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::DefaultHelpers;
use Mojolicious::Plugin::Config;
use Mojolicious::Plugin::Database;
use Mojo::Log;

use Freee::Helpers;
# use Mojo::Pg;

use common;
use validate;
use Data::Dumper;

use DBD::Pg;
use DBI;

$| = 1;

has [qw( messages )];

# This method will run once at server start
sub startup {
    my $self = shift;

    # register Helpers
    $self->plugin('Freee::Helpers');

    # load config
    $config = $self->plugin(Config => { file => rel_file('./freee.conf') });
    $log = Mojo::Log->new(path => $config->{'log'}, level => 'debug');

    # Configure the application
    $self->secrets($config->{secrets});
print "$config->{'host'}\n";

    # set life-time fo session (second)
    $self->sessions->default_expiration($config->{'expires'});

    # postgress connection
    $self->plugin('database', $config->{'dbs'});

    # prepare validate functions
    prepare_validate();

    # Router
    my $r = $self->routes;
    $r->post('/login')              ->to('auth#login');
    $r->any('/logout')              ->to('auth#logout');

    $r->any('/doc')                 ->to('index#doc');

    $r->any('/fields')              ->to('index#fields');

    my $auth = $r->under()          ->to('auth#check_token');
    $auth->any('/settings')         ->to('settings#index');

    $r->any('/*')                   ->to('index#index');
}

1;
