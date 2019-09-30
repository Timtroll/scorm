use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

#Ввод данных для удаления
my $data = {name => 'test', label => 'test', parent => 1};
$t->post_ok('http://127.0.0.1:4444/routes/add' => form => $data )
    ->status_is(200)
    ->json_is( {'id' => 1,'status' => 'ok'} );

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1
        },
        'result' => {
            'status'  => 'ok'
        },
        'comment' => {
            'text' => 'All right:' 
        }
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message' => "Can't find row for hiding",
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'Wrong id:' 
        }
    },
    3 => {
        'data' => {},
        'result' => {
            'message' => 'Need id for changing',
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'No data:' 
        }
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ("\n $$test_data{$test}{'comment'}{'text'} ");
    $t->post_ok('http://127.0.0.1:4444/routes/hide' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
};


done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".routes_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".routes RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


