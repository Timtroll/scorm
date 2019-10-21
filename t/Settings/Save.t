# Сохранение настройки
# my $id = $self->update({
# 'id'          => 1,
# 'parent'      => 1,
# 'name'        => 'name',
# 'label'       => 'label',
# 'placeholder' => 'placeholder',
# 'type'        => 'type',
# 'mask'        => 'mask',
# 'value'       => 'value',
# 'selected'    => '[]',
# 'required'    => 0,
# 'readonly'    => 0,
# 'status'      => 1
# });
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Freee::Mock::TypeFields;

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# добавляем тестовый раздел настроек
diag "Add folder:";
$t->post_ok( $host.'/settings/add_folder' => form => {
    "parent"        => 0,
    "name"          => 'test',
    "label"         => 'first test',
});
diag "";

# добавляем данные для изменения
diag "Add settings:";
my $test_data = {
    1 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
    },
    2 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name3',
            'label'       => 'label3',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
    },
};
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/settings/add' => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No placeholder:' 
    },
    3 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No type:' 
    },
    4 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No mask:' 
    },
    5 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No value:' 
    },
    6 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No selected:' 
    },
    7 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No required:' 
    },
    
    8 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'status'      => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'No readonly:' 
    },

    # отрицательные тесты
    9 => {
        'data' => {
            'id'          => 2,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Validation error for 'parent'. Field is empty or not exists",
            'status'    => 'fail',
        },
        'comment' => 'No parent:' 
    },
    10 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Validation error for 'name'. Field is empty or not exists",
            'status'    => 'fail',
        },
        'comment' => 'No name:' 
    },
    11 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Validation error for 'label'. Field is empty or not exists",
            'status'    => 'fail',
        },
        'comment' => 'No label:' 
    },
    12 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0
        },
        'result' => {
            'message'   => "Validation error for 'status'. Field is empty or not exists",
            'status'    => 'fail',
        },
        'comment' => 'No status:' 
    },
    13 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Validation error for 'id'. Field is empty or not exists",
            'status'    => 'fail',
        },
        'comment' => 'No id:' 
    },
    14 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name3',
            'label'       => 'label3',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Setting named 'name3' is exists",
            'status'    => 'fail',
        },
        'comment' => 'Same name:'
    },
    15 => {
        'data' => {
            'id'          => 2,
            'parent'      => 1,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 'mistake',
            'status'      => 0
        },
        'result' => {
            'message'   => "Could not update setting item '2'",
            'status'    => 'fail',
        },
        'comment' => 'Wrong field type:'
    },
    16 => {
        'data' => {
            'id'          => 3,
            'parent'      => 2,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 'mistake',
            'status'      => 0
        },
        'result' => {
            'message'   => "Could not update setting item '3'",
            'status'    => 'fail',
        },
        'comment' => 'Parent not a folder:'
    },
    17 => {
        'data' => {
            'id'          => 1,
            'parent'      => 2,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 'mistake',
            'status'      => 0
        },
        'result' => {
            'message'   => "Could not update setting item '1'",
            'status'    => 'fail',
        },
        'comment' => 'Not a leaf:'
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/settings/save' => form => $data );
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