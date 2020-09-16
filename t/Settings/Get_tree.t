# получить дерево без листьев
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw( decode_json );
use Data::Compare;
use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}
my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и готовим таблицу групп
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# Ввод фолдера
diag "Add folder parent:";
my $data = {
    'name'      => 'testName',
    'label'     => 'testLabel',
    'parent'    => 0,
    'publish'    => 1
};
$t->post_ok( $host.'/settings/add_folder' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');

my $result = {
    'publish' => 'ok',
    'list' => [
        {
            'label'     => 'testLabel',
            'name'      => 'testName',
            'folder'    => 1,
            'parent'    => 0,
            'id'        => 1,
            'parent'    => 0,
            'children'  => []
        }
    ]
};

diag "Get tree:";
$t->post_ok($host.'/settings/get_tree' => form => $data )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8');

    # проверка данных ответа
    my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
    my $keywords = $response->{'list'}->[0]->{'keywords'};
    delete $response->{'list'}->[0]->{'keywords'};
    ok( Compare( $result, $response ), "Response is correct" );

    # keywords проверяются отдельно, так как их порядок случаен
    ok( $keywords eq $$result{'list'}[0]{'label'} . ' ' . $$result{'list'}[0]{'name'} || $keywords eq $$result{'list'}[0]{'name'} . ' ' . $$result{'list'}[0]{'label'}, "Keywords are correct" );
diag "";

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}