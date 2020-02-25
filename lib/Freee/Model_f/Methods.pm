package Freee::Model::Methods;

use Mojo::Base 'Freee::Model::EAV';
use common;

sub do {
    my ($self) = @_;
    warn "Freee::Model::Methods sub do()";
use DDP;
    warn p $dbh;
}

1;