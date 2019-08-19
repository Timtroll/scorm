package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

sub index {
    my ($self);
    $self = shift;
print "--\n";
    my ($status, $responce, $mess);
print "$FindBin::Bin/../log/flock\n========\n";
    if (-e "$FindBin::Bin/../log/flock") {
        $status = 'fail';
        $mess = 'Deploy working now';
    }
    else {
        $responce = `/usr/bin/flock -w 180 $FindBin::Bin/../log/deploy.lock $FindBin::Bin/../deploy.sh > $FindBin::Bin/../deploy.log &`;
print "/usr/bin/flock -w 180 $FindBin::Bin/../log/deploy.lock $FindBin::Bin/../deploy.sh > $FindBin::Bin/../deploy.log &\n";
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