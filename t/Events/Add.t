# добавление потока
# my $id = $self->insert_stream({
#     'age'          => 1,                 - год обучения, обязательное поле
#     'date'         => '01-09-2020',      - дата начала обучения, обязательное поле
#     'master_id'    => 11,                - id руководителя
#     "status"       => 0 или 1,           - активен ли поток, обязательное поле
# });

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

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'comment'    => 'event1',
            'time_start' => '01-09-2020',
            'initial_id' => $user + 1,
            'status'     => 1,
            'student_ids'=> "[5]"
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        },
        'comment' => 'All fields:'
    },
    2 => {
        'data' => {
            'comment'    => 'event2',
            'time_start' => '01-09-2020',
            'initial_id' => $user + 1,
            'status'     => 0,
            'student_ids'=> "[5]"
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok',
        },
        'comment' => 'status zero:'
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'time_start' => '01-09-2020',
            'initial_id' => $user + 1,
            'status'     => 1,
            'student_ids'=> "[5]"
        },
        'result' => {
            'message'   => "/events/add _check_fields: didn't has required data in 'comment' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No comment:'
    },
    4 => {
        'data' => {
            'comment'    => 'event2',
            'initial_id' => $user + 1,
            'status'     => 0,
            'student_ids'=> "[5]"
        },
        'result' => {
            'message'   => "/events/add _check_fields: didn't has required data in 'time_start' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No time_start:'
    },
    5 => {
        'data' => {
            'comment'    => 'event2',
            'time_start' => '01-09-2020',
            'initial_id' => $user + 1,
            'student_ids'=> "[5]"
        },
        'result' => {
            'message'   => "/events/add _check_fields: didn't has required data in 'status' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No status:'
    },
    6 => {
        'data' => {
            'comment'    => 'event2',
            'time_start' => 'error',
            'initial_id' => $user + 1,
            'status'     => 0,
            'student_ids'=> "[5]"
        },
        'result' => {
            'message'   => "/events/add _check_fields: empty field 'time_start', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong input format:'
    },
    7 => {
        'data' => {
            'comment'    => 'event1',
            'time_start' => '01-09-2020',
            'initial_id' => 404,
            'status'     => 1,
            'student_ids'=> "[5]"
        },
        'result' => {
            'message'    => "user with id '404' doesn/'t exist\nUser '404' is not a teacher",
            'status'     => 'fail'
        },
        'comment' => 'User does not exist:'
    },
    9 => {
        'data' => {
            'comment'    => 'event1',
            'time_start' => '01-09-2020',
            'initial_id' => 1,
            'status'     => 1,
            'student_ids'=> "[5]"
        },
        'result' => {
            'message'    => "User '1' is not a teacher",
            'status'     => 'fail'
        },
        'comment' => 'User is not a teacher:'
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/events/add' => {token => $token}  => form => $data );
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