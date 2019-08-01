package Freee::Helpers::Rabbit;

use strict;
use warnings;

use Mojo::Pg::Database;
use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for RabbitMQ
    $app->helper( 'events' => sub {
        # state $events = Mojo::EventEmitter->new;
        return Mojo::EventEmitter->new;
    });
}

1;
