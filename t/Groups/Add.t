# добавление группы
# my $id = $self->insert_group({
#     "label"        => 'название',    - название для отображения, обязательное поле
#     "name",      => 'name',           - системное название, латиница, обязательное поле
#     "publish"      => 0 или 1,          - активна ли группа
# });
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label1',
            'publish'    => 1
        },
        'result' => {
            'id'        => '1',
            'publish'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2',
            'publish'    => 1
        },
        'result' => {
            'id'        => '2',
            'publish'    => 'ok',
        },
        'comment' => 'Status zero:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'name'      => 'name3',
            'publish'    => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'label'",
            'publish'    => 'fail'
        },
        'comment' => 'No label:' 
    },
    4 => {
        'data' => {
            'label'     => 'label4',
            'publish'    => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'name'",
            'publish'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    5 => {
        'data' => {
            'name'      => 'name5',
            'label'     => 'label5'
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'publish'",
            'publish'    => 'fail'
        },
        'comment' => 'No publish:' 
    },
    6 => {
        'data' => {
            'name'      => 'label 6',
            'label'     => 'label6',
            'publish'    => 1
        },
        'result' => {
            'message'   => "_check_fields: 'name' didn't match regular expression",
            'publish'    => 'fail'
        },
        'comment' => 'Wrong input format:' 
    },
    7 => {
        'data' => {
            'name'       => 'name1',
            'label'      => 'label7',
            'publish'     => 1
        },
        'result' => {
            'message'    => "name 'name1' already exists",
            'publish'     => 'fail'
        },
        'comment' => 'Same name:' 
    },
    8 => {
        'data' => {
            'name'       => 'name8',
            'label'      => 'label1',
            'publish'     => 1
        },
        'result' => {
            'message'    => "label 'label1' already exists",
            'publish'     => 'fail'
        },
        'comment' => 'Same label:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/groups/add' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
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

