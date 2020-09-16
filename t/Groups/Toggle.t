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

# Импорт доступных групп
diag "Add group:";
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

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'publish',
            'value'     => 1
        },
        'result' => {
            'publish'    => 'ok',
            'id'        => 1
        },
        'comment' => 'All right:' 
    },

    # отрицательные тесты
    2 => {
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
    3 => {
        'data' => {
            'fieldname' => 'publish',
            'value'    => 1,
        },
        'result' => {
            'message'   => "_check_fields: 'id' didn't match regular expression",
            'publish'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    4 => {
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
    5 => {
        'data' => {
            'id'        => 404,
            'fieldname' => 'publish',
            'value'     => 1
        },
        'result' => {
            'message'   => "Id '404' doesn't exist",
            'publish'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    6 => {
        'data' => {
            'id'        => 0,
            'fieldname' => 'publish',
            'value'     => 1
        },
        'result' => {
            'message'   => "Id '0' doesn't exist",
            'publish'    => 'fail'
        },
        'comment' => '0 id:' 
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
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}