# загрузка media файла
# "upload" - загружаемый файл - файл, обязателен
# "description" - описание загружаемого файла - до 256 букв, цифр и знаков
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
# use File::Slurp qw( read_file );
use Mojo::JSON qw( decode_json );
use Data::Compare;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use common;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my ( $t, $host, $picture_path, $test_data, $extension, $regular, $file_path, $desc_path, $cmd, $data, $result, $response, $token, $url, $size, $description );
$t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
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

# размер загружаемого файла
$size = -s $picture_path . 'all_right.svg';

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
                       'description' => 'description',
                        upload => { file => $picture_path . 'all_right.svg' }
                  },
        'result' => {
                        'id'        => 1,
                        'mime'      => 'image/svg+xml',
                        'status'    => 'ok'
                    },
        'comment' => 'all right:' 
    },
    2 => {
        'data' => {
                       'description' => '',
                        upload => { file => $picture_path . 'all_right.svg' }
                  },
        'result' => {
                        'id'        => 2,
                        'mime'      => 'image/svg+xml',
                        'status'    => 'ok'
                    },
        'comment' => 'empty description:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
                    'description' => 'description'
                   },
        'result' => {
                    'message'   => "/upload _check_fields: didn\'t has required file data in \'upload\'",
                    'status'    => 'fail'
        },
        'comment' => 'empty file:' 
    },
    4 => {
        'data' =>  {
                        'description' => 'description',
                        upload => { file => $picture_path . 'large_file.jpg' }
                    },
        'result' => {
                        'message'   => '/upload _check_fields: file is too large',
                        'status'    => 'fail'
        },
        'comment' => 'file is too large:' 
    },
    5 => {
        'data' =>  {
                        'description' => 'description',
                        upload => { file => $picture_path . 'no_extension' }
                    },
        'result' => {
                        'message'   => "/upload _check_fields: can\'t read extension",
                        'status'    => 'fail'
        },
        'comment' => 'no extension:' 
    },
    6 => {
        'data' =>  {
                        'description' => 'description',
                        upload => { file => $picture_path . 'wrong_extension.wrong_extension' }
                    },
        'result' => {
                        'message'   => '/upload _check_fields: extension wrong_extension is not valid',
                        'status'    => 'fail'
        },
        'comment' => 'wrong extension:' 
    }
};

# запросы и проверка их выполнения
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    $data = $$test_data{$test}{'data'};
    $result = $$test_data{$test}{'result'};

    # проверка подключения
    $t->post_ok( $host.'/upload/' => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');

    # проверка данных ответа
    $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
    # url проверяется отдельно, так как оно генерируется случайно
    $url = $$response{'url'};
    delete $response->{'url'};
    ok( Compare( $result, $response ), "Response is correct" );

    # дополнительные проверки работы положительных запросов
    if ( $$result{'status'} eq 'ok' ) {

        # составление списка возможных расширений
        $extension = '(';
        foreach ( keys %{$settings->{'valid_extensions'}} ) {
            $extension = $extension . $_ . '|';
        }
        $extension =~ s/\|$/)/;

        # регулярное выражение для проверки url
        $regular = '^' . $settings->{'site_url'} . $settings->{'upload_url_path'} . '([\w]{48}' . ').(' . $extension . ')$';
        ok( $url =~ /$regular/, "Url is correct" );

        # проверка размера загруженного файла
        $file_path = $settings->{'upload_local_path'} . $1 . '.' . $2;
        ok( -s $file_path == $size, "Download was successful");

        # проверка содержимого файла описания
        $desc_path = $settings->{'upload_local_path'} . $1 . '.' . $settings->{'desc_extension'};
        $description = read_file( $desc_path, { binmode => ':utf8' } );
        $description = decode_json $description;

        ok( 
            $$description{'description'} eq $$data{'description'} &&
            $$description{'mime'} eq $$result{'mime'} &&
            $$description{'filename'} eq $1 &&
            $$description{'extension'} eq $2 &&
            $$description{'title'} eq 'all_right.svg' &&
            $$description{'size'} == $size,
            "Description is correct"
        );

        # удаление загруженных файлов
        $cmd = `rm $file_path $desc_path`;
        ok( !$?, "Files were deleted");
    }
    diag "";
};
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