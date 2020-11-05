use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Freee::Mock::TypeFields;
use Mojo::JSON qw( decode_json );

use Data::Dumper;

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой
$t->app->config->{test} = 1 unless $t->app->config->{test};

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

my $test_data = {
    1 => {
        'data' => {
            'email'      => 'error@error',
        },
        'result' => {
            'message'   => 'email \'error@error\' doesn\'t exist',
            'status'    => 'fail'
        },
        'address' => '/reset',
        'comment' => 'Email doesnt exist:'
    },
    2 => {
        'data' => {
        },
        'result' => {
            'message'   => "/reset _check_fields: didn't has required data in 'email' = ''",
            'status'    => 'fail',
        },
        'address' => '/reset',
        'comment' => 'No email:'
    }
};

# проверка роута /reset
# отрицательные тесты
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    my $address = $$test_data{$test}{'address'};

    $t->post_ok( $host.$address => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

diag "Right test /reset:";
my $test = {
    'data' => {
        'email'      => 'student@student',
    },
    'result' => {
        'status' => 'ok'
    }
};
$t->post_ok( $host.'/reset' => form => $test->{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};

# result проверяется отдельно, так как оно генерируется случайно
my $result = $$response{'result'};
ok( $result =~ /^\w{30}\@student\@student$/, "Result is correct" );

done_testing();

