#!/usr/bin/perl -w
# загрузка media файла
# "upload" - загружаемый файл - файл, обязателен
# "description" - описание загружаемого файла - до 256 букв, цифр и знаков
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );
use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my ( $t, $host, $picture_path, $test_data, $extension, $regular, $file_path, $desc_path, $cmd, $data, $result, $response, $url);
$t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
$host = $t->app->config->{'host'};

# Путь к директории с файлами
$picture_path = './t/Upload/';

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
                       'description' => 'description.svg',
                        upload => { file => $picture_path . 'all_right.svg' }
                  },
        'result' => {
                        'id'        => '1',
                        'mime'      => 'image/svg+xml',
                        'status'    => 'ok'
                    },
        'comment' => 'all right:' 
    },
    2 => {
        'data' => {
                       'description' => '',
                        upload => { file => $picture_path . 'all_right.jpg' }
                  },
        'result' => {
                        'id'        => '1',
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
                    'message'   => "_check_fields: no file's content",
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
                        'message'   => '_check_fields: file is too large',
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
                        'message'   => "_check_fields: can't read extension",
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
                        'message'   => '_check_fields: extension wrong_extension is not valid',
                        'status'    => 'fail'
        },
        'comment' => 'wrong extension:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    $data = $$test_data{$test}{'data'};
    $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/upload/' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
    $url = $$response{'url'};
    delete $response->{'url'};
    ok( %$result == %$response, "Response is correct" );
    if ( $url ) {
        # составление списка возможных расширений
        $extension = '(';
        foreach ( keys %{$t->app->{'settings'}->{'valid_extensions'}} ) {
            $extension = $extension . $_ . '|';
        }
        $extension =~ s/\|$/)/;

        # регулярное выражение для проверки url
        $regular = '^' . $t->app->{'settings'}->{'site_url'} . $t->app->{'settings'}->{'upload_url_path'} . '([\w]{48}' . '.)(' . $extension . ')$';
        ok( $url =~ /$regular/, "Url is correct" );

        # путь к загруженному файлу
        $file_path = $t->app->{'settings'}->{'upload_local_path'} . $1 . $2;
        ok( -s $file_path, "Download was successful");

        # путь к файлу описания
        $desc_path = $t->app->{'settings'}->{'upload_local_path'} . $1 . $t->app->{'settings'}->{'desc_extension'};
        ok( -s $desc_path, "Description created");

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