# получить данные для редактирования задания
# my $id = $self->_list_course({
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
    upload => { file => './t/Theme/all_right.svg' }
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

# Добавление Тем
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

$data = {
};
$result = {
    'id'        => $answer + 3,
    'status'    => 'ok'
};

$t->post_ok( $host.'/course/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );
diag"";

$data = {
};
$result = {
    'id'        => $answer + 4,
    'status'    => 'ok'
};

$t->post_ok( $host.'/course/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );
diag"";

my $test_data = {
    1 => {
        'data' => {
            'id'          => $answer + 3,
            'name'        => 'Предмет1',
            'label'       => 'Предмет 1',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'parent'      => $answer + 2,
            'status'      => 1,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => $answer + 3,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'          => $answer + 4,
            'name'        => 'Предмет2',
            'label'       => 'Предмет 2',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'parent'      => $answer + 2,
            'status'      => 0,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => $answer + 4,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/course/save' => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

$result = {
    "data" => {
        "label" =>  "курсы",
        "current" =>  {
            "route"  => "/course",        # роут для получения детей
            "add"    => "/course/add",    # разрешает добавлять детей
            "edit"   => "/course/edit",   # разрешает редактировать детей
            "delete" => "/course/delete", # разрешает удалять детей
        },
        "child" =>  {
            "add"    =>    "/course/add",  # разрешает добавлять дочерние темы
        },
        "list" => [
            {
                "folder"      => 0,
                "id"          => $answer + 3,
                "label"       => "Предмет 1",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "parent"      => $answer + 2,
                "status"      => 1,
                "attachment"  => '[]'
            },
            {
                "folder"      => 0,
                "id"          => $answer + 4,
                "label"       => "Предмет 2",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "parent"      => $answer + 2,
                "status"      => 0,
                "attachment"  => '[]'
            }
        ]
    },
    "status" => "ok"
};

$t->post_ok( $host.'/course/' => {token => $token} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );
diag"";

done_testing();

# переинсталляция базы scorm_test
reset_test_db();