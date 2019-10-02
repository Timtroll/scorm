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
my $data = {
    name        => 'name1', 
    label       => 'label1', 
    parent      => 1,
    status      => 1,
    value       => '{"/route":0}',
    required    => 0,
    readOnly    => 0,
    removable   => 0
};
$t->post_ok($host.'/routes/add' => form => $data )
    ->status_is(200)
    ->json_is( {'id' => 1,'status' => 'ok'} );

$data = {
    name        => 'name2',
    label       => 'label2',
    parent      => 1,
    status      => 1,
    value       => '{"/route":0}',
    required    => 0,
    readOnly    => 0,
    removable   => 0
};
$t->post_ok($host.'/routes/add' => form => $data )
    ->status_is(200)
    ->json_is( {'id' => 2,'status' => 'ok'} );

# index
my $result = 
    [
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
            'component' => 'Routes',
            'children'  => [],
            'folder'    => 0,
            'keywords'  => '',
            'opened'    => 0,
            'label'     => 'label2',
            'table'     => {},
            'id'        => 2
          }
        ];

my $data = $$test_data{$test}{'data'};
my $result = $$test_data{$test}{'result'};
$t->post_ok( $host.'/routes/index' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
$t->json_is( $result );


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


