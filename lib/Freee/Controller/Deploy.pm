package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

sub index {
    my ($self);
    $self = shift;
print "--\n";
    my ($status, $responce, $mess, $root);
    $root = "$FindBin::Bin/../log/flock";
print "$root/log/flock\n========\n";
    if (-e "$root/log/flock") {
        $status = 'fail';
        $mess = 'Deploy working now';
    }
    else {
        $responce = `/usr/bin/flock -x -w 180 $root/log/deploy.lock -c \"$root/deploy.sh\" > $root/deploy.log &`;
print "/usr/bin/flock -x -w 180 $root/log/deploy.lock -c \"$root/deploy.sh\" > $root/deploy.log \&\n";
        $status = 'ok';
    }

    $self->render(
        'json' => {
            status      => $status,
            responce    => $responce,
            mess        => $mess,
            lock        => "$root/log/flock",
            dir         => $FindBin::Bin
        }
    );
}

1;