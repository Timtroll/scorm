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

# Ввод пользователей
diag "Add users:";
my $test_data = {
    1 => {
        'data' => {
        },
        'result' => {
            'id'        => $user+1,
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
        },
        'result' => {
            'id'        => $user+2,
            'status'    => 'ok'
        }
    },
    3 => {
        'data' => {
        },
        'result' => {
            'id'        => $user+3,
            'status'    => 'ok'
        }
    },
    4 => {
        'data' => {
        },
        'result' => {
            'id'        => $user+4,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    $t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

# Сохранение пользователей
diag "Save users:";
$test_data = {
    1 => {
        'data' => {
            'id'           => $user+1,
            'surname'      => 'а',
            'name'         => 'а',
            'patronymic',  => 'а',
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
    },
    2 => {
        'data' => {
            'id'           => $user+2,
            'surname'      => 'а',
            'name'         => 'а',
            'patronymic',  => 'а',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login2',
            'email'        => '2@email.ru',
            'phone'        => '7(921)1111112',
            'status'       => 1,
            'groups'       => "[1,2]"
        },
        'result' => {
            'id'        => $user+2,
            'status'    => 'ok'
        }
    },
    3 => {
        'data' => {
            'id'           => $user+3,
            'surname'      => 'а',
            'name'         => 'а',
            'patronymic',  => 'а',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login3',
            'email'        => '3@email.ru',
            'phone'        => '7(921)1111113',
            'status'       => 1,
            'groups'       => "[2,1,3]"
        },
        'result' => {
            'id'        => $user+3,
            'status'    => 'ok'
        }
    },
    4 => {
        'data' => {
            'id'           => $user+4,
            'surname'      => 'а',
            'name'         => 'аб',
            'patronymic',  => 'а',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login4',
            'email'        => '4@email.ru',
            'phone'        => '7(921)1111114',
            'status'       => 1,
            'groups'       => "[3,2,1]"
        },
        'result' => {
            'id'        => $user+4,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    warn Dumper( $$test_data{$test}{'data'} );
    $t->post_ok( $host.'/user/save' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

# Ввод потоков
diag "Add event:";
my $test_data = {
    1 => {
        'data' => {
            "comment"=> "event",
            "initial_id"=> $user+1,
            "status"=> 1,
            "time_start"=> "01-09-2020",
            "student_ids" => "[7,8]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/events/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

my $result =
    {
        "teacher" =>
        {
            'id'           => $user+1,
            'surname'      => 'фамилияright',
            'name'         => 'имяright',
            'patronymic',  => 'отчествоright',
            'place'        => 'place',
            'timezone'     => 3,
            'email'        => '1@email.ru',
            'phone'        => '7(921)1111111',
            'status'       => 1
        },
        "students" => 
        [
            {
                'id'           => $user+2,
                'surname'      => 'фамилияright',
                'name'         => 'имяright',
                'patronymic',  => 'отчествоright',
                'place'        => 'place',
                'timezone'     => 3,
                'email'        => '2@email.ru',
                'phone'        => '7(921)1111112',
                'status'       => 1
            },
            {
                'id'           => $user+3,
                'surname'      => 'фамилияright',
                'name'         => 'имяright',
                'patronymic',  => 'отчествоright',
                'place'        => 'place',
                'timezone'     => 3,
                'email'        => '3@email.ru',
                'phone'        => '7(921)1111113',
                'status'       => 1
            }
        ],
        "meta" =>
        {
            "comment" => "event",
            "id" => 1,
            "initial_id"=> 6,
            "status" => 1,
            "student_ids"=> [
                "7",
                "8"
            ],
            "time_start" => "2020-09-01 00:00:00+03"
        },
        "status"=> "ok"
    };

diag "All events:";
$t->post_ok( $host.'/events/lesson_users`' => {token => $token} )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );
diag "";

done_testing();

# переинсталляция базы scorm_test
reset_test_db();