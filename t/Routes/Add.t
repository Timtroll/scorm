# новый роут
# my $id = $self->insert_route({
#     "parent"      => 5,               - id родителя (должно быть натуральным числом), 0 - фолдер
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
#     "required"    => 0,               - не обязательно, по умолчанию 0
#     "readOnly"    => 0,               - не обязательно, по умолчанию 0
#     "removable"   => 0,               - не обязательно, по умолчанию 0
#     "status"      => 0                - по умолчанию 1
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
            'parent'    => 1,
            'label'     => 'label1',
            'name'      => 'name1',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:'
    },
    2 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label2',
            'name'      => 'name2',            
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No value:'
    },
    3 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label3',
            'name'      => 'name3',            
            'value'     => '{"/route":0}',
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
        'comment' => 'No status:'
    },
    4 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label4',
            'name'      => 'name4',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'id'        => 4,
            'status'    => 'ok'
        },
        'comment' => 'No required:'
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
        'comment' => 'No readOnly:'
    },
    6 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label6',
            'name'      => 'name6',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0
        },
        'result' => {
            'id'        => '6',
            'status'    => 'ok'
        },
        'comment' => 'No removable:'
    },

    # отрицательные тесты
    7 => {
        'data' => {
            'label'     => 'label7',
            'name'      => 'name7',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => 'Wrong parent',
            'status'    => 'fail'
        },
        'comment' => 'No parent:'
    },
    8 => {
        'data' => {
            'parent'    => 1,
            'name'      => 'name8',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No label:'
    },
    9 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label9',
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => 'Required fields do not exist',
            'status'    => 'fail'
        },
        'comment' => 'No name:'
    },
    10 => {
        'data' => {
            'parent'    => 1,
            'label'     => 'label1',
            'name'      => 'name1',            
            'value'     => '{"/route":0}',
            'status'    => 0,
            'required'  => 0,
            'readOnly'  => 0,
            'removable' => 0
        },
        'result' => {
            'message'   => "Could not add new route item 'label1'",
            'status'    => 'fail'
        },
        'comment' => 'Mistake from DB:'
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok( $host.'/routes/add' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
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

