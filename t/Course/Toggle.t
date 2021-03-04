# изменить поле задания
# my $id = $self->_toggle_course({
# 'id'          => 1,                               # До 9 цифр, обязательное поле
# 'fieldname'   => 'название поля',                 # status, обязательное поле
# 'status'      => '1'                              # 0 или 1, обязательное поле
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

# Добавление предмета
my $data = {
};
my $result = {
    'id'        => $answer + 1,
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
    # положительные тесты
    1 => {
        'data' => {
            'id'        => $answer + 1,
            'fieldname' => 'status',
            'value'     => 0
        },
        'result' => {
            'status'    => 'ok',
            'id'        => $answer + 1
        },
        'comment' => 'All right:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 1,
            'fieldname' => 'status'
        },
        'result' => {
            'message'   => "/course/toggle _check_fields: didn't has required data in 'value' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No value:'
    },
    3 => {
        'data' => {
            'fieldname' => 'status',
            'value'    => 1,
        },
        'result' => {
            'message'   => "/course/toggle _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'value'     => 1,
        },
        'result' => {
            'message'   => "/course/toggle _check_fields: didn't has required data in 'fieldname' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No fieldname:' 
    },
    5 => {
        'data' => {
            'id'        => 404,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'message'   => "Course with '404' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    6 => {
        'data' => {
            'id'        => 0,
            'fieldname' => 'status',
            'value'     => 1
        },
        'result' => {
            'message'   => "Course with '0' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => '0 id:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/course/toggle' => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

done_testing();

# переинсталляция базы scorm_test
reset_test_db();