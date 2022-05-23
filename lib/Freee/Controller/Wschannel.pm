package Freee::Controller::Wschannel;

use open qw(:utf8);
binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw( from_json );
use Mojo::File;
use File::Slurp::Unicode qw( slurp );

# use Mojo::EventEmitter;
# use Mojo::RabbitMQ::Client;
# use Mojo::RabbitMQ::Client::Channel;

use Data::Dumper;

use common;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'template'    => 'wschannel',
        'title'       => 'Описание роутов'
    );
}

sub type {
    my $self = shift;

    $self->inactivity_timeout(3600);

    $self->on(
        json => sub {
            my $ws = shift;
            my $msg = shift;

            if ($msg->{'user'}) {
                $websockets->{$self->tx->handshake->connection} = {
                    'connection' => $ws->tx,
                    'user' => $msg->{'user'}
                };
                send_ws_connection($msg->{'user'}, '{"user":"' . $msg->{'user'} . '","data":"Connected"}');
            }
        },
    );
##############
    # my $self = shift;

    my $type = $self->param("type");

    $self->app->log->debug("WebSocket opened: $type");

    # Increase inactivity timeout for connection a bit
    Mojo::IOLoop->stream($self->tx->connection)->timeout(100);

    my $id = Mojo::IOLoop->recurring(4 => sub {
        if ("offerer" eq $type) {
            if (-f "/tmp/sdp.answerer") {
                $self->app->log->debug("Sending sdp: to offerer from answerer");
                # my $txt = Mojo::File::slurp("/tmp/sdp.answerer");
                my $path = Mojo::File->new("/tmp/sdp.answerer");
                my $txt = $path->slurp;

                my $ref = from_json($txt);
                $self->send({json => $ref});
                unlink("/tmp/sdp.answerer");
                # Mojo::File::spurt(scalar localtime(time), "/tmp/sdp.offerer.sent");
                $path = Mojo::File->new("/tmp/sdp.offerer.sent");
                $path->spurt(scalar localtime(time));
            }

            foreach my $f (glob("/tmp/candidate.answerer.*")) {
                $self->app->log->debug("Sending $f: to offerer from answerer");
                # my $txt = Mojo::File::slurp($f);
                my $path = Mojo::File->new($f);
                my $txt = $path->slurp;

                my $ref = from_json($txt);
                $self->send({json => $ref});
                unlink($f);
            }
        }
        else {
            if (-f "/tmp/sdp.offerer") {
                # my $txt = Mojo::File::slurp("/tmp/sdp.offerer");
                my $path = Mojo::File->new("/tmp/sdp.offerer");
                my $txt = $path->slurp;

                my $ref = from_json($txt);
                $self->app->log->debug("Sending sdp: to answerer from offerer");
                $self->send({json => $ref});
                unlink("/tmp/sdp.offerer");
            }

            if (-f "/tmp/sdp.offerer.sent") {
                foreach my $f (glob("/tmp/candidate.offerer.*")) {
                    $self->app->log->debug("Sending $f: to answerer from offerer");
                    # my $txt = Mojo::File::slurp($f);
                    my $path = Mojo::File->new($f);
                    my $txt = $path->slurp;

                    my $ref = from_json($txt);
                    $self->send({json => $ref});
                    unlink($f);
                }
                unlink("/tmp/sdp.offerer.sent");
            }
        }
    });

    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->debug("msg: $msg: type: $type");
        my $ret = from_json($msg);

        if ($$ret{sender} && "offerer" eq $$ret{sender} && $$ret{sdp}) {
            # Mojo::File::spurt($msg, "/tmp/sdp.offerer");
            my $path = Mojo::File->new("/tmp/sdp.offerer");
            $path->spurt($msg);
        } 
        if ($$ret{sender} && "answerer" eq $$ret{sender} && $$ret{sdp}) {
            # Mojo::File::spurt($msg, "/tmp/sdp.answerer");
            my $path = Mojo::File->new("/tmp/sdp.answerer");
            $path->spurt($msg);
        }

        if ($$ret{sender} && $$ret{candidate}) {
            foreach my $suffix (qw(001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 end)) {
                if ("end" eq $suffix) {
                    $self->app->log->debug("We are OUT of candidate suffixes.");
                    last;
                }
                my $f = "/tmp/candidate.$$ret{sender}.$suffix";
                if (-f $f) {
                    next;
                }
                # Mojo::File::spurt($msg, $f);
	            my $path = Mojo::File->new($f);
	            $path->spurt($msg);
                last;
            }
        }
    });

    $self->on(finish => sub {
        my ($self, $code, $reason) = @_;
        $self->app->log->debug("WebSocket closed with status $code.");
        Mojo::IOLoop->remove($id);
        unlink("/tmp/sdp.$type");
    });
}

# sub test {
#     my ($self, $string, $user);
#     $self = shift;

#     $user = $self->req->json->{'user'} ? $self->req->json->{'user'} : undef;

#     if ( (keys %{$self->req->json} > 1) && ($user) ) {
#         $string = encode_json($self->req->json);
#         utf8::decode($string);
#         send_ws_connection($user, $string);

#         $self->render(json => $string);
#     }
#     else {
#         $self->render(json => {"error" => "No socket for 'user' or empty data"});
#     }
# }

sub send_ws_connection {
    my $user = shift;
    my $data = shift;

    map {
        if ($websockets->{$_}) {
            if ($websockets->{$_}->{'user'} eq $user) {
                $websockets->{$_}->{'connection'}->send($data);
            }
        }
    } (keys %{$websockets});
}

1;
