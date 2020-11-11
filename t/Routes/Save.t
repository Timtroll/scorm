# сохранение бинарных поле роута
# 'id'        => 1,
# 'list'      => 1,
# 'add'       => 1,
# 'edit'      => 1,
# 'delete'    => 1,
# 'status'    => 1
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и готовим таблицу групп
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


#  Вводим группу родителя
diag "Add Group" ;
my $data = {
    'name'      => 'test',
    'label'     => 'test',
    'status'    => 1
};
$t->post_ok( $host.'/groups/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200 ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# получаем список роутов, чтобы произошло автоматическое заполнение доступных роутов в добаленной группе
diag "Add Routes" ;
$data = {'parent' =>  1};
$t->post_ok( $host.'/groups/' => {token => $token} => form => $data );

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
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'All fields = 1 :' 
    },
    2 => {
        'data' => {
            'id'        => 1,
            'list'      => 0,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'list = 0:' 
    },
    3 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 0,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'add = 0:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 1,
            'edit'      => 0,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'edit = 0:' 
    },
    5 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 0,
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'delete = 0 :' 
    },
    6 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 0
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'status = 0 :' 
    },
    # отрицательные тесты
    7 => {
        'data' => {
            'id'        => 404,
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "Route '404' is not exists",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    8 => {
        'data' => {
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/routes/save _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    9 => {
        'data' => {
            'id'        => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/routes/save _check_fields: didn't has required data in 'list' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No list:' 
    },
    10 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/routes/save _check_fields: didn't has required data in 'add' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No add:' 
    },
    11 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/routes/save _check_fields: didn't has required data in 'edit' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No edit:' 
    },
    12 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/routes/save _check_fields: didn't has required data in 'delete' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No delete:' 
    },
    13 => {
        'data' => {
            'id'        => 1,
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
        },
        'result' => {
            'message'   => "/routes/save _check_fields: didn't has required data in 'status' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No status:' 
    },
    14 => {
        'data' => {
            'id'        => 'mistake',
            'list'      => 1,
            'add'       => 1,
            'edit'      => 1,
            'delete'    => 1,
            'status'    => 1
        },
        'result' => {
            'message'   => "/routes/save _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong field type:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/routes/save' => {token => $token} => form => $data )
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
        warn "Turn on 'test' option in config";
    }
}