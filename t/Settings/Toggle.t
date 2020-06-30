# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
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

# Ввод фолдера
diag "Add folder:";
my $data = {
    'name'    => 'test',
    'label'   => 'test',
    'parent'  => 0,
    'status'  => 1
};
$t->post_ok( $host.'/settings/add_folder' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Ввод настройки
diag "Add setting:";
$data = {
    'name'      => 'name',
    'label'     => 'label',
    'status'    => 1,
    'parent'    => 1
};
$t->post_ok( $host.'/settings/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'required',
            'value'     => 0
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2
        },
        'comment' => 'Required -> 0:' 
    },
    2 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'required',
            'value'     => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2
        },
        'comment' => 'Required -> 1:' 
    },
    3 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'readonly',
            'value'     => 0
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2
        },
        'comment' => 'Readonly -> 0:' 
    },
    4 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'readonly',
            'value'     => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2
        },
        'comment' => 'Readonly -> 1:' 
    },
    5 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'status',
            'value'     => 0
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2
        },
        'comment' => 'Status -> 0:' 
    },
    6 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2
        },
        'comment' => 'Status -> 1:' 
    },
    7 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1
        },
        'comment' => 'Status for folder:' 
    },
    8 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'readonly',
            'value'     => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'Readonly for folder:' 
    },
    9 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'required',
            'value'     => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'Required for folder:'
    },

    # отрицательные тесты
    10 => {
        'data' => {
            'id'        => 2,
            'fieldname' => 'status'
        },
        'result' => {
            'message'   => "Validation error for 'value'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => 'No value:'
    },
    11 => {
        'data' => {
            'fieldname' => 'status',
            'value'    => 1,
        },
        'result' => {
            'message'   => "Validation error for 'id'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    12 => {
        'data' => {
            'id'        => 2,
            'value'     => 1,
        },
        'result' => {
            'message'   => "Validation error for 'fieldname'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => 'No fieldname:' 
    },
    13 => {
        'data' => {
            'id'        => 404,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'message'   => "Could not toggle '404'",
            'status'    => 'fail'
        },
        'comment' => 'Id do not exist:' 
    },
    14 => {
        'data' => {
            'id'        => 'mistake',
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'message'   => "_check_fields: 'id' don't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Validation mistake:' 
    }
};
use Data::Dumper;
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok($host.'/settings/toggle' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
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