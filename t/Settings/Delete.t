# удаление настройки
#    "id" => 1;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

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


# Ввод фолдера
diag "Add folder:";
my $data = {
    'name'      => 'test',
    'label'     => 'test',
    'parent'    => 0,
    'status'    => 1
};
$t->post_ok( $host.'/settings/add_folder' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Ввод настройки
diag "Add setting:";
$data = {
    'name'      => 'name',
    'label'     => 'label',
    'status'    => 1,
    'parent'    => 1
};
$t->post_ok( $host.'/settings/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
$t->post_ok( $host.'/settings/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

my $test_data = {
    # отрицательные тесты
    1 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "Could not delete '404'",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    2 => {
        'result' => {
            'message'   => "/settings/delete _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    3 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "/settings/delete _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id validation:' 
    },

    # положительные тесты
    4 => {
        'data' => {
            'id'        => 2
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'All right:'
    },
    5 => {
        'data' => {
            'id'        => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'That is a folder:' 
    },

};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok($host.'/settings/delete' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


