package Freee::Controller::Upload;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use common;

sub index {
    my $self = shift;

    warn "it works!";

    $self->render(
        'json'    => {
            'controller'    => 'upload',
            'route'         => 'index',
            'status'        => 'ok'
        }
    );
}