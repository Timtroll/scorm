package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

sub index {
    my ($self);
    $self = shift;

    my ($status, $responce, $lock);

    open(LOCK, "$FindBin::Bin/../log/deploy.flock") or $lock = 1;
    close (LOCK);
    if ($lock) {
        $status = 'fail';
        $lock = 'Deploy working now';
    }
    else {
        $responce = `/usr/bin/flock -x -w 120 $FindBin::Bin/../log/deploy.lock -c \"$FindBin::Bin/../deploy.sh\" > $FindBin::Bin/../log/deploy.log &`;
        $status = 'ok';
    }

    $self->render(
        'json' => {
            status    => $status,
            message   => $lock
        }
    );
}

1;