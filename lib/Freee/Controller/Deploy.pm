package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

sub index {
    my ($self);
    $self = shift;

    my ($token, $status, $responce, $lock);
    $token = $self->req->param('token');

    # check lock file
    open(LOCK, "$FindBin::Bin/../log/deploy.flock") or $lock = 1;
    close (LOCK);

    if (!$lock && ($self->config->{secrets}[0] eq $token)) {
        $responce = `/usr/bin/flock -x -w 120 $FindBin::Bin/../log/deploy.lock -c \"$FindBin::Bin/../deploy.sh\" > $FindBin::Bin/../log/deploy.log &`;
        $status = 'ok';
    }
    else {
        $status = 'fail';
        $lock = 'Deploy working now or token if fail';
    }

    $self->render(
        'json' => {
            status    => $status,
            message   => $lock
        }
    );
}

1;