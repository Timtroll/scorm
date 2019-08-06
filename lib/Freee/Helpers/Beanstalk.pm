package Freee::Helpers::Beanstalk;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Beanstalk::Client;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for RabbitMQ
    $app->helper( 'beans_init' => sub {
        unless ($beans) {
            $beans = Beanstalk::Client->new( $config->{'beans'} );
            $beans->connect();
        }

        return $beans;
    });

    $app->helper( 'events' => sub {
        # state $events = Mojo::EventEmitter->new;
        return Mojo::EventEmitter->new;
    });
}

1;
