package Test;

use utf8;
use warnings;
use strict;

use DBI;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK );
use Data::Dumper;


our @ISA = qw( Exporter );
our @EXPORT = qw(
    &get_last_id_EAV &get_last_id_user &clear_db
);
our @EXPORT_OK = qw(
    &get_last_id_EAV &get_last_id_user &clear_db
);

# получение id последнего элемента EAV_items
# my $answer = get_last_id_EAV( $connect );
sub get_last_id_EAV {
    my $connect = shift;

    my $sth = $connect->prepare( 'SELECT max("id") AS "id" FROM "public"."EAV_items"' );
    $sth->execute();
    my $answer = $sth->fetchrow_hashref();

    return $$answer{'id'};
}

# получение id последнего пользователя
# my $answer = get_last_id_user( $connect );
sub get_last_id_user {
    my $connect = shift;

    my $sth = $connect->prepare( 'SELECT max("id") AS "id" FROM "public"."users"' );
    $sth->execute();
    my $answer = $sth->fetchrow_hashref();

    return $$answer{'id'};
}

# очистка тестовой таблицы
sub clear_db {
    my ( $test, $connect ) = @_;

    if ( $test ) {
        $connect->do('ALTER SEQUENCE "public".media_id_seq RESTART');
        $connect->do('TRUNCATE TABLE "public".media RESTART IDENTITY CASCADE');

        $connect->do('TRUNCATE TABLE "public"."EAV_data_string" RESTART IDENTITY CASCADE');

        $connect->do('TRUNCATE TABLE "public"."EAV_data_datetime" RESTART IDENTITY CASCADE');

        $connect->do('ALTER SEQUENCE "public".eav_items_id_seq RESTART');
        $connect->do('TRUNCATE TABLE "public"."EAV_items" RESTART IDENTITY CASCADE');

        $connect->do('TRUNCATE TABLE "public"."EAV_links" RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

1;