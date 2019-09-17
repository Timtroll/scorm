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

my $data1 = { name => 'ядро', label => 'ядро'};
my $presult1 = {id => '11', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data1)->status_is(200)->json_is($presult1);


my $data2 = { lib_id => '0',name => 'test', label => 'test'};
my $presult2 = {id => '12', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data2)->status_is(200)->json_is($presult2);

my $data3 = { lib_id => '0',name => 'test', label => 'test'};
my $presult3 = {id => '13', status => 'ok'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data3)->status_is(200)->json_is($presult3);

# отрицательные тесты

my $nresult1 = { message => "Required fields do not exist", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => { lib_id => '0', label => 'test' } )->status_is(200)->json_is( $nresult1 );

my $nresult2 = { message => "Wrong lib_id", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => { lib_id => '9', label => 'test' } )->status_is(200)->json_is( $nresult2 );

my $nresult3 = { message => "Wrong lib_id", status => "fail" };
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => { lib_id => '404', label => 'test' } )->status_is(200)->json_is( $nresult3 );

done_testing();
