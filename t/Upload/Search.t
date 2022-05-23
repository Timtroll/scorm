# получить запись о загруженном файле
# "search" => 1/"file.48symbols.name"/"part of description" - данные для поиска
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );
use Data::Compare;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use common;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my ( $t, $host, $picture_path, $size, $data, $test_data, $result, $response, $token, $url, $regular, $desc_path, $file_path, $cmd );
$t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
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

# Путь к директории с файлами
$picture_path = './t/Upload/files/';

# размер загружаемого файла
$size = -s $picture_path . 'all_right.svg';

# загрузка файла
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

# проверка url, получение имени файла и расширения
$url = $$response{'url'};
$regular = '^' . $settings->{'site_url'} . $settings->{'upload_url_path'} . '([\w]{48}' . ').(' . '[\w]+' . ')$';
ok( $url =~ /$regular/, "Url is correct" );

# путь до загруженого файла
$file_path = $settings->{'upload_local_path'} . $1 . '.' . $2;
# путь до описания загруженного файла
$desc_path = $settings->{'upload_local_path'} . $1 . '.' . $settings->{'desc_extension'};

diag "";

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'search'    => 1,
        },
        'result' => {
            'data'      => [
                {
                  "description" => "description",
                  "id"          =>  1,
                  "mime"        =>  'image/svg+xml',
                  "size"        =>  $size,
                  "title"       =>  'all_right.svg',
                  "url"         =>  $url
                }
            ],
            'status'    => 'ok'
        },
        'comment'         => 'Search for id' 
    },
    2 => {
        'data' => {
            'search'    => $1,
        },
        'result' => {
            'data'      => [
                {
                  "description" => "description",
                  "id"          =>  1,
                  "mime"        =>  'image/svg+xml',
                  "size"        =>  $size,
                  "title"       =>  'all_right.svg',
                  "url"         =>  $url
                }
            ],
            'status'    => 'ok'
        },
        'comment'         => 'Search for filename:' 
    },
    3 => {
        'data' => {
             'search'    => 'desc',
        },
        'result' => {
            'data'      => [
                {
                  "description" => "description",
                  "id"          =>  1,
                  "mime"        =>  'image/svg+xml',
                  "size"        =>  $size,
                  "title"       =>  'all_right.svg',
                  "url"         =>  $url
                }
            ],
            'status'    => 'ok'
        },
        'comment' => "Search for description:" 
    },
    # отрицательные тесты
    4 => {
        'data' => {
            'search'      => 404
        },
        'result' => {
            'message'   => "can not get data from database",
            'status'    => 'fail'
        },
        'comment' => "Id doesn't exist:" 
    },
    5 => {
        'data' => {
        },
        'result' => {
            'message'   => "/upload/search _check_fields: didn\'t has required data in \'search\' = \'\'",
            'status'    => 'fail'
        },
        'comment' => 'No search:' 
    },
};

# запросы и проверка их выполнения
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    $data = $$test_data{$test}{'data'};
    $result = $$test_data{$test}{'result'};

    # проверка подключения
    $t->post_ok($host.'/upload/search/' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8');

    # проверка данных ответа
    $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};

    ok( Compare( $result, $response ), "Response is correct" );

    diag "";
};

# удаление загруженного файла и расширения
$cmd = `rm $file_path $desc_path`;
ok( !$?, "Files were deleted");

# очистка базы
clear_db();

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