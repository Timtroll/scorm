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
    $app->helper( '_beans_init' => sub {
        unless ($beans) {
            $beans = Beanstalk::Client->new( $config->{'beans'} );
            $beans->connect();
        }

        return $beans;
    });

    $app->helper( '_events' => sub {
        # state $events = Mojo::EventEmitter->new;
        return Mojo::EventEmitter->new;
    });
}

1;
