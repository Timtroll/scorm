use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
#use Data::Dumper;
#print(Dumper(\@INC));
my $t = Test::Mojo->new('Freee');

#положительные тесты

#нету поля lib_id
my $data = { name => 'core', label => 'core'};
my $result = {id => '1', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )->status_is(200)->json_is( $result );

#поле lib_id = 0
$data = { lib_id => '0',name => 'test2', label => 'test2'};
$result = {id => '2', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )->status_is(200)->json_is( $result );

#поле lib_id != 0 и наследуется
$data = { lib_id => '1',name => 'test3', label => 'test3'};
$result = {id => '3', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )->status_is(200)->json_is( $result );

$data = { lib_id => '1',name => 'test4', label => 'test4'};
$result = {id => '4', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )->status_is(200)->json_is( $result );


# отрицательные тесты

#нету поля name
$data = { lib_id => '0', label => 'test' };
$result = { message => "Required fields do not exist", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )->status_is(200)->json_is( $result );

#наследование не от фолдера
$data = { lib_id => '3', name => 'test', label => 'test'};
$result = { message => "Wrong lib_id", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )->status_is(200)->json_is( $result );

#наследование от не существующего элемента
$data = { lib_id => '404', name => 'test', label => 'test'};
$result = { message => "Wrong lib_id", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data  )->status_is(200)->json_is( $result );

done_testing();
