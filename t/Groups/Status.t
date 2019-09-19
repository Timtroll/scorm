use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# положительные тесты

# status 1
my $data = { id => '3', status => '1'};
my $result = { status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => $data )->status_is(200)->json_is( { status =>'ok' } );

# status 0
$data = { id => '3', status => '0'};
$result = { status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => $data )->status_is(200)->json_is( { status =>'ok' } );

# status 0 по умолчанию
$data = {id => '3'};
$result = { status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => $data )->status_is(200)->json_is( { status =>'ok' } );


# отрицательные тесты

# id не существует
$data = { id => '404', status => '1'};
$result = { message => "Can't find row for updating", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => $data )->status_is(200)->json_is( $result );

# id не указан
$data = { status => '0'};
$result = { message => "Need id for changing", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => $data )->status_is(200)->json_is( $result );

# status >1
$data = { id => '3', status => '404'};
$result = { message => "New status is wrong", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => $data )->status_is(200)->json_is( $result );

done_testing();
