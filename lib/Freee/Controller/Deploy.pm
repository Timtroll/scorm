package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

sub index {
    my ($self);
    $self = shift;

    my ($status, $responce, $mess);
print "$FindBin::Bin/../log/flock\n========\n";

    if (-e "$FindBin::Bin/../log/flock") {
        $status = 'fail';
        $mess = 'Deploy working now';
    }
    else {
        $responce = `/usr/bin/flock -x -w 180 $FindBin::Bin/../log/deploy.lock -c \"$FindBin::Bin/../deploy.sh\" > $FindBin::Bin/../deploy.log &`;
print "/usr/bin/flock -x -w 180 $FindBin::Bin/../log/deploy.lock -c \"$FindBin::Bin/../deploy.sh\" > $FindBin::Bin/../deploy.log \&\n";
        $status = 'ok';
    }

    $self->render(
        'json' => {
            status      => $status,
            responce    => $responce,
            mess        => $mess,
            lock        => "$FindBin::Bin/../log/flock",
            dir         => $FindBin::Bin
        }
    );
}

1;