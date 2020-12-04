# получить данные для редактирования предмета
# my $id = $self->_get_discipline({
# 'id' => 1   # До 9 цифр, обязательное поле
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
use Test qw( get_last_id_EAV clear_db );

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

# инициализация EAV
my $discipline = Freee::EAV->new( 'Discipline' );

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

# Сохранение предмета
$data = {
    'id'          => $answer + 1,
    'name'        => 'Предмет1',
    'label'       => 'Предмет 1',
    'description' => 'Краткое описание',
    'content'     => 'Полное описание',
    'keywords'    => 'ключевые слова',
    'url'         => 'https://test.com',
    'seo'         => 'дополнительное поле для seo',
    'parent'      => $discipline->root(),
    'status'      => 1,
    'attachment'  => '[1]'
};
$result = {
    'id'        => $answer + 1,
    'status'    => 'ok'
};

$t->post_ok( $host.'/discipline/save' => {token => $token} => form => $data );
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
            'id' => $answer + 1
        },
        'result' => {
            "data" => {
                "id" => $answer + 1,
                "parent" => $discipline->root(),
                "folder" => 0,
                "tabs" => [
                    {
                        "label" => "основные",
                        "fields" => [
                            {"label" => "Предмет 1"},
                            {"description" => "Краткое описание"},
                            {"keywords" => "ключевые слова"},
                            {"url" => "https://test.com"},
                            {"seo" => "дополнительное поле для seo"},
                            {"route" => "/discipline"},
                            {"status" => 1},

                        ],
                    },
                    {
                        "label" => "Контент",
                        "fields" => [
                            {"content" => "Полное описание"},
                            {"attachment" => '[1]'}
                        ]
                    }
                ]
            },
            "status" => "ok"
        },
        'comment' => 'All fields:' 
    },
    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "discipline with id '404' doesn't exist\nCould not get discipline",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'result' => {
            'message'   => "/discipline/edit _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    4 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "/discipline/edit _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id validation:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/discipline/edit' => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

done_testing();

clear_db( $t->app->config->{test}, $t->app->pg_dbh );







