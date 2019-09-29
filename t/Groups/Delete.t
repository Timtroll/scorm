use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};

# положительные тесты

my $data = {id => '2'};

my $result = { status => 'ok'};

$t->post_ok('http://127.0.0.1:4444/groups/delete' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );



# отрицательные тесты

# id не существует
$data->{ id } = 404;

$result = { message => "Can't find row for deleting", status => "fail" };

$t->post_ok('http://127.0.0.1:4444/groups/delete' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


# id не задан
$data->{ id } = undef;

$result = { message => "Could not id for deleting", status => "fail" };

$t->post_ok('http://127.0.0.1:4444/groups/delete' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


done_testing();


