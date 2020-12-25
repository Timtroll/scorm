# изменение поля на 1/0
# my $true = $self->toggle(
#   'id'    => <id> - id записи
#   'field' => имя поля в таблице
#   'val'   => 1/0
#  );

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Freee::Mock::TypeFields;
use Mojo::JSON qw( decode_json );
use Install qw( reset_test_db );
use Test qw( get_last_id_user );

use Data::Dumper;

# переинсталляция базы scorm_test
reset_test_db();

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'admin' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
my $token = $response->{'data'}->{'token'};

# получение id последнего элемента юзера
my $user = get_last_id_user( $t->app->pg_dbh );

# Ввод пользователя
diag "Add user:";
my $test_data = {
    'data' => {
    },
    'result' => {
        'id'        => $user+1,
        'status'    => 'ok'
    }
};

$t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit; 
}
$t->json_is( $$test_data{'result'} );
diag "";

# Ввод потока
diag "Add stream:";
my $test_data = {
    'data' => {
        'name'      => 'name',
        'age'       => 1,
        'date'      => '01-09-2020',
        'master_id' => $user + 1,
        'status'    => 1
    },
    'result' => {
        'id'        => 1,
        'status'    => 'ok'
    }
};

$t->post_ok( $host.'/stream/add' => {token => $token} => form => $$test_data{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit; 
}
$t->json_is( $$test_data{'result'} );
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'status',
            'value'     => 0
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1
        },
        'comment' => 'All right:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'status'
        },
        'result' => {
            'message'   => "/stream/toggle _check_fields: didn't has required data in 'value' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No value:'
    },
    3 => {
        'data' => {
            'fieldname' => 'status',
            'value'    => 1,
        },
        'result' => {
            'message'   => "/stream/toggle _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'value'     => 1,
        },
        'result' => {
            'message'   => "/stream/toggle _check_fields: didn't has required data in 'fieldname' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No fieldname:' 
    },
    5 => {
        'data' => {
            'id'        => 404,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'message'   => "Id '404' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    6 => {
        'data' => {
            'id'        => 0,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'message'   => "Id '0' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => '0 id:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/stream/toggle' => {token => $token}  => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag "";
};

done_testing();

# переинсталляция базы scorm_test
reset_test_db();