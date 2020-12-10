# Сохранить информацию о пользователе
# my $id = $self->_save_user({
# 'id'           => 1,                 # До 9 цифр, обязательное поле
# 'surname'      => 'фамилия',         # До 24 букв, обязательное поле
# 'name'         => 'имя',             # До 24 букв, обязательное поле
# 'patronymic',  => 'отчество',        # До 32 букв, обязательное поле
# 'place'        => 'place',           # До 64 букв, цифр и знаков, обязательное поле
# 'country'      => 'RU',              # 2 буквы кода страны, обязательное поле
# 'timezone'     => -3.5,             # 2-4 буквы кода часового пояса, обязательное поле
# 'birthday'     => 807393600,      # 12 цифр, обязательное поле
# 'status'       => '1',               # 0 или 1, обязательное поле
# 'password'     => 'password1',       # До 64 букв, цифр и знаков, обязательное поле
# 'avatar'       => 1,              # До 9 цифр, обязательное поле
# 'email'        => 'email@email.ru'   # До 100 букв, цифр с @, обязательное поле
# 'phone'        => 'email@email.ru'   # +, 11 цифр, обязательное поле
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
use Test qw( get_last_id_user );

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

# Ввод пользователей для изменения
diag "Add users:";
my $test_data = {
};
$t->post_ok( $host.'/user/add' => {token => $token} => form => $test_data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

# Ввод ещё одного пользователя
diag "Add users:";
$test_data = {
};
$t->post_ok( $host.'/user/add' => {token => $token} => form => $test_data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}

# Ввод файла с аватаром
my $data = {
   'description' => 'description',
    upload => { file => './t/User/all_right.svg' }
};
diag "Insert media:";
$t->post_ok( $host.'/upload/' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    exit; 
}
diag "";

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'id'        => $answer,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'phone'        => '7(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'id'        => $answer,
            'status'    => 'ok'
        },
        'comment' => 'No email:' 
    },
    3 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'id'        => $answer,
            'status'    => 'ok'
        },
        'comment' => 'No phone:' 
    },
    4 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)-111-11-11',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'id'        => $answer,
            'status'    => 'ok'
        },
        'comment' => 'status 0:' 
    },
    5 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'avatar'       => 1,
            'email'        => '6@email.ru',
            'phone'        => '8(921)1111116',
            'status'       => 0,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'id'        => $answer,
            'status'    => 'ok'
        },
        'comment' => 'No password and no newpassword:' 
    },

    # отрицательные тесты
    6 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111119',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "/user/save _check_fields: didn't has required data in 'surname' = ''",
            'status'    => 'fail',
        },
        'comment' => 'No required field surname:' 
    },
    7 => {
        'data' => {
            'id'           => $answer+1,
            'login'        => 'login2',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '6@email.ru',
            'phone'        => '8(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "email '6\@email.ru' already used",
            'status'    => 'fail',
        },
        'comment' => "Email already used:"
    },
    8 => {
        'data' => {
            'id'           => $answer+1,
            'login'        => 'login2',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111116',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "phone '8(921)1111116' already used",
            'status'    => 'fail',
        },
        'comment' => "Telephone already used:"
    },
    9 => {
        'data' => {
            'id'           => 404,
            'login'        => 'login2',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '3@email.ru',
            'phone'        => '8(921)1111113',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "can't update 404 in users",
            'status'    => 'fail',
        },
        'comment' => "Wrong id:"
    },
    10 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password1',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "Password and newpassword are the same",
            'status'    => 'fail',
        },
        'comment' => "Password and newpassword are the same:" 
    },
    11 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => 'Empty newpassword',
            'status'    => 'fail',
        },
        'comment' => 'No newpassword:' 
    },
    12 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => 'Empty password',
            'status'    => 'fail',
        },
        'comment' => 'No password:' 
    },
    13 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'  => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "No email and no phone",
            'status'    => 'fail',
        },
        'comment' => 'No email and no phone:' 
    },
    14 => {
        'data' => {
            'id'           => 'qwerty',
            'login'        => 'login',
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '8(921)1111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "/user/save _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'Wrong id validation:'
    },
    15 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'avatar'       => 1,
            'email'        => 'emailright3@email.ru',
            'phone'        => '8(921)1111114',
            'status'       => 1,
            'groups'       => "[1,2,404,405]"
        },
        'result' => {
            'message'   => "group with id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Group doesn't exist:"
    },
    16 => {
        'data' => {
            'id'           => $answer,
            'login'        => 'login',
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => -3.5,
            'birthday'     => 807393600,
            'avatar'       => 404,
            'email'        => 'emailright3@email.ru',
            'phone'        => '8(921)1111114',
            'status'       => 1,
            'groups'       => "[1,2]"
        },
        'result' => {
            'message'   => "avatar with id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Avatar doesn't exist:"
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/save' => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

done_testing();

# # переинсталляция базы scorm_test
reset_test_db();