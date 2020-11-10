# загрузка данных о настройке
#    "id" => 1;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper;
use Encode qw( _utf8_on );

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
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'yfenbkec' } );
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

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'    => 2
        },
        'result' => {
            "data" => {
                "id" => 2,
                "parent" => 1,
                "folder" => 0,
                "tabs" => [
                    {
                        "label" => "Основные",
                        "fields" => [
                            { "label" => "label" },
                            { "name" => "name" },
                            { "placeholder" => '' },
                            { "selected" => [] },
                            { "type" => '' },
                            { "value" => '' }
                        ],
                    },
                    {
                        "label" => "Дополнительно",
                        "fields" => [
                            { "mask" => '' },
                            { "readonly" => 0 },
                            { "required" => 0 },
                            { "placeholder" => '' },
                            { "status" => 1 }
                        ]
                    }
                ]
            },
            'status' => 'ok'
        },
        'comment' => 'All right:'
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'    => 1
        },
        'result' => {
            'message'   => "Id '1' is not a setting",
            'status'    => 'fail'
        },
        'comment' => 'Edit folder:'
    },
    3 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "Could not get id 404",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    4 => {
        'result' => {
            'message'   => "/settings/edit _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    5 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "/settings/edit _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id validation:' 
    },
};

# включение флага utf8
_utf8_on( $$test_data{1}{'result'}{'data'}{'tabs'}[0]{'label'} );
_utf8_on( $$test_data{1}{'result'}{'data'}{'tabs'}[1]{'label'} );

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/settings/edit' => {token => $token} => form => $data )
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


