# переключение бинарных поле роута
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

# Включаем режим работы с тестовой базой и чистим таблицу групп
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# Импорт доступных групп
diag "Add Group";
my $data = {
    'name'      => 'test',
    'label'     => 'test',
    'publish'    => 1
};
$t->post_ok( $host.'/groups/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Импорт доступных роутов
diag "Add Routes";
$data = {'parent' =>  1};
$t->post_ok( $host.'/groups/' => form => $data );

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
            'id'        => 1,
            'fieldname' => 'list',
            'value'     => 1
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'list -> 1:' 
    },
    2 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'list',
            'value'     => 0
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'list -> 0:' 
    },
    3 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'add',
            'value'     => 1
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'add -> 1:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'add',
            'value'     => 0
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'add -> 0:' 
    },
    5 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'edit',
            'value'     => 1
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'edit -> 1:' 
    },
    6 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'edit',
            'value'     => 0
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'edit -> 0:' 
    },
    7 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'delete',
            'value'     => 1
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'delete -> 1:' 
    },
    8 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'delete',
            'value'     => 0
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'delete -> 0:' 
    },
    9 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'publish',
            'value'     => 1
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'publish -> 1:' 
    },
    10 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'publish',
            'value'     => 0
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'publish -> 0:' 
    },

    # отрицательные тесты
    11 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'publish'
        },
        'result' => {
            'message'   => "_check_fields: 'value' didn't match regular expression",
            'publish'    => 'fail'
        },
        'comment' => 'No value:'
    },
    12 => {
        'data' => {
            'fieldname' => 'publish',
            'value'     => 1,
        },
        'result' => {
            'message'   => "_check_fields: 'id' didn't match regular expression",
            'publish'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    13 => {
        'data' => {
            'id'        => 1,
            'value'     => 1,
        },
        'result' => {
            'message'   => "_check_fields: 'fieldname' didn't match required in check array",
            'publish'    => 'fail'
        },
        'comment' => 'No fieldname:' 
    },
    14 => {
        'data' => {
            'id'        => 404,
            'fieldname' => 'publish',
            'value'     => 1
        },
        'result' => {
            'message'   => "Id '404' doesn't exist",
            'publish'    => 'fail'
        },
        'comment' => 'Id do not exist:' 
    },
    15 => {
        'data' => {
            'id'        => 'mistake',
            'fieldname' => 'publish',
            'value'     => 1
        },
        'result' => {
            'message'   => "_check_fields: 'id' didn't match regular expression",
            'publish'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    
    
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/routes/toggle' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".routes_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".routes RESTART IDENTITY CASCADE');
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


