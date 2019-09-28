package Freee::Helpers::Utils;

use utf8;
use strict;
use warnings;

use base 'Mojolicious::Plugin';

use common;

sub register {
    my ($self, $app) = @_;

    $app->helper( '_inputComponents' => sub {
        return $config->{'inputComponents'};
    });
}

1;