# создание группы настроек
# my $id = $self->add();
# {
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
# }
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );

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


my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label1',
            'parent'    => 0,
            'status'    => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2',
            'parent'    => 0,
            'status'    => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'status zero:' 
    },
    3 => {
        'data' => {
            'name'      => 'name3',
            'label'     => 'label3',
            'parent'    => 1,
            'status'    => 1
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
        'comment' => 'Folder in folder:' 
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'name'      => 'name4',
            'parent'    => 0,
            'status'    => 1
        },
        'result' => {
            'message'   => "/settings/add_folder _check_fields: didn't has required data in 'label' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No label:' 
    },
    5 => {
        'data' => {
            'label'     => 'label5',
            'parent'    => 0,
            'status'    => 1
        },
        'result' => {
            'message'   => "/settings/add_folder _check_fields: didn't has required data in 'name' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    6 => {
        'data' => {
            'name'      => 'label*',
            'label'     => 'label6',
            'parent'    => 0,
            'status'    => 1
        },
        'result' => {
            'message'   => "/settings/add_folder _check_fields: empty field 'name', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong input format:' 
    },
    7 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label7',
            'parent'    => 0,
            'status'    => 1
        },
        'result' => {
            'message'   => "Folder item named 'name1' is exists",
            'status'    => 'fail'
        },
        'comment' => 'Same name:' 
    },
    8 => {
        'data' => {
            'name'      => 'name8',
            'label'     => 'label8',
            'parent'    => 404,
            'status'    => 1
        },
        'result' => {
            'message'   => "Parent folder with id '404' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => 'Parent doesnt exist:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok( $host.'/settings/add_folder' => {token => $token} => form => $data );
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
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

