# создание настройки
# my $id = $self->_insert_setting({
# "parent"      => 0,           - обязательно (должно быть натуральным числом)
# "label"       => 'название',  - обязательно (название для отображения)
# "name",       => 'name'       - обязательно (системное название, латиница)
# "readonly"    => 0,           - не обязательно, по умолчанию 0
# "value"       => "",            - строка или json
# "type"        => "InputNumber", - тип поля из конфига
# "placeholder" => 'это название',- название для отображения в форме
# "mask"        => '\d+',         - регулярное выражение
# "selected"    => "CKEditor",    - значение по-умолчанию для select
# "required"    => 1              - обязательное поле
# });
use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Freee::Mock::TypeFields;

use Data::Dumper;

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

my $test_data = {
    # положительные тесты
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
            'id'        => '2',
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name3',
            'label'       => 'label3',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '3',
            'status'    => 'ok'
        },
        'comment' => 'No placeholder:' 
    },
    3 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name4',
            'label'       => 'label4',
            'placeholder' => 'placeholder',
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '4',
            'status'    => 'ok'
        },
        'comment' => 'No type:' 
    },
    4 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name5',
            'label'       => 'label5',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '5',
            'status'    => 'ok'
        },
        'comment' => 'No mask:' 
    },
    5 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name6',
            'label'       => 'label6',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '6',
            'status'    => 'ok'
        },
        'comment' => 'No value:' 
    },
    6 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name7',
            'label'       => 'label7',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '7',
            'status'    => 'ok'
        },
        'comment' => 'No selected:' 
    },
    7 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name8',
            'label'       => 'label8',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '8',
            'status'    => 'ok'
        },
        'comment' => 'No required:' 
    },
    
    8 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name9',
            'label'       => 'label9',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'status'      => 0
        },
        'result' => {
            'id'        => '9',
            'status'    => 'ok'
        },
        'comment' => 'No readonly:' 
    },

    # отрицательные тесты
    9 => {
        'data' => {
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
    14 => {
        'data' => {
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
            'message'   => "Could not create new setting item ''",
            'status'    => 'fail',
        },
        'comment' => 'Wrong field type:'
    },
    15 => {
        'data' => {
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
            'message'   => "Could not create new setting item ''",
            'status'    => 'fail',
        },
        'comment' => 'Wrong parent:'
    },
    15 => {
        'data' => {
            'parent'      => 0,
            'name'        => 'name123',
            'label'       => 'label123',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 'mistake',
            'status'      => 0
        },
        'result' => {
            'message'   => "Could not create new setting item ''",
            'status'    => 'fail',
        },
        'comment' => 'Folder creation:'
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/settings/add' => form => $data );
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