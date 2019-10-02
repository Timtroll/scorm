# добавление группы
# my $id = $self->insert_group({
#     "label"        => 'название',    - название для отображения, обязательное поле
#     "name",      => 'name',           - системное название, латиница, обязательное поле
#     "status"      => 0 или 1,          - активна ли группа
# });
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

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label1',
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        },
        'comment' => {
            'text' => 'All fields:' 
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2'
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No status:' 
        }
    },
    3 => {
        'data' => {
            'name'      => 'name3',
            'label'     => 'label3'
        },
        'result' => {
            'id'        => '3',
            'status'    => 'ok',
        },
        'comment' => {
            'text'      => 'Status zero:' 
        }
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'name'      => 'name4'
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => {
            'text' => 'No label:' 
        }
    },
    5 => {
        'data' => {
            'label'     => 'label5',
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => {
            'text'      => 'No name:' 
        }
    },
    6 => {
        'data' => { },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => {
            'text' => 'Empty data:' 
        }
    },
    7 => {
        'data' => {
            'name'       => 'name1',
            'label'      => 'label1',
            'status'     => 1
        },
        'result' => {
            'message'    => "Could not add new group item 'label1'",
            'status'     => 'fail'
        },
        'comment' => {
            'text'       => 'Mistake from DB:' 
        }
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok( $host.'/groups/add' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
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

