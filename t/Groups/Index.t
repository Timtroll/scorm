# вывод списка групп в виде объекта как в Mock
#    "label"       => "scorm",
#    "id"          => 1,
#    "component"   => "Groups",
#    "opened"      => 0,
#    "folder"      => 1,
#    "keywords"    => "",
#    "children"    => [],

use Test::More;
use Test::Mojo;
use FindBin;
use Data::Dumper;
use Mojo::JSON qw(decode_json encode_json);
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
            'name'      => 'name1',
            'label'     => 'label1',
            'publish'    => 1
        },
        'result' => {
            'id'        => '1',
            'publish'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2',
            'publish'    => 1
        },
        'result' => {
            'id'        => '2',
            'publish'    => 'ok' 
        }
    }
};
diag "Create groups:";
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/groups/add' => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
}
diag "";

# Проверка ввода в Groups
my $result = {
    'list' => [
        {
            'label'     => 'label1',
            'id'        => 1,
            'opened'    => 0,
            'children'  => [],
            'component' => 'Groups',
            'folder'    => 0,
            'keywords'  => 'label1'
        },
        {
            'label'     => 'label2',
            'id'        => 2,
            'opened'    => 0,
            'children'  => [],
            'component' => 'Groups',
            'folder'    => 0,
            'keywords'  => 'label2'
        }
    ],
    'publish' => 'ok'
};

diag "All groups:";
$t->post_ok( $host.'/groups/' )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );
diag "";

diag "Create routes:";
my $answer = $t->post_ok( $host.'/routes/' => form => {'parent' => 1} )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8');

my $json =  $answer->{tx}->{res}->{content}->{asset}->{content} ;
$json = decode_json $json;

# Проверка наличия реального роута в таблице
my @labels;
my $poss = '/groups';
foreach my $tmp ( @{$json->{'list'}->{'body'}} ) {
    push @labels, $tmp->{'label'};
}
ok( grep( $poss, @labels ) );

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".routes_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".routes RESTART IDENTITY CASCADE');
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


