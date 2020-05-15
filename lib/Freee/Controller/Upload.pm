package Freee::Controller::Upload;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use common;

sub index {
    my $self = shift;

    $self->render(
        'template' => 'upload',
        'format'   => 'html'
    );
}