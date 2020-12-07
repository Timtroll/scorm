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

# Добавление предмета
$data = {
};
$result = {
    'id'        => $answer + 2,
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

# Сохранение предметов
my $test_data = {
    1 => {
        'data' => {
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
        },
        'result' => {
            'id'        => $answer + 1,
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
            'parent'      => $discipline->root(),
            'status'      => 0,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => $answer + 2,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/discipline/save' => {token => $token} => form => $data );
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
        "label" =>  "Предметы",
        "current" =>  {
            "route" =>  "/discipline",      
            "add"   =>  "/discipline/add",    # разрешает добавлять предмет
            "edit"  =>  "/discipline/edit",   # разрешает редактировать предмет
            "delete"=>  "/discipline/delete"  # разрешает удалять предмет
        },
        "child" =>  {
            "add"    =>  "/theme/add" ,         # разрешает добавлять детей
        },
        "list" => [
            {
                "folder"      => 0,
                "id"          => $answer + 1,
                "label"       => "Предмет 1",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "url"         => "https://test.com",
                "seo"         => "дополнительное поле для seo",
                "route"       => "/discipline",  # роут для работы с элементами
                "parent"      => 3,
                "status"      => 1,
                "attachment"  => '[1]'
            },
            {
                "folder"      => 0,
                "id"          => $answer + 2,
                "label"       => "Предмет 2",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "url"         => "https://test.com",
                "seo"         => "дополнительное поле для seo",
                "route"       => "/discipline",
                "parent"      => 3,
                "status"      => 0,
                "attachment"  => '[1]'
            }
        ]
    },
    "status" => "ok"
};

$t->post_ok( $host.'/discipline/' => {token => $token} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );
diag"";
$response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
done_testing();

# переинсталляция базы scorm_test
reset_test_db();