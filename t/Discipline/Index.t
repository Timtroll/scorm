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

use Data::Dumper;

# переинсталляция базы scorm_test
reset_test_db();

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

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
my $sth = $t->app->pg_dbh->prepare( 'SELECT max("id") AS "id" FROM "public"."EAV_items"' );
$sth->execute();
my $answer = $sth->fetchrow_hashref();

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
    'id'        => $$answer{'id'} + 1,
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
    'id'        => $$answer{'id'} + 2,
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
            'id'          => $$answer{'id'} + 1,
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
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'          => $$answer{'id'} + 2,
            'name'        => 'Предмет2',
            'label'       => 'Предмет 2',
            'description' => 'Краткое описание',
            'content'     => 'Полное описание',
            'keywords'    => 'ключевые слова',
            'url'         => 'https://test.com',
            'seo'         => 'дополнительное поле для seo',
            'parent'      => 0,
            'status'      => 0,
            'attachment'  => '[1]'
        },
        'result' => {
            'id'        => 2,
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
                "id"          => 1,
                "label"       => "Предмет 1",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "url"         => "https://test.com",
                "seo"         => "дополнительное поле для seo",
                "route"       => "/discipline/",  # роут для работы с элементами
                "parent"      => 0,
                "status"      => 1,
                "attachment"  => '[1]'
            },
            {
                "folder"      => 0,
                "id"          => 2,
                "label"       => "Предмет 2",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "url"         => "https://test.com",
                "seo"         => "дополнительное поле для seo",
                "route"       => "/discipline/",
                "parent"      => 0,
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







