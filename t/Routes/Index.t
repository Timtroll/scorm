# вывод списка роутов в виде объекта 
#    "label"       => "scorm",
#    "id"          => 1,
#    "component"   => "Routes",
#    "opened"      => 0,
#    "folder"      => 0,
#    "keywords"    => "",
#    "children"    => [],
#    "table"       => {}
use Mojo::Base -strict;

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
my $test_data = {
    1 => {
        'data' => {
            'parent'    => 1,
            'name'      => 'name1',
            'label'     => 'label1',
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'parent'    => 1,
            'name'      => 'name2',
            'label'     => 'label2',
            'status'    => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    }
};
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/routes/add' => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
}

# index
my $result = [
    {
    'label'     => 'label1',
    'id'        => 1,
    'table'     => {},
    'opened'    => 0,
    'children'  => [],
    'component' => 'Routes',
    'folder'    => 0,
    'keywords'  => ''
    },
    {
    'label'     => 'label2',
    'id'        => 2,
    'table'     => {},
    'opened'    => 0,
    'children'  => [],
    'component' => 'Routes',
    'folder'    => 0,
    'keywords'  => ''
    },
];

diag ("\n All routes: ");
$t->post_ok( $host.'/routes/' )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );


done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".routes_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".routes RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


