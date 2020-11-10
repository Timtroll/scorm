# список роутов для группы
# 'id'        =>    1     -  id роута для изменения ( > 0 )
# 'list'      => 0 или 1  -   
# 'add'       => 0 или 1  -    
# 'edit'      => 0 или 1  -   
# 'delete'    => 0 или 1  -   
# 'status'    => 0 или 1  -  активен ли роут
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw(decode_json encode_json);

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и готовим таблицу групп
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'yfenbkec' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
my $token = $response->{'data'}->{'token'};


#  Вводим группу родителя
diag "Create group: ";
my $data = {'name' => 'test', 'label' => 'test', 'status' => 1};
$t->post_ok( $host.'/groups/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't create group");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

diag "Get list groups and create routes: ";
$t->post_ok( $host.'/groups/' )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8');
diag "";

my $test_data = {
    # отрицательные тесты
    1 => {
        'data' => {
            'parent'    => 404,
        },
        'result' => {
            'message'   => "Routes for Group id '404' is not exists",
            'status'    => 'fail'
        },
        'comment' => 'Wrong parent:' 
    },
    2 => {
        'data' => {
            'parent'    => 'mistake',
        },
        'result' => {
            'message'   => "_check_fields: 'parent' didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong field type:' 
    },
    3 => {
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'parent'",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/routes/' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

diag "All right:";
my $answer = $t->post_ok( $host.'/routes/' => form => {'parent' => 1} )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8');

my $json =  $answer->{tx}->{res}->{content}->{asset}->{content} ;
$json = decode_json $json;

# Проверка наличия реального роута в таблице
my @labels;
my $poss = '/routes';
foreach my $tmp ( @{$json->{'list'}->{'body'}} ) {
    push @labels, $tmp->{'label'};
}
ok( grep( $poss, @labels ) );
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