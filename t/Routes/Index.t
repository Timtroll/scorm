# список роутов для группы
# 'id'        =>    1     -  id роута для изменения ( > 0 )
# 'list'      => 0 или 1  -   
# 'add'       => 0 или 1  -    
# 'edit'      => 0 или 1  -   
# 'delete'    => 0 или 1  -   
# 'status'    => 0 или 1  -  активен ли роут
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и готовим таблицу групп
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

#  Вводим группу родителя
my $data = {'name' => 'test', 'label' => 'test', 'status' => 1};
$t->post_ok( $host.'/groups/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');

# получаем список роутов, чтобы произошло автоматическое заполнение доступных роутов в добаленной группе
$data = {'parent' =>  1};
$t->post_ok( $host.'/routes/' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'parent'    => 1
        },
        'result' => {
            'result'    => $result,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    # отрицательные тесты
    2 => {
        'data' => {
            'parent'    => 404,
        },
        'result' => {
            'message'   => "Routes for Group id '404' is not exists",
            'status'    => 'fail'
        },
        'comment' => 'Wrong parent:' 
    },
    3 => {
        'data' => {
            'parent'    => 'mistake',
        },
        'result' => {
            'message'   => "Validation error for 'parent'. Field has wrong type",
            'status'    => 'fail'
        },
        'comment' => 'Wrong field type:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/routes/' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}