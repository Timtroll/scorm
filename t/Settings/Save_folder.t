# Сохранение папки настроек
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

use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Freee::Mock::TypeFields;

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Ввод фолдера
my $host = $t->app->config->{'host'};

# добавляем тестовый раздел настроек
diag "Add folder:";
$t->post_ok( $host.'/settings/add_folder' => form => {
    "name"      => 'test',
    "label"     => 'test',
    "parent"    => 0,
    "status"    => 1
});
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'          => 1,
            'name'        => 'name1',
            'label'       => 'label1',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'Status 0:' 
    },
    2 => {
        'data' => {
            'id'          => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'parent'      => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'Status 1:' 
    },
    3 => {
        'data' => {
            'id'          => 1,
            'name'        => 'name3',
            'label'       => 'label3',
            'parent'      => 0
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'No status:' 
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'id'          => 1,
            'label'       => 'label3',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: don't have required data in -name-",
            'status'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    5 => {
        'data' => {
            'id'          => 1,
            'name'        => 'name4',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: don't have required data in -label-",
            'status'    => 'fail'
        },
        'comment' => 'No label:' 
    },
    6 => {
        'data' => {
            'name'        => 'name6',
            'label'       => 'label6',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: don't have required data in -id-",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    7 => {
        'data' => {
            'id'          => 1,
            'name'        => 'name',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: don't have required data in -label-",
            'status'    => 'fail',
        },
        'comment' => 'Same name:'
    },
    8 => {
        'data' => {
            'id'          => 'mistake',
            'name'        => 'name8',
            'label'       => 'label8',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: 'id' don't match regular expression",
            'status'    => 'fail'
        },
        'comment' => "Wrong id type:"
    },
    9 => {
        'data' => {
            'id'          => 404,
            'name'        => 'name9',
            'label'       => 'label9',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: Action for '404' is not allowed for '/settings/save_folder'",
            'status'    => 'fail'
        },
        'comment' => 'Id do not exist:'
    },
    10 => {
        'data' => {
            'id'          => 2,
            'name'        => 'name10',
            'label'       => 'label10',
            'parent'      => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: Action for '2' is not allowed for '/settings/save_folder'",
            'status'    => 'fail'
        },
        'comment' => 'Not exists folder:'
    },
    11 => {
        'data' => {
            'id'          => 2,
            'name'        => 'name10',
            'label'       => 'label10',
            'status'      => 0
        },
        'result' => {
            'message'   => "_check_fields: don't have required data in -parent-",
            'status'    => 'fail'
        },
        'comment' => 'Not exists parent:'
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/settings/save_folder' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

# выбрать случайный html тип поля
sub get_type {
    my $i = int(rand( scalar(@$type) - 1 ));
    my $j = $$type[$i];

    return $$type[$i]{'value'};
}