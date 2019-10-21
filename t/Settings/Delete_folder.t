# удаление фолдера
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

# Ввод фолдера
diag "Add folder:";
my $data = {name => 'test', label => 'test', parent => 0};
$t->post_ok( $host.'/settings/add_folder' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Ввод настройки
diag "Add setting:";
$data = {name => 'name', label => 'label', status => 1, parent => 1};
$t->post_ok( $host.'/settings/add' => form => $data );
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
            'message'   => "Could not delete folder '404'",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    2 => {
        'result' => {
            'message'   => "Validation error for 'id'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    3 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "Validation error for 'id'. Field has wrong type",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id validation:' 
    },
    4 => {
        'data' => {
            'id'        => 2
        },
        'result' => {
            'message'   => "Could not delete folder '2'",
            'status'    => 'fail'
        },
        'comment' => 'Not a folder:'
    },

    # положительные тесты
    5 => {
        'data' => {
            'id'    => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All right:'
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/settings/delete_folder' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

# проверка удаления потомка
# diag "Child check:";
# $t->post_ok( $host.'/settings/delete' => form => { "id" => 2 })
#     ->status_is(200)
#     ->content_type_is('application/json;charset=UTF-8')
#     ->json_is( { 'status'    => 'fail',  'message'   => "Could not delete '2'" } );
# diag "";

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


