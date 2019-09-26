use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# положительные тесты

my $data = {
    name        => 'name',
    label       => 'label',
    value       => 'value',
    required    => 0,
    readOnly    => 0,
    editable    => 1,
    removable   => 0
};

my $result = { id => '1', status => 'ok' };

$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );

#
$data->{name} = 'name2';
$data->{label} = 'label2';

$result = {id => '2', status => 'ok'};

$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );

#
$data->{name} = 'name3';
$data->{label} = 'label3';

$result = {id => '3', status => 'ok'};

$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );

#
$data->{name} = 'name4';
$data->{label} = 'label4';

$result = {id => '4', status => 'ok'};

$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


# отрицательные тесты

# нету поля name

$data->{parent} = 0;
$data->{name} = undef;
$data->{label} = 'label5';

$result = { message => "Required fields do not exist", status => "fail" };

$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

