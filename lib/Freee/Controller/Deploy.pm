package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

sub index {
    my ($self);
    $self = shift;

    my ($status, $responce);
    $responce = `/usr/bin/flock -x -w 180 $FindBin::Bin/../log/deploy.lock -c \"$FindBin::Bin/../deploy.sh\" > $FindBin::Bin/../log/deploy.log &`;
    $status = 'ok';

    $self->render(
        'json' => {
            status      => $status,
            responce    => $responce,
        }
    );
}

1;