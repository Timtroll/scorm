package Freee::Controller::Websocket;

use open qw(:utf8);
binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;

use Data::Dumper;

use common;

sub index {
	my ($self);
	$self = shift;

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
				send_ws_connection($msg->{'user'}, "\{\"user\":\"$msg->{'user'}\",\"data\":\"Connected\"\}");
			}
		},
	);
}

sub test {
	my ($self, $string, $user);
	$self = shift;

	$user = $self->req->json->{'user'} ? $self->req->json->{'user'} : undef;

	if ( (keys %{$self->req->json} > 1) && ($user) ) {
		$string = encode_json($self->req->json);
		utf8::decode($string);
		send_ws_connection($user, $string);

		$self->render(json => $string);
	}
	else {
		$self->render(json => {"error" => "No socket for 'user' or empty data"});
	}
}

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
