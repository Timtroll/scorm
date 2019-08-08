package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Cwd qw(getcwd);
use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    my $responce = `/usr/bin/flock -w 180 /var/tmp/deploy.lock /home/troll/workspace/scorm/deploy.sh &`;

    $self->render(
        'json'    => 'ok'
    );
}




1;