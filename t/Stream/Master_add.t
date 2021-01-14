# добавление руководителя в поток
# my $id = $self->insert_stream({
#     "stream_id",        => 1,           - ID потока,
#     "master_id"         => 1,           - ID руководителя
# });

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

# Сохранение пользователя
diag "Save user:";
$test_data = {
    'data' => {
        'id'           => $user+1,
        'surname'      => 'surname',
        'name'         => 'name',
        'patronymic',  => 'patronymic',
        'place'        => 'place',
        'country'      => 'RU',
        'timezone'     => 3,
        'birthday'     => 807393600,
        'login'        => 'login1',
        'email'        => '1@email.ru',
        'phone'        => '7(921)1111111',
        'status'       => 1,
        'groups'       => "[4]"
    },
    'result' => {
        'id'        => $user+1,
        'status'    => 'ok'
    }
};


$t->post_ok( $host.'/user/save' => {token => $token} => form => $$test_data{'data'} );
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
            'stream_id'        => 1,
            'master_id'        => $user + 1,
        },
        'result' => {
            'stream_id' => 1,
            'master_id' => $user + 1,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'stream_id'        => 404,
            'master_id'        => $user + 1,
        },
        'result' => {
            'message'   => "Stream '404' does not exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'data' => {
            'stream_id'        => 1,
            'master_id'          => 404,
        },
        'result' => {
            'message'   => "User '404' does not exist\nUser '404' is not a teacher",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    4 => {
        'data' => {
            'master_id'          => $user + 1,
        },
        'result' => {
            'message'   => "/stream/master_add _check_fields: didn't has required data in 'stream_id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    5 => {
        'data' => {
            'stream_id'      => 1,
            'master_id'        => - 404,
        },
        'result' => {
            'message'   => "/stream/master_add _check_fields: empty field 'master_id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong type of id:' 
    },
    6 => {
        'data' => {
            'stream_id'      => 1,
            'master_id'      => 1,
        },
        'result' => {
            'message'   => "User '1' is not a teacher",
            'status'    => 'fail'
        },
        'comment' => 'Wrong type of id:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/stream/master_add' => {token => $token}  => form => $data );
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
# reset_test_db();