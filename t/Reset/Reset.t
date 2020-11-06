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

# проверка роута /reset
# отрицательные тесты

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

# положительный тест
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

# result проверяется отдельно, так как он генерируется случайно
$response = $$response{'result'};
ok( $response =~ /^\w{30}\@student\@student$/, "Response is correct" );

# проверка роута /confirmation

# отрицательные тесты
$test_data = {
    1 => {
        'data' => '?'.'code=qwerty',
        'result' => {
            'message'   => '/reset/confirmation _check_fields: \'code\' didn\'t match regular expression',
            'status'    => 'fail'
        },
        'address' => '/reset/confirmation',
        'comment' => 'Wrong code format:'
    },
    2 => {
        'data' => '?'.'code=012345678901234567890123456789@error@error',
        'result' => {
            'message'   => "code doesn't exist",
            'status'    => 'fail',
        },
        'address' => '/reset/confirmation',
        'comment' => 'Wrong code:'
    },
    # правильный тест
    3 => {
        'data' => '?'."code=$response",
        'result' => {
            'result'   => $response,
            'status'    => 'ok',
        },
        'address' => '/reset/confirmation',
        'comment' => 'Right code:'
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    my $address = $$test_data{$test}{'address'};

    $t->get_ok( $host.$address.$data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

# проверка роута /reset/reset
# отрицательные тесты

my $test_data = {
    1 => {
        'data' => {
            'code'          => '012345678901234567890123456789@error@error',
            'password'      => 'password',
            'con_password'  => 'error'
        },
        'result' => {
            'message'   => 'password and con_password aren\'t the same',
            'status'    => 'fail'
        },
        'address' => '/reset/reset',
        'comment' => 'Password and con_password aren\'t the same:'
    },
    2 => {
        'data' => {
            'password'      => 'password',
            'con_password'  => 'password'
        },
        'result' => {
            'message'   => "/reset/reset _check_fields: didn't has required data in 'code' = ''",
            'status'    => 'fail',
        },
        'address' => '/reset/reset',
        'comment' => 'No code:'
    },
    3 => {
        'data' => {
            'code'          => 'error',
            'password'      => 'password',
            'con_password'  => 'password'
        },
        'result' => {
            'message'   => "/reset/reset _check_fields: 'code' didn't match regular expression",
            'status'    => 'fail',
        },
        'address' => '/reset/reset',
        'comment' => 'Code don\'t fit regexp:'
    },

    # правильный тест
    4 => {
        'data' => {
            'code'          => $response,
            'password'      => 'password',
            'con_password'  => 'password'
        },
        'result' => {
            'result'    => 1,
            'status'    => 'ok',
        },
        'address' => '/reset/reset',
        'comment' => 'All right:'
    }
};

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
done_testing();

