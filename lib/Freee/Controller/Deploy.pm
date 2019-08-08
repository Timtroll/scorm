package Freee::Controller::Deploy;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    my @command = (
        'pwd',
        'git checkout master',
        'git status',
        'git pull',

        'cd ./client/admin',
        'pwd',
    );

    my @responce;
    foreach (@command) {
        my $res = `$_`;
        push @responce, $res;
    }

    $self->render(
        'json'    => \@responce
    );
}




1;