# добавить тему
# my $id = $self->_insert_theme({
# 'parent'      => 'ID родителя',                   # До 9 цифр, обязательное поле
# 'name'        => 'название',                      # До 256 букв и цифр, обязательное поле
# 'label'       => 'описание поля для отображения', # До 256 букв, цифр и знаков, обязательное поле
# 'description' => 'краткое содержание',            # До 256 букв, цифр и знаков, обязательное поле
# 'content'     => 'полное содержание',             # До 2048 букв, цифр и знаков, обязательное поле
# 'attachment'  => 'массив ID вложенных файлов',    # До 255 цифр в массиве, обязательное поле
# 'keywords'    => 'ключевые слова и фразы',        # До 2048 символов, слова, разделенные запятыми, обязательное поле
# 'url'         => 'https://test.com',                  # До 256 символов, электронный адрес, обязательное поле
# 'seo'         => 'дополнительное поле для seo',   # До 2048 букв, цифр и знаков, обязательное поле
# 'status'      => '1'                              # 0 или 1, обязательное поле
# });
use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Freee::Mock::TypeFields;
use Mojo::JSON qw( decode_json );
use Install qw( reset_test_db );

use Data::Dumper;

# переинсталляция базы scorm_test
reset_test_db();

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};

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


# Ввод файлов
my $data = {
   'description' => 'description',
    upload => { file => './t/Theme/all_right.svg' }
};
diag "Insert media:";
$t->post_ok( $host.'/upload/' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit; 
}
diag "";

# Ввод предмета родителя
$data = {
    'name'        => 'Предмет1',
    'label'       => 'Предмет 1',
    'description' => 'Краткое описание',
    'content'     => 'Полное описание',
    'keywords'    => 'ключевые слова',
    'url'         => 'https://test.com',
    'seo'         => 'дополнительное поле для seo',
    'parent'      => 0,
    'status'      => 1,
    'attachment'  => '[1]'
};
diag "Insert media:";
$t->post_ok( $host.'/discipline/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit; 
}
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'        => 'Предмет1',
            'label'       => 'Предмет 1',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 1,
            'status'      => 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'name'        => 'Предмет2',
            'label'       => 'Предмет 2',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 1,
            'status'      => 0,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
        'comment' => 'status 0:' 
    },
    3 => {
        'data' => {
            'name'        => 'Предмет3',
            'label'       => 'Предмет 3',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => 4,
            'status'    => 'ok'
        },
        'comment' => 'No status:' 
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'name'",
            'status'    => 'fail',
        },
        'comment' => 'No required field:' 
    },
    5 => {
        'data' => {
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 1,
            'attachment'  => '[1,404]'
        },
        'result' => {
            'message'   => "file with id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Attachment doesn't exist:"
    },
    6 => {
        'data' => {
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 1,
            'attachment'  => 'error'
        },
        'result' => {
            'message'   => "_check_fields: 'attachment' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => "Validation error:"
    },
    7 => {
        'data' => {
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 404,
            'attachment'  => '[1]'
        },
        'result' => {
            'message'   => "parent with id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Parent doesn't exist:"
    },
    8 => {
        'data' => {
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 0,
            'attachment'  => '[1]'
        },
        'result' => {
            'message'   => "theme must have a nonzero parent",
            'status'    => 'fail',
        },
        'comment' => "Parent is 0:"
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/theme/add' => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ( $t->app->config->{test} ) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".media_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".media RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_data_string" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_data_datetime" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('ALTER SEQUENCE "public".eav_items_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_items" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_links" RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}