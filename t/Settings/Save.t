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
use Mojo::JSON qw( decode_json );

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

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'yfenbkec' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
my $token = $response->{'data'}->{'token'};


# добавляем тестовый раздел настроек
diag "Add folder:";
$t->post_ok( $host.'/settings/add_folder' => {token => $token} => form => {
    "parent"        => 0,
    "name"          => 'test',
    "label"         => 'first test',
    'status'    => 1
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
            'folder'      => 0,
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
            'folder'      => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
    },
};
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/settings/add' => {token => $token} => form => $$test_data{$test}{'data'} );
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
    9 => {
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
            'readonly'    => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok',
        },
        'comment' => 'No status:' 
    },

    # отрицательные тесты
    10 => {
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
            'message'   => "setting have wrong parent 0",
            'status'    => 'fail',
        },
        'comment' => 'No parent:' 
    },
    11 => {
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
            'message'   => "/settings/save _check_fields: didn't has required data in 'name' = ''",
            'status'    => 'fail',
        },
        'comment' => 'No name:' 
    },
    12 => {
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
            'message'   => "/settings/save _check_fields: didn't has required data in 'label' = ''",
            'status'    => 'fail',
        },
        'comment' => 'No label:' 
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
            'message'   => "/settings/save _check_fields: didn't has required data in 'id' = ''",
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
            'message'   => "/settings/save _check_fields: 'readonly' has wrong size",
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
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "setting have wrong parent 2",
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
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Id '1' is not a setting",
            'status'    => 'fail',
        },
        'comment' => 'Not a setting:'
    },
    18 => {
        'data' => {
            'id'          => 3,
            'parent'      => 404,
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
            'message'   => "setting have wrong parent 404",
            'status'    => 'fail',
        },
        'comment' => "Parent doesn't exist:"
    },
    19 => {
        'data' => {
            'id'          => 404,
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
            'message'   => "Id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Id doesn't exist:"
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/settings/save' => {token => $token} => form => $data );
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