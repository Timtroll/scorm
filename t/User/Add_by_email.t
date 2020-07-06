# добавить информацию о пользователе, который зарегестрировался по электронному адресу
# my $id = $self->_insert_user({
# 'surname'      => 'фамилия',         # До 24 букв, обязательное поле
# 'name'         => 'имя',             # До 24 букв, обязательное поле
# 'patronymic',  => 'отчество',        # До 32 букв, обязательное поле
# 'place'        => 'место жительства',# До 64 букв, цифр и знаков, обязательное поле
# 'country'      => 'Россия',          # До 32 букв, обязательное поле
# 'timezone'     => '+3',              # +/- с 1/2 цифрами, обязательное поле
# 'birthday'     => '01.01.2000',      # 12 цифр, обязательное поле
# 'password'     => 'password1',       # До 64 букв, цифр и знаков, обязательное поле
# 'avatar'       => 'CKEditor',        # До 9 цифр, обязательное поле
# 'type'         => 1,                 # Цифра 1-4, обязательное поле
# 'email'        => 'email@email.ru'   # До 100 букв, цифр с @, обязательное поле
# });
use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Freee::Mock::TypeFields;

use Data::Dumper;

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'surname'",
            'status'    => 'fail',
        },
        'comment' => 'No surname:' 
    },
    3 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'name'",
            'status'    => 'fail',
        },
        'comment' => 'No name:' 
    },
    4 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'patronymic'",
            'status'    => 'fail',
        },
        'comment' => 'No patronymic:' 
    },
    5 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "Setting named 'country' is exists",
            'status'    => 'fail',
        },
        'comment' => 'No country:'
    },
    6 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'timezone' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No timezone:'
    },
    7 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'birthday' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No birthday:'
    },
    8 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'password' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No password:'
    },
    9 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'avatar' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No avatar:'
    },
    10 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'type' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No type:'
    },
    11 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'email' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No email:'
    },
    12 => {
        'data' => {
            'surname'      => 404,
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'место жительства',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'CKEditor',
            'type'         => 1,
            'email'        => 'email@email.ru'
        },
        'result' => {
            'message'   => "_check_fields: 'surname' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'Wrong type:'
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/add_by_email' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".users_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".users RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}