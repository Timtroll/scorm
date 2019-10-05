# обновление роута
# my $id = $self->insert_route({
#      "id"         => 1            - id обновляемого элемента ( >0 )
#     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "status"      => 0,           - по умолчанию 1
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",          - строка или json
#     "required"    => 0            - не обязательно, по умолчанию 0
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

# Ввод данных для обновления
my $test_data = {
    1 => {
        'data' => {
            'parent'    => 1,
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
            'parent'    => 1,
            'name'      => 'name',
            'label'     => 'label',
            'status'    => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    }
};
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/routes/add' => form => $$test_data{$test}{'data'} );
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
            'parent'    => 1,
            'label'     => 'label1',
            'name'      => 'name1',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label2',
            'name'      => 'name2',            
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'No value:' 
    },
    3 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label3',
            'name'      => 'name3',            
            'value'     => '{"/route":0}',
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'No status:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label4',
            'name'      => 'name4',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'readonly'  => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'No required:' 
    },
    5 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label5',
            'name'      => 'name5',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'No readonly:' 
    },
    
    # отрицательные тесты
    6 => {
        'data' => {
            'parent'    => 1,
            'name'      => 'name7',
            'label'     => 'label7',
            'status'    => 1
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    7 => {
        'data' => {
            'id'        => 1,
            'label'     => 'label8',
            'name'      => 'name8',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'message'   => 'Wrong parent',
            'status'    => 'fail'
        },
        'comment' => 'No parent:' 
    },
    8 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'name'      => 'name9',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No label:' 
    },
    9 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label10',
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    10 => {
        'data' => {
            'id'        => 404,
            'parent'    => 1,
            'label'     => 'label11',
            'name'      => 'name11',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'message'   => "Can't find row for updating",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    11 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label',
            'name'      => 'name',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'message'   => "Could not update setting item 'label'",
            'status'    => 'fail'
        },
        'comment' => 'Mistake from DB:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/routes/update' => form => $data )
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

