# загрузка данных о роуте
#    "id" => 1;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper;
use Mojo::JSON qw( decode_json );

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'admin' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
my $token = $response->{'data'}->{'token'};


# Ввод данных для вывода
diag "Add group:";
my $group = {
    'data' => {
        'name'      => 'test',
        'label'     => 'first test',
        'status'    => 1
    },
    'result' => {
        'id'        => '1',
        'status'    => 'ok'
    },
    'comment' => 'New group' 
};
$t->post_ok( $host.'/groups/add' => {token => $token} => form => $group->{'data'} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $group->{'result'} );
diag "";

# получаем список роутов, чтобы произошло автоматическое заполнение доступных роутов в добаленной группе
diag "Add routes" ;
$data = {
    'parent' =>  1
};
$t->post_ok( $host.'/groups/' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Получаю роуты
diag "Check Routes" ;
$data = {
    'parent' =>  1
};
my $answer = $t->post_ok( $host.'/routes/' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Получаю значения первого роута
my $json =  $answer->{tx}->{res}->{content}->{asset}->{content} ;
$json = decode_json $json;
my $label = $json->{'list'}->{'body'}[0]->{'label'};
my $name  = $json->{'list'}->{'body'}[0]->{'name'};

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'    => 1
        },
        'result' => {
            'data'      => {
                'id'        => 1,
                'parent'    => 1,
                'label'     => $label,
                'name'      => $name,
                'list'      => 0,
                'add'       => 0,
                'edit'      => 0,
                'delete'    => 0,
                'status'    => 1
            },
            'status'    => 'ok'
        },
        'comment' => 'All right:'
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "Could not get Route '404'",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'result' => {
            'message'   => "/routes/edit _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    4 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "/routes/edit _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/routes/edit' => {token => $token} => form => $data )
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


