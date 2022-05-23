package Freee::Helpers::PgGraph;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;
# use experimental 'smartmatch';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Postgress

    $app->helper( 'pg_dbh' => sub {
        my $self = shift;

        # если в конфиге установлен test = 1 - подключаемся к тестовой базе
        my $database = 'pg_main';
        $database = 'pg_main_test' if ($config->{'test'});
        unless ($dbh) {
warn "db connect\n";
            $dbh = DBI->connect(
                $config->{'databases'}->{$database}->{'dsn'},
                $config->{'databases'}->{$database}->{'username'},
                $config->{'databases'}->{$database}->{'password'},
                $config->{'databases'}->{$database}->{'options'}
            );
        }
        $self->{errstr} = sub {
            warn "Error received: $DBI::errstr\n";
        };

        return $dbh;
    });


    ###################################################################
    # служебные
    ###################################################################

    # список полей
    # $self->list_fields();
    $app->helper( 'list_fields' => sub {
        my $self = shift;
        return $self->pg_dbh->selectall_arrayref('SELECT id, title, alias, type FROM "public"."EAV_fields"', { Slice=> {} } );
    });

    # создание полей
    # $self->create_field(
    # {
        #     id      => 1,
        #     alias   => 'theme',
        #     title   => 'Тема',
        #     type    => 'string',
        #     set     => 'user'
    # });
    $app->helper( 'create_field' => sub {
        my $self = shift;
        my $data = shift;
        return $self->pg_dbh->do( 'INSERT INTO "public"."EAV_fields" ("id", "title", "alias", "type", "set") VALUES '."( '$$data{id}', '$$data{title}', '$$data{alias}', '$$data{type}', '$$data{set}' ) RETURNING \"id\"" );
    });

    # update поля
    # $self->update_field(
    # {
    #     id      => 1,
    #     alias   => 'theme',
    #     title   => 'Тема',
    #     type    => 'string',
    #     set     => 'lesson'
    # }));
    $app->helper( 'update_field' => sub {
        my $self = shift;
        my $data = shift;
        return $self->pg_dbh->do('UPDATE "public"."EAV_fields" SET '.join( ', ', map { "$_='$$data{$_}'" } keys %$data )." WHERE id=$$data{id} RETURNING id") if $$data{id};
    });

    # удаление поля
    # $self->delete_field(5);
    $app->helper( 'delete_field' => sub {
        my $self = shift;
        my $id = shift;
        return $self->pg_dbh->do( 'DELETE FROM "public"."EAV_fields" WHERE "id"='.$id );
    });

    # очистка базы 
    # $self->tranc_bases();
    $app->helper( 'tranc_bases' => sub {
        my $self = shift;
        
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_boolean" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_datetime" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_int4" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_data_string" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_fields" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_items" RESTART IDENTITY' );
        $self->pg_dbh->do( 'ALTER SEQUENCE eav_items_id_seq RESTART' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_links" RESTART IDENTITY' );
        # $self->pg_dbh->do( 'TRUNCATE "public"."EAV_sets" RESTART IDENTITY' );
        $self->pg_dbh->do( 'TRUNCATE "public"."EAV_submodules_subscriptions" RESTART IDENTITY' );

        return 1;
    });
}

1;
