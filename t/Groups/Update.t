use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# положительные тесты

$t->post_ok('http://127.0.0.1:4444/groups/update' => form => { id => '3', lib_id => '0', name => 'test', label => 'test'} )->status_is(200)->json_is( { status =>'ok' } );

$t->post_ok('http://127.0.0.1:4444/groups/update' => form => { id => '3', lib_id => '7', name => 'test', label => 'test'} )->status_is(200)->json_is( { status =>'ok' } );


# отрицательные тесты

my $result1 = { message => "Can't find row for updating", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => { id => '404', lib_id => '0', name => 'test', label => 'test'} )->status_is(200)->json_is( $result1 );

my $result2 = { message => "Required fields do not exist", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => { id => '3', lib_id => '0', name => 'test' } )->status_is(200)->json_is( $result2 );

my $result3 = { message => "Wrong lib_id", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => { id => '3', lib_id => '9', name => 'test', label => 'test' } )->status_is(200)->json_is( $result3 );

my $result4 = { message => "Wrong lib_id", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/update' => form => { id => '3', lib_id => '404', name => 'test', label => 'test' } )->status_is(200)->json_is( $result4 );

done_testing();
