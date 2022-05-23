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
        'groups'       => "[1]"
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
diag "Add streams:";
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

# Ввод пользователя в поток
diag "Add user into stream:";
my $test_data = {
    'data' => {
        'stream_id'        => 1,
        'user_id'          => $user + 1,
    },
    'result' => {
        'stream_id' => 1,
        'user_id'   => $user+1,
        'status'    => 'ok'
    }
};

$t->post_ok( $host.'/stream/user_add' => {token => $token} => form => $$test_data{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit; 
}
$t->json_is( $$test_data{'result'} );
diag "";

my $result =
    {
        "list" => [
            {
                "member_count" => 1,
                "component" => "Stream",
                "id" => 1,
                "name" => "test1",
                "age" =>  1, # год обучения
                "date" => "2020-09-01 00:00:00+03",
                "master_id" => $user+1
            },
            {
                "member_count" => 0,
                "component" => "Stream",
                "id" => 2,
                "name" => "test2",
                "age" => 1, 
                "date" => "2020-09-01 00:00:00+03",
                "master_id" => $user+1
            }
        ],
        "status" => "ok"
    };

diag "All streams:";
$t->post_ok( $host.'/stream/' => {token => $token} )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );
diag "";

done_testing();

# переинсталляция базы scorm_test
reset_test_db();