use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# положительные тесты
# my $data = {id => '2', status => '1'};
# my $result = {status => 'ok'};

$t->post_ok('http://127.0.0.1:4444/groups/status' => form => { id => '3', status => '1'} )->status_is(200)->json_is( { status =>'ok' } );
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => { id => '3', status => '0'} )->status_is(200)->json_is( { status =>'ok' } );
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => { id => '3' } )->status_is(200)->json_is( { status =>'ok' } );

# отрицательные тесты

my $result1 = { message => "Can't find row for updating", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => { id => '404', status => '1'} )->status_is(200)->json_is( $result1 );

my $result2 = { message => "Need id for changing", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => { status => '3' } )->status_is(200)->json_is( $result2 );

my $result3 = { message => "New status is wrong", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/status' => form => { id => '3', status => '404' } )->status_is(200)->json_is( $result3 );

done_testing();
