package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    my ($status, $responce, $mess);
    if (-e '/usr/bin/flock') {
        $status = 'fail';
        $mess = 'Deploy working now';
    }
    else {
        $responce = `/usr/bin/flock -w 180 /home/troll/scorm/log/deploy.lock /home/troll/scorm/deploy.sh > /home/troll/scorm/log/deploy.log &`;
        $status = 'ok';
    }

    $self->render(
        'json' => {
            status  => $status,
            responce    => $responce,
            mess        => $status
        }
    );
}

1;