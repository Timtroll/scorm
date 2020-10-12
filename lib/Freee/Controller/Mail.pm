package Freee::Controller::Mail;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;

    $self->render(
        'template'  =>'mail/email',
        'title'     => 'форма'
    );
}

sub send {
    my $self = shift;

    $self->render(
        'template'  =>'mail/send',
        'title'     => 'отправлено'
    );
}

1;