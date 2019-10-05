package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use FindBin;

# Деплой и сборка js приложения 
sub index {
    my ($self);
    $self = shift;

    my ($token, $status, $responce, $mess);
    $token = $self->req->param('token');

    if (!(-e "$FindBin::Bin/../log/deploy.lock") && ($self->config->{secrets}[0] eq $token)) {
        $responce = `/usr/bin/flock -x -w 120 $FindBin::Bin/../log/deploy.lock -c \"$FindBin::Bin/../deploy.sh\" > $FindBin::Bin/../log/deploy.log &`;
        $status = 'ok';
    }
    else {
        $status = 'fail';
        $mess = 'Deploy working now or token if fail';
    }

    $self->render(
        'json' => {
            status    => $status,
            message   => $mess
        }
    );
}

1;