#!/usr/bin/perl -w
# удалениe загруженного файла 
# "id" => 1 - id удаляемого файла ( >0 )
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my ( $t, $host, $picture_path, $data, $test_data, $result );
$t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
$host = $t->app->config->{'host'};

# Путь к директории с файлами
$picture_path = './t/Upload/';

# Ввод данных для удаления
diag "Add media:";
$data = {
   'description' => 'description',
    upload => { file => $picture_path . 'all_right.svg' }
};
$t->post_ok( $host.'/upload/' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    done_testing();
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "Start";

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'          => 1,
            'description' => 'description'
        },
        'result' => {
                        'id'        => 1,
                        'mime'      => 'image/svg+xml',
                        'status'    => 'ok'
        },
        'comment'         => 'All right:' 
    },
    2 => {
        'data' => {
            'id'          => 1,
            'description' => ''
        },
        'result' => {
                        'id'        => 1,
                        'mime'      => 'image/svg+xml',
                        'status'    => 'ok'
        },
        'comment'         => 'Empty description:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => 'Can not get file info',
            'status'    => 'fail'
        },
        'comment' => "File with id doesn't exist:" 
    },
    4 => {
        'result' => {
            'message'   => "_check_fields: don't have required data",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    5 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "_check_fields: 'id' don't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong type of id:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    $data = $$test_data{$test}{'data'};
    $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/upload/update/' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".media_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".media RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}