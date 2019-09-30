use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# положительные тесты

# изменение на фолдер
my $data = { id => '3', parent => '0', name => 'test', label => 'test'};
my $result = { status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )->status_is(200)->json_is( $result );

# изменение на наследование
$data = { id => '3', parent => '1', name => 'test', label => 'test'};
$result = { status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )->status_is(200)->json_is( $result );


# отрицательные тесты

# указан не сущуствующий id
$data = { id => '404', parent => '0', name => 'test', label => 'test'};
$result = { message => "Can't find row for updating", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )->status_is(200)->json_is( $result );

# не указан label
$data = { id => '3', parent => '0', name => 'test' };
$result = { message => "Required fields do not exist", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )->status_is(200)->json_is( $result );

# указан parent не на фолдер
$data = { id => '3', parent => '4', name => 'test', label => 'test' };
$result = { message => "Wrong parent", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )->status_is(200)->json_is( $result );

# указан не сущуствующий parent
$data = { id => '3', parent => '404', name => 'test', label => 'test' };
$result = { message => "Wrong parent", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )->status_is(200)->json_is( $result );

done_testing();