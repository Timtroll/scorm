package Freee::Helpers;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Websocket
# ??????? нужно?

    #################################
    # Helper for RabbitMQ
    $app->helper(
        events => sub {
            state $events = Mojo::EventEmitter->new;
        }
    );

    #################################
    # Helper for Postgress
    $app->helper(
        list_fields => sub  {
            my $self = shift;
            my $items = $self->pg_main->selectrow_hashref('SELECT id, title, alias, type FROM "public"."EAV_fields" WHERE 1 = 1'); #, {Slice=>{}}, undef);
            return $items;
        }
    );
}

1;
