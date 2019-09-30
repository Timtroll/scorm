use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'        => 'name1',
            'label'       => 'label1',
            'status'      => 1
        },
        'result' => {
            'id'      => '1',
            'status'  => 'ok'
        },
        'comment' => {
            'text' => 'All fields:' 
        }
    },
    2 => {
        'data' => {
            'name'        => 'name2',
            'label'       => 'label2'
        },
        'result' => {
            'id'      => '2',
            'status'  => 'ok'
        },
        'comment' => {
            'text' => 'No status:' 
        }
    },
    3 => {
        'data' => {
            'name'        => 'name3',
            'label'       => 'label3'
        },
        'result' => {
            'id'      => '3',
            'status'  => 'ok',
        },
        'comment' => {
            'text' => 'Status zero:' 
        }
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'name'        => 'name4'
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'No label:' 
        }
    },
    5 => {
        'data' => {
            'label'       => 'label5',
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
        'data' => { },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        },
        'comment' => {
            'text' => 'Empty data:' 
        }
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ("\n $$test_data{$test}{'comment'}{'text'} ");
    $t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
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

