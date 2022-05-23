# сохранить предмет
# my $id = $self->_save_theme({
# 'id'           => 1,                              # До 9 цифр, обязательное поле
# 'parent'      => 'ID родителя',                   # До 9 цифр, обязательное поле
# 'name'        => 'название',                      # До 256 букв и цифр, обязательное поле
# 'label'       => 'описание поля для отображения', # До 256 букв, цифр и знаков, обязательное поле
# 'description' => 'краткое содержание',            # До 256 букв, цифр и знаков, обязательное поле
# 'content'     => 'полное содержание',             # До 2048 букв, цифр и знаков, обязательное поле
# 'attachment'  => 'массив ID вложенных файлов',    # До 255 цифр в массиве, обязательное поле
# 'keywords'    => 'ключевые слова и фразы',        # До 2048 символов, слова, разделенные запятыми, обязательное поле
# 'url'         => 'url страницы',                  # До 256 символов, электронный адрес, обязательное поле
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
use Test qw( get_last_id_EAV );

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

# получение id последнего элемента
my $answer = get_last_id_EAV( $t->app->pg_dbh );

# Ввод файлов
my $data = {
   'description' => 'description',
    upload => { file => './t/Discipline/all_right.svg' }
};
diag "Insert media:";
$t->post_ok( $host.'/upload/' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit;
}
diag "";

# Добавление предмета
$data = {
};
my $result = {
    'id'        => $answer + 1,
    'status'    => 'ok'
};

$t->post_ok( $host.'/discipline/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );
diag"";

# Добавление темы
$data = {
};
$result = {
    'id'        => $answer + 2,
    'status'    => 'ok'
};

$t->post_ok( $host.'/theme/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );
diag"";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'          => $answer + 2,
            'name'        => 'Предмет1',
            'label'       => 'Предмет 1',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'status'      => 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => $answer + 2,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'          => $answer + 2,
            'name'        => 'Предмет2',
            'label'       => 'Предмет 2',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'status'      => 0,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => $answer + 2,
            'status'    => 'ok'
        },
        'comment' => 'status 0:' 
    },
    # отрицательные тесты
    3 => {
        'data' => {
            'id'          => $answer + 2,
            'name'        => 'Предмет3',
            'label'       => 'Предмет 3',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'message'   => "/theme/save _check_fields: didn't has required data in 'status' = ''",
            'status'    => 'fail',
        },
        'comment' => 'No status:' 
    },
    4 => {
        'data' => {
            'id'          => $answer + 2,
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'message'   => "/theme/save _check_fields: didn't has required data in 'name' = ''",
            'status'    => 'fail',
        },
        'comment' => 'No required field:' 
    },
    5 => {
        'data' => {
            'id'          => $answer + 2,
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'attachment'  => 'error'
        },
        'result' => {
            'message'   => "/theme/save _check_fields: empty field 'attachment', didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => "Validation error:"
    },
    6 => {
        'data' => {
            'id'          => $answer + 2,
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'attachment'  => 'error'
        },
        'result' => {
            'message'   => "/theme/save _check_fields: empty field 'attachment', didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => "Validation error:"
    },
    7 => {
        'data' => {
            'id'          => 404,
            'name'        => 'Предмет',
            'label'       => 'Предмет',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => $answer + 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'message'   => "/theme/save _check_fields: didn't has required data in 'status' = ''",
            'status'    => 'fail',
        },
        'comment' => "Validation error:"
    },

};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/theme/save' => {token => $token} => form => $data );
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
reset_test_db();