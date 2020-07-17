# Сохранить информацию о пользователе
# my $id = $self->_save_user({
# 'id'           => 1,                 # До 9 цифр, обязательное поле
# 'surname'      => 'фамилия',         # До 24 букв, обязательное поле
# 'name'         => 'имя',             # До 24 букв, обязательное поле
# 'patronymic',  => 'отчество',        # До 32 букв, обязательное поле
# 'place'        => 'place',           # До 64 букв, цифр и знаков, обязательное поле
# 'country'      => 'Россия',          # До 32 букв, обязательное поле
# 'timezone'     => '+3',              # +/- с 1/2 цифрами, обязательное поле
# 'birthday'     => '01.01.2000',      # 12 цифр, обязательное поле
# 'status'       => '1',               # 0 или 1, обязательное поле
# 'password'     => 'password1',       # До 64 букв, цифр и знаков, обязательное поле
# 'avatar'       => 'https://thispersondoesnotexist.com/image',              # До 9 цифр, обязательное поле
# 'type'         => 1,                 # Цифра 1-4, обязательное поле
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

use Data::Dumper;

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# Ввод пользователей для изменения
diag "Add users:";
my $test_data = {
    1 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '2@email.ru',
            'phone'        => '+2',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        }
    }
};


foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    $t->post_ok( $host.'/user/add' => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2010',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2010',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'No email:' 
    },
    3 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2010',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'No phone:' 
    },
    4 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2010',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'Status 0:' 
    },
    5 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+4',
            'birthday'     => '01.01.2010',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '6@email.ru',
            'phone'        => '+6',
            'status'       => 0,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'No password and no newpassword:' 
    },

    # отрицательные тесты
    6 => {
        'data' => {
            'id'           => 1,
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'surname'",
            'status'    => 'fail',
        },
        'comment' => 'No required field surname:' 
    },
    7 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '2@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => "email '2\@email.ru' already used",
            'status'    => 'fail',
        },
        'comment' => "Email already used:"
    },
    8 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+2',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => "phone '+2' already used",
            'status'    => 'fail',
        },
        'comment' => "Telephone already used:"
    },
    9 => {
        'data' => {
            'id'           => 404,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '3@email.ru',
            'phone'        => '+3',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => "can't update 404",
            'status'    => 'fail',
        },
        'comment' => "Wrong id:"
    },
    10 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'newpassword'  => 'password1',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => "Password and newpassword are the same",
            'status'    => 'fail',
        },
        'comment' => "Password and newpassword are the same:" 
    },
    11 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => 'No newpassword',
            'status'    => 'fail',
        },
        'comment' => 'No newpassword:' 
    },
    12 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => 'No password',
            'status'    => 'fail',
        },
        'comment' => 'No password:' 
    },
    13 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'  => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
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
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'newpassword'  => 'password2',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => '1@email.ru',
            'phone'        => '+1',
            'status'       => 1,
            'groups'       => "[1, 2, 3]"
        },
        'result' => {
            'message'   => "_check_fields: 'id' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'Wrong id validation:'
    },
    15 => {
        'data' => {
            'id'           => 1,
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'avatar'       => 'https://thispersondoesnotexist.com/image',
            'type'         => 1,
            'email'        => 'emailright3@email.ru',
            'phone'        => '+4',
            'status'       => 1,
            'groups'       => "[1, 2, 404, 405]"
        },
        'result' => {
            'message'   => "group with id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Group doesn't exist:"
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/save' => form => $data );
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
    if ( $t->app->config->{test} ) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".users_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".users RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_data_string" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_data_datetime" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('ALTER SEQUENCE "public".eav_items_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_items" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_links" RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}