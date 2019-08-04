package Freee::Helpers::Rabbit;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::EventEmitter;
use Mojo::RabbitMQ::Client;
use Mojo::RabbitMQ::Client::Channel;


use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for RabbitMQ
    $app->helper( 'ampq' => sub {
        unless ($amqp) {
            $amqp = Mojo::RabbitMQ::Client->new( $config->{'ampq'}->{'url'} );
            # $amqp->on(
            #     open => sub {
            #         my ($client) = @_;
            #         warn "client connected";

            #         my $channel = Mojo::RabbitMQ::Client::Channel->new();
            #         $channel->catch(sub { warn 'Error on channel received'; });
            #         $channel->on(
            #             open => sub {
            #                 # Forward every message from browser to message queue
            #                 app->events->on(
            #                     mojochat => sub {
            #                         return unless $_[1]->[0] eq 'browser';

            #                         $channel->publish(
            #                             exchange    => 'mojo',
            #                             routing_key => '',
            #                             body        => $_[1]->[1],
            #                             mandatory   => 0,
            #                             immediate   => 0,
            #                             header      => {}
            #                         )->deliver();
            #                     }
            #                 );

            #                 # Create anonymous queue and bind it to fanout exchange named mojo
            #                 my $queue = $channel->declare_queue(exclusive => 1);
            #                 $queue->on(
            #                     success => sub {
            #                         my $method = $_[1]->method_frame;
            #                         my $bind   = $channel->bind_queue(
            #                             exchange    => 'mojo',
            #                             queue       => $method->queue,
            #                             routing_key => '',
            #                         );
            #                         $bind->on(
            #                             success => sub {
            #                                 my $consumer = $channel->consume(queue => $method->queue);

            #                                 # Forward every received messsage to browser
            #                                 $consumer->on(
            #                                     message => sub {
            #                                         app->events->emit( mojochat => ['amqp', $_[1]->{body}->payload] );
            #                                     }
            #                                 );
            #                                 $consumer->deliver();
            #                             }
            #                         );
            #                         $bind->deliver();
            #                     }
            #                 );
            #                 $queue->deliver();
            #             }
            #         );
            #         $channel->on(close => sub { warn 'Channel closed'; });
            #         $client->open_channel($channel);
            #     }
            # );
            $amqp->connect();
        }

        return $amqp;
    });

    $app->helper( 'events' => sub {
        # state $events = Mojo::EventEmitter->new;
        return Mojo::EventEmitter->new;
    });
}

1;
