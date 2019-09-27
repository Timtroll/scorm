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

#########################################
# положительные тесты

# нету поля parent
my $data = {
    parent      => 0,
    name        => 'name',
    label       => 'label',
    value       => 'value',
    required    => 0,
    readOnly    => 0,
    editable    => 1,
    removable   => 0,
    status      => 1
};
my $result = { id => '1', status => 'ok' };
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );

# поле parent = 0
# $data = { parent => '0',name => 'test2', label => 'test2'};
$data->{name} = 'test2';
$data->{label} = 'test2';
$result = {id => '2', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data )->status_is(200)->json_is( $result );

# поле parent != 0 и наследуется
$data = { parent => '1',name => 'test3', label => 'test3'};
$result = {id => '3', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data )->status_is(200)->json_is( $result );

$data = { parent => '1',name => 'test4', label => 'test4'};
$result = {id => '4', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data )->status_is(200)->json_is( $result );

#########################################
# отрицательные тесты

# нету поля name
$data = { parent => '0', label => 'test' };
$result = { message => "Required fields do not exist", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data )->status_is(200)->json_is( $result );

# наследование не от фолдера
$data = { parent => '3', name => 'test', label => 'test'};
$result = { message => "Wrong parent", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data )->status_is(200)->json_is( $result );

# наследование от не существующего элемента
$data = { parent => '404', name => 'test', label => 'test'};
$result = { message => "Wrong parent", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/settings/add' => form => $data  )->status_is(200)->json_is( $result );

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

