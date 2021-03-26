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
use Test qw( get_last_id_EAV );

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

# получение id последнего элемента
my $answer = get_last_id_EAV( $t->app->pg_dbh );

diag "Add course:";
$test_data = {
    # положительные тесты
    1 => {
        'data' => {
        },
        'result' => {
            'id'        => $answer + 1,
            'status'    => 'ok'
        },
        'comment' => 'Add course:' 
    }
};

$t->post_ok( $host.'/course/add' => {token => $token} => form => $$test_data{1}{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $$test_data{1}{'result'} );
diag"";

diag "Add schedule:";
$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'time_start' => '2021-03-20 00:00:00',
            'teacher_id' => $user + 1,
            'status'     => 1,
            'course_id'  => $answer + 1,
            'duration'   => 10000,
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'Add course:' 
    }
};

$t->post_ok( $host.'/schedule/add' => {token => $token} => form => $$test_data{1}{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $$test_data{1}{'result'} );
diag"";

$test_data = 
    {
        'time_start' => '2021-03-20 00:00:00'
    };

my $result =
{
    "list"=>
        [
            {
                'time_start' => '2021-03-20 00:00:00+03',
                'teacher_id' => $user + 1,
                'status'     => 1,
                'id'         => 1,
                'course_id'  => $answer + 1,
                'duration'   => 10000,
            }
        ],
    "status"=> "ok"
};

diag "Schedule on week:";
$t->post_ok( $host.'/schedule/on_week' => {token => $token} => form => $test_data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );
diag "";

done_testing();

# переинсталляция базы scorm_test
reset_test_db();