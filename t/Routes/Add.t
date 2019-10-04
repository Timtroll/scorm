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
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => {
            'text' => 'All fields:' 
        }
    },
    2 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label2',
            'name'      => 'name2',            
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => {
            'text' => 'No value:' 
        }
    },
    3 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label3',
            'name'      => 'name3',            
            'value'     => '{"/route":0}',
            'required'  => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
        'comment' => {
            'text' => 'No status:' 
        }
    },
    4 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label4',
            'name'      => 'name4',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'readonly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 4,
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No required:' 
        }
    },
    5 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label5',
            'name'      => 'name5',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 5,
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No readonly:' 
        }
    },
    6 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label6',
            'name'      => 'name6',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readonly'  => 0
        },
        'result' => {
            'id'        => '6',
            'status'    => 'ok'
        },
        'comment' => {
            'text'      => 'No removable:' 
        }
    },
    


    # отрицательные тесты
    7 => {
        'data' => {
            'label'     => 'label7',
            'name'      => 'name7',            
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
    8 => {
        'data' => {
            'parent'    => 1,
            'name'      => 'name8',            
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
    9 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label9',
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
    
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ("\n $$test_data{$test}{'comment'}{'text'} ");
    $t->post_ok('http://127.0.0.1:4444/routes/add' => form => $data )
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

