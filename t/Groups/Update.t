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

my $data = {
    id          => 3,
    name        => 'name3',
    label       => 'label3',
    value       => 'value',
    required    => 0,
    readOnly    => 0,
    editable    => 1,
    removable   => 0
};

my $result = { status => 'ok'};

$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


# отрицательные тесты

# указан не сущуствующий id
$data->{ id } = 404;

$result = { message => "Can't find row for updating", status => "fail" };

$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


# не указан label
$data->{ id } = 3;
$data->{ label } = undef;

$result = { message => "Required fields do not exist", status => "fail" };

$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


done_testing();


