# обновление роута
# my $id = $self->insert_route({
#      "id"         => 1            - id обновляемого элемента ( >0 )
#     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "status"      => 0,           - по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
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
my $data = {
    name        => 'name1', 
    label       => 'label1', 
    parent      => 1,
    status      => 1,
    value       => '{"/route":0}',
    required    => 0,
    readOnly    => 0,
    removable   => 0
};
$t->post_ok( $host.'/routes/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->json_is( {'id' => 1,'status' => 'ok'} );

$data = {
    name        => 'name',
    label       => 'label',
    parent      => 1,
    status      => 1,
    value       => '{"/route":0}',
    required    => 0,
    readOnly    => 0,
    removable   => 0
};
$t->post_ok($host.'/routes/add' => form => $data )
    ->status_is(200);
    ->json_is( {'id' => 2,'status' => 'ok'} );

my $test_data = {
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
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'All fields:' 
        }
    },
    2 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label2',
            'name'      => 'name2',            
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No value:' 
        }
    },
    3 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label3',
            'name'      => 'name3',            
            'value'     => '{"/route":0}',
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No status:' 
        }
    },
    4 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label4',
            'name'      => 'name4',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No required:' 
        }
    },
    5 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label5',
            'name'      => 'name5',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'removable' => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No readonly:' 
        }
    },
    6 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label6',
            'name'      => 'name6',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No removable:' 
        }
    },
    
    # отрицательные тесты
    7 => {
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
        'comment' => {
            'text'      => 'No id:' 
        }
    },
    8 => {
        'data' => {
            'id'        => 1,
            'label'     => 'label8',
            'name'      => 'name8',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => 'Wrong parent',
            'status'    => 'fail'
        },
        'comment' => {
            'text'      => 'No parent:' 
        }
    },
    9 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'name'      => 'name9',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => {
            'text' => 'No label:' 
        }
    },
    10 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label10',
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => {
            'text'      => 'No name:' 
        }
    },
    11 => {
        'data' => {
            'id'        => 404,
            'parent'    => 1,
            'label'     => 'label11',
            'name'      => 'name11',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => "Can't find row for updating",
            'status'    => 'fail'
        },
        'comment' => {
            'text'      => 'Wrong id:' 
        }
    },
    12 => {
        'data' => {
            'id'        => 1,
            'parent'    => 1,
            'label'     => 'label',
            'name'      => 'name',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => "Could not update setting item 'label'",
            'status'    => 'fail'
        },
        'comment' => {
            'text'      => 'Mistake from DB:' 
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ("\n $$test_data{$test}{'comment'}{'text'} ");
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

