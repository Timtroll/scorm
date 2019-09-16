use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../lib";
}

my $t = Test::Mojo->new('Freee');

# положительные тесты
my $data = {field1 => 'bar', field2 => 'baz.txt'};
$t->post_ok('/upload' => form => $data)->status_is(200)->json_is({bye => 'world'});

# отрицательные тесты
#...

done_testing();
