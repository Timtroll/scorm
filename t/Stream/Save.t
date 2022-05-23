# обновление данных о потоке
# "id"        => 1             - id обновляемого элемента ( >0 )
# "name",     => 'name'        - обязательно (системное название, латиница)
# 'age'       => 1,            - год обучения, обязательное поле
# 'date'      => '01-09-2020', - дата начала обучения, обязательное поле
# 'master_id' => 11,           - id руководителя
# "status"    => 0 или 1       - активен ли поток

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use utf8;

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

# Ввод потоков
diag "Add stream:";
my $test_data = {
    1 => {
        'data' => {
            'name'      => 'test1',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'name'      => 'test2',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        }
    }
};

diag "Add streams:";
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/stream/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'name'      => 'test1',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'All fields:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404,
            'name'      => 'name2',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "Stream with id '404' does not exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'data' => {
            'name'      => 'name2',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/stream/save _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/stream/save _check_fields: didn't has required data in 'name' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    5 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name2',
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/stream/save _check_fields: didn't has required data in 'age' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No label:' 
    },
    6 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name2',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1
        },
        'result' => {
            'message'   => "/stream/save _check_fields: didn't has required data in 'status' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No status:' 
    },
    7 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name*',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/stream/save _check_fields: empty field 'name', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong field type:' 
    },
    8 => {
        'data' => {
            'id'        => 1,
            'name'      => 'test2',
            'age'       => 1,
            'date'      => '01-09-2020',
            'master_id' => $user + 1,
            'status'    => 0
        },
        'result' => {
            'message'   => "Stream with name 'test2' already exists",
            'status'    => 'fail'
        },
        'comment' => 'Name already used:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/stream/save' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# переинсталляция базы scorm_test
reset_test_db();