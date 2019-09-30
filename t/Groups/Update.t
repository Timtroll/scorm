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
my $data = {name => 'test', label => 'test'};
$t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
    ->status_is(200)
    ->json_is( {'id' => 1,'status' => 'ok'} );

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'status'  => 'ok'
        },
        'comment' => {
            'text' => 'All fields:' 
        }
    },
    2 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'label'     => 'label'
        },
        'result' => {
            'status'  => 'ok'
        },
        'comment' => {
            'text' => 'No status:' 
        }
    },
        

    # отрицательные тесты
    3 => {
        'data' => {
            'id'        => 404,
            'name'      => 'name',
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'message' => "Can't find row for updating",
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'Wrong id:' 
        }
    },
    4 => {
        'data' => {
            'name'      => 'name',
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'No id:' 
        }
    },
    5 => {
        'data' => {
            'id'        => 1,
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'No name:' 
        }
    },
    6 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'status'    => 1
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'No label:' 
        }
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ("\n $$test_data{$test}{'comment'}{'text'} ");
    $t->post_ok('http://127.0.0.1:4444/groups/update' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
};


done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

