#!/usr/bin/perl -w
# удалениe загруженного файла 
# "id" => 1 - id удаляемого файла ( >0 )
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use common;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my ( $t, $host, $picture_path, $data, $test_data, $result, $response, $token, $url, $regular, $file_path, $desc_path );
$t = Test::Mojo->new('Freee');

# включение режима работы с тестовой базой и очистка таблицы
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# установка адреса
$host = $t->app->config->{'host'};

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'admin' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
$response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
$token = $response->{'data'}->{'token'};

# путь к директории с файлами
$picture_path = './t/Upload/files/';

# ввод данных
diag "Add media:";
$data = {
   'description' => 'description',
    upload => { file => $picture_path . 'all_right.svg' }
};

# проверка работы запросов
$t->post_ok( $host.'/upload/' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');

# получение url загруженного файла
$response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
$url = $$response{'url'};

# проверка url, получение имени файла и расширения
$regular = '^' . $settings->{'site_url'} . $settings->{'upload_url_path'} . '([\w]{48}' . '.)(' . '[\w]+' . ')$';
ok( $url =~ /$regular/, "Url is correct" );
diag "";

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1
        },
        'result' => {
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
            'message'   => 'Can not get file info',
            'status'    => 'fail'
        },
        'comment' => "File with id doesn't exist:" 
    },
    3 => {
        'data' => {},
        'result' => {
            'message'   => "/upload/delete _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    4 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "/upload/delete _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong type of id:' 
    },
};

# запросы и проверка их выполнения
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    $data = $$test_data{$test}{'data'};
    $result = $$test_data{$test}{'result'};

    # проверка запроса и ответа
    $t->post_ok($host.'/upload/delete/' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );

    # проверка удаления файла и его описания
    if ( $$result{'status'} eq 'ok' ) {
        # путь к загруженному файлу
        $file_path = $settings->{'upload_local_path'} . $1 . $2;
        ok( !-e $file_path, "file was deleted");

        # путь к описанию файла
        $desc_path = $settings->{'upload_local_path'} . $1 . $settings->{'desc_extension'};
        ok( !-e $desc_path, "description was deleted");
    }
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