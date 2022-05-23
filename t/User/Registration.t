# Добавить пустой объект пользователя
# ( $user_id ) = $self->add();
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
use Test qw( get_last_id_user );

use Data::Dumper;

# переинсталляция базы scorm_test
reset_test_db();

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111',
        },
        'result' => {
            'id'        => $answer+1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'login'        => 'login2',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'email'        => '2@email.ru',
        },
        'result' => {
            'id'        => $answer+2,
            'status'    => 'ok'
        },
        'comment' => 'No phone:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'login'        => 'login',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111119'
        },
        'result' => {
            'message'   => "/user/registration _check_fields: didn't has required data in 'surname' = ''",
            'status'    => 'fail',
        },
        'comment' => 'No required field surname:' 
    },
    4 => {
        'data' => {
            'login'        => 'login2',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111'
        },
        'result' => {
            'message'   => "email '1\@email.ru' already used",
            'status'    => 'fail',
        },
        'comment' => "Email already used:"
    },
    5 => {
        'data' => {
            'login'        => 'login2',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'email'        => '9@email.ru',
            'phone'        => '8(921)1111111'
        },
        'result' => {
            'message'   => "phone '8(921)1111111' already used",
            'status'    => 'fail',
        },
        'comment' => "Telephone already used:"
    },
    6 => {
        'data' => {
            'login'        => 'login',
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'email'        => '7@email.ru',
            'phone'        => 'qwerty'
        },
        'result' => {
            'message'   => "/user/registration _check_fields: empty field 'phone', didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'Wrong phone validation:'
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/registration' => form => $data );
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