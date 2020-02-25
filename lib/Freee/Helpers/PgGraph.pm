package Freee::Helpers::PgGraph;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Mojolicious::EAV::User;
use Mojolicious::EAV::Location;
use common;

use Data::Dumper;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Postgress

    $app->helper( 'pg_dbh' => sub {
        # если в конфиге установлен test = 1 - подключаемся к тестовой базе
        my $database = 'pg_main';
        $database = 'pg_main_test' if ($config->{'test'});
print "===========";
        unless ($dbh) {
            $dbh = DBI->connect(
                $config->{'dbs'}->{'databases'}->{$database}->{'dsn'},
                $config->{'dbs'}->{'databases'}->{$database}->{'username'},
                $config->{'dbs'}->{'databases'}->{$database}->{'password'},
                $config->{'dbs'}->{'databases'}->{$database}->{'options'}
            );
        }
        $dbh->{errstr} = sub {
            print "Error received: $DBI::errstr\n";
        };

        return $dbh;
    });

    $app->helper( 'eav' => sub {
        my ($self, $type) = @_;

        my $obj;
        eval '
            $obj = Mojolicious::EAV::'.$type.'->new( $self->pg_dbh, @_ );
        ';
        # eval '
        #     $obj = Mojolicious::EAV::'.$type.'->new( $self->{dbh}, @_ );
        # ';
print "+++";
print $dbh;
print "---";
        return $obj;
    });
}

1;
