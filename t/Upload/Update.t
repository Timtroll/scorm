# обновление описания загруженного файла 
# "id" => 1 - id файла ( >0 )
# "description" => "description" - описание файла, до 256 символов, может быть пустым
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );
# use File::Slurp qw( read_file );
use Data::Compare;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use common;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my ( $t, $host, $picture_path, $data, $test_data, $result, $response, $token, $url, $regular, $desc_path, $file_path, $description, $cmd );

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
    done_testing();
    exit;
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
            'id'          => 1,
            'description' => 'description'
        },
        'result' => {
            'id'        => 1,
            'mime'      => 'image/svg+xml',
            'status'    => 'ok',
            'url'       => $url
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
            'status'    => 'ok',
            'url'       => $url
        },
        'comment'         => 'Empty description:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'id'          => 404,
            'description' => 'description'
        },
        'result' => {
            'message'   => 'Can not get file info',
            'status'    => 'fail'
        },
        'comment' => "File with id doesn't exist:" 
    },
    4 => {
        'data' => {
            'description' => 'description'
        },
        'result' => {
            'message'   => "/upload/update _check_fields: didn\'t has required data in \'id\' = \'\'",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    5 => {
        'data' => {
            'id'        => - 404,
            'description' => 'description'
        },
        'result' => {
            'message'   => "/upload/update _check_fields: empty field \'id\', didn\'t match regular expression",
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

    # проверка подключения
    $t->post_ok($host.'/upload/update/' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8');

    # проверка данных ответа
    $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
    ok( Compare( $result, $response ), "Response is correct" );

    # проверка содержимого файла описания
    if ( $$result{'status'} eq 'ok' ) {
        $description = read_file( $desc_path, { binmode => ':utf8' } );
        $description = decode_json $description;
        ok( 
            $$description{'description'} eq $$data{'description'} &&
            $$description{'mime'} eq $$test_data{$test}{'result'}{'mime'} &&
            $$description{'filename'} eq $1 &&
            $$description{'extension'} eq $2 &&
            $$description{'title'} eq 'all_right.svg',
            "New description is correct"
        );
    }
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