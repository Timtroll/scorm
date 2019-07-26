package Freee;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Mojo::Log;

use Mojo::EventEmitter;
use Mojo::RabbitMQ::Client;
use Mojo::RabbitMQ::Client::Channel;

use common;
use validate;
use Data::Dumper;

$| = 1;
has [qw( websockets )];

# This method will run once at server start
sub startup {
    my $self = shift;

    my ( $host );
    # load database config
    $config = $self->plugin(Config => { file => rel_file('./freee.conf') });
    $log = Mojo::Log->new(path => $config->{'log'}, level => 'debug');

    # Configure the application
    $self->secrets($config->{secrets});
    $host = $config->{'host'};

    # set life-time fo session (second)
    $self->sessions->default_expiration($config->{'expires'});

    # prepare validate functions
    prepare_validate();

    # Router
    my $r = $self->routes;
    $r->post('/login')              ->to('auth#login');
    $r->any('/logout')              ->to('auth#logout');

    $r->any('/doc')                 ->to('index#doc');

    $r->any('/test')                ->to('websocket#test');
    $r->websocket('/channel')       ->to('websocket#index');

    my $auth = $r->under()          ->to('auth#check_token');
    $auth->any('/settings')         ->to('settings#index');

    $r->any('/*')                   ->to('index#index');
}

1;
