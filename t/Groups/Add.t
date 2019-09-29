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
            'parent'      => 0,
            'name'        => 'name',
            'label'       => 'label',
            'value'       => 'value',
            'required'    => 0,
            'readOnly'    => 0,
            'editable'    => 1,
            'removable'   => 0,
            'status'      => 1
        },
        'result' => {
            'id'      => '1',
            'status'  => 'ok'
        },
    },
    2 => {
        'data' => {
            'parent'      => 0,
            'name'        => 'name1',
            'label'       => 'label1',
            'value'       => 'value1',
        },
        'result' => {
            'id'      => '2',
            'status'  => 'ok'
        }
    },
    3 => {
        'data' => {
            'parent'      => 0,
            'name'        => 'name2',
            'label'       => 'label2',
        },
        'result' => {
            'id'      => '3',
            'status'  => 'ok'
        }
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'parent'      => 0,
            'name'        => 'name3',
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        }
    },
    5 => {
        'data' => {
            'parent'      => 0,
            'label'       => 'label4',
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        }
    },
    6 => {
        'data' => {
            'parent'      => 0,
        },
        'result' => {
            'message' => 'Required fields do not exist',
            'status'  => 'fail'
        }
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok('http://127.0.0.1:4444/groups/add' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
}

done_testing();


# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        diag "Clear table groups";

        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        diag "Turn on 'test' option in config";
        exit;
    }
}

