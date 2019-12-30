package Freee::Helpers::EAV;

use strict;
use warnings;

use base 'Mojolicious::Plugin';
use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    $app->helper( 'pg_dbh' => sub {
        # если в конфиге установлен test = 1 - подключаемся к тестово базе
        my $database = 'pg_main';
        $database = 'pg_main_test' if ($config->{'test'});
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

    #################################
    # Helper for RabbitMQ
    $app->helper( 'EAV' => sub {
        unless ($beans) {
        }

        return $beans;
    });

    # $app->helper( '_events' => sub {
    #     # state $events = Mojo::EventEmitter->new;
    #     return Mojo::EventEmitter->new;
    # });
}

1;
