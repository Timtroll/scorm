# обновление группы
# my $id = $self->update({
#     "id"        => 1            - id обновляемого элемента ( >0 )
#     "label"     => 'название'   - обязательно (название для отображения)
#     "name",     => 'name'       - обязательно (системное название, латиница)
#     "status"    => 0 или 1      - активна ли группа
# });
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

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

my $test_data = {
    1 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label1',
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2',
            'status'    => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    }
};
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/groups/add' => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
}

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'label'     => 'label'
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'No status:' 
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
            'message'   => "Can't find row for updating",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    4 => {
        'data' => {
            'name'      => 'name',
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    5 => {
        'data' => {
            'id'        => 1,
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    6 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'status'    => 1
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No label:' 
    },
    7 => {
        'data' => {
            'id'        => 1,
            'label'     => 'label2',
            'name'      => 'name2',            
            'status'    => 0
        },
        'result' => {
            'message'   => "Could not update setting item 'label2'",
            'status'    => 'fail'
        },
        'comment' => 'Mistake from DB:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/groups/update' => form => $data )
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