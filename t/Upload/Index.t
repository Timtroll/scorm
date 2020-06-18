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
my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# Путь к директории с файлами
my $picture_path = './t/Upload/';

my $test_data = {
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
        'comment' => 'all right svg:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
                    'description' => 'description'
                   },
        'result' => {
                    'message'   => "_check_fields: no file's content",
                    'status'    => 'fail'
        },
        'comment' => 'empty file:' 
    },
    3 => {
        'data' =>  {
                        'description' => 'description',
                        upload => { file => $picture_path . 'large_file.jpg' }
                    },
        'result' => {
                        'message'   => '_check_fields: file is too large',
                        'status'    => 'fail'
        },
        'comment' => 'file is too large:' 
    }
};

my $extension;
my $regular;

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/upload/' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    # $t->json_has( $result );
    my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
    my $url = $$response{'url'};
    delete $response->{'url'};
    ok( %$result == %$response, "Response is correct" );
    if ( $url ) {
        $$test_data{$test}{'data'}{'description'} =~ /^.*\.(\w+)$/;
        $extension = lc $1;
        # $regular = '\^' . $t->app->{'settings'}->{'site_url'} . $t->app->{'settings'}->{'upload_url_path'} . '[\w]{48}' . '.' . $extension . '\$';
        diag $url;
        # diag $regular;
        # ok( $url =~ $regular, "Url is correct" );
        # ok( $url =~ /^$t->app->{'settings'}->{'site_url'} . $t->app->{'settings'}->{'upload_url_path'}[\w]{48}$extension$/, "Url is correct" );
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