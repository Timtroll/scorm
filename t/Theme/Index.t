# получить данные для редактирования предмета
# my $id = $self->_get_theme({
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

# Добавление Тем
my $test_data = {
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
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $data = $$test_data{$test}{'data'};
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

my $result = {
    "data" => {
        "label" =>  "Темы",
        "add"   => 1,              # разрешает добавлять предметы
        "child" =>  {
            "add"    => 1,         # разрешает добавлять детей
            "edit"   => 1,         # разрешает редактировать детей
            "remove" => 1,         # разрешает удалять детей
            "route"  => "/theme",  # роут для получения детей
        },
        "list" => [
            {
                "folder"      => 0,
                "id"          => 2,
                "label"       => "Предмет 1",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "url"         => "https://test.com",
                "seo"         => "дополнительное поле для seo",
                "route"       => "/theme/",  # роут для работы с элементами
                "parent"      => 0,
                "status"      => 1,
                "attachment"  => '[1]'
            },
            {
                "folder"      => 0,
                "id"          => 3,
                "label"       => "Предмет 2",
                "description" => "Краткое описание",
                "content"     => "Полное описание",
                "keywords"    => "ключевые слова",
                "url"         => "https://test.com",
                "seo"         => "дополнительное поле для seo",
                "route"       => "/theme/",
                "parent"      => 0,
                "status"      => 0,
                "attachment"  => '[1]'
            }
        ]
    },
    "status" => "ok"
};

$t->post_ok( $host.'/theme/' );
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







