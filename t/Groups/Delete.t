use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# положительные тесты
my $data = {id => '6'};
my $result = {status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/delete' => form => $data)->status_is(200)->json_is($result);

# отрицательные тесты

my $result1 = { message => "Can't find row for deleting", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/delete' => form => { id => '404' } )->status_is(200)->json_is( $result1 );

my $result2 = { message => "Could not id for deleting", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/delete' => form => { } )->status_is(200)->json_is( $result2 );

done_testing();
