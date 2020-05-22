package Freee::Helpers::PgUpdate;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Update

    # вводит данные о новом файле в таблицу media
    # my $true = $self->_insert_media( $data );
    # возвращает true/false
    $app->helper( '_insert_media' => sub {
        my ( $self, $data ) = @_;

        my $sth = $self->pg_dbh->prepare( 'SELECT table_name FROM information_schema.columns WHERE table_schema = ?' );
        $sth->bind_param( 1, 'public' );
        my $result = $sth->execute();
        warn $result;
        return $result;
    });
}

1;
