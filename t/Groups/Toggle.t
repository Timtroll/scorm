# включение/выключение роута
#  "id"     => 1 - id изменяемого элемента ( > 0 )
#  элементу присваивается "status" = 1
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

# Импорт доступных групп
my $data = {'name' => 'test', 'label' => 'test', 'status' => 1};
$t->post_ok( $host.'/groups/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'status',
            'value'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1
        },
        'comment' => '1. All right:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'status'
        },
        'result' => {
            'message'   => "Validation error for 'value'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => '2. No value:'
    },
    3 => {
        'data' => {
            'fieldname' => 'status',
            'value'    => 1,
        },
        'result' => {
            'message'   => "Validation error for 'id'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => '3. No id:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'value'    => 1,
        },
        'result' => {
            'message'   => "Validation error for 'fieldname'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => '4. No fieldname:' 
    },
    5 => {
        'data' => {
            'id'        => 404,
            'fieldname' => 'status',
            'value'    => 1
        },
        'result' => {
            'message'   => "Could not toggle Group '404'",
            'status'    => 'fail'
        },
        'comment' => '5. Wrong id:' 
    },
    
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/groups/toggle' => form => $data )
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
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


