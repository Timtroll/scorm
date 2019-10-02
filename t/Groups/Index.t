# вывод списка групп в виде объекта как в Mock
#    "label"       => "scorm",
#    "id"          => 1,
#    "component"   => "Groups",
#    "opened"      => 0,
#    "folder"      => 1,
#    "keywords"    => "",
#    "children"    => [],
#    "table"       => {}use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# Ввод данных для вывода
my $data = [
    1 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label1',
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        },
        'comment' => {
            'text' => 'All fields:' 
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2',
            'status'    => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    }
];
$t->post_ok( $host.'/groups/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit;
}
$t->json_is( {'id' => 1,'status' => 'ok'} );

# index
my $result = [
    {
        'label'     => 'label1',
        'id'        => 1,
        'table'     => {},
        'opened'    => 0,
        'children'  => [],
        'component' => 'Groups',
        'folder'    => 1,
        'keywords'  => ''
    },
    {
        'label'     => 'label2',
        'id'        => 2,
        'table'     => {},
        'opened'    => 0,
        'children'  => [],
        'component' => 'Groups',
        'folder'    => 1,
        'keywords'  => ''
    }
];

my $result = $$test_data{$test}{'result'};
diag ("\n $$test_data{$test}{'comment'}{'text'} ");
$t->post_ok( $host.'/groups/index' )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


