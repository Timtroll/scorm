# добавить информацию о пользователе, который зарегестрировался по электронному адресу
# my $id = $self->_insert_user({
# 'surname'      => 'фамилия',         # До 24 букв, обязательное поле
# 'name'         => 'имя',             # До 24 букв, обязательное поле
# 'patronymic',  => 'отчество',        # До 32 букв, обязательное поле
# 'place'        => 'place',           # До 64 букв, цифр и знаков, обязательное поле
# 'country'      => 'Россия',          # До 32 букв, обязательное поле
# 'timezone'     => '+3',              # +/- с 1/2 цифрами, обязательное поле
# 'birthday'     => '01.01.2000',      # 12 цифр, обязательное поле
# 'status'       => '1',               # 0 или 1, обязательное поле
# 'password'     => 'password1',       # До 64 букв, цифр и знаков, обязательное поле
# 'avatar'       => 1234,              # До 9 цифр, обязательное поле
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

my $test_data = {
    # положительные тесты
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
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79212222222',
            'status'       => 1
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
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
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79212222221',
            'status'       => 0
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'Status 0:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'surname'",
            'status'    => 'fail',
        },
        'comment' => 'No surname:' 
    },
    4 => {
        'data' => {
            'surname'      => 'фамилия',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'name'",
            'status'    => 'fail',
        },
        'comment' => 'No name:' 
    },
    5 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'patronymic'",
            'status'    => 'fail',
        },
        'comment' => 'No patronymic:' 
    },
    6 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'country'",
            'status'    => 'fail',
        },
        'comment' => 'No country:'
    },
    7 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'timezone'",
            'status'    => 'fail',
        },
        'comment' => 'No timezone:'
    },
    8 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'birthday'",
            'status'    => 'fail',
        },
        'comment' => 'No birthday:'
    },
    9 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'password'",
            'status'    => 'fail',
        },
        'comment' => 'No password:'
    },
    10 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'type'         => 1,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'avatar'",
            'status'    => 'fail',
        },
        'comment' => 'No avatar:'
    },
    11 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'phone'        => '+79211111111',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'type'",
            'status'    => 'fail',
        },
        'comment' => 'No type:'
    },
    12 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'phone'",
            'status'    => 'fail',
        },
        'comment' => 'No phone:'
    },
    13 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79211111111a',
            'status'       => 1
        },
        'result' => {
            'message'   => "_check_fields: 'phone' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No status:'
    },
    14 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'Россия',
            'timezone'     => '+3',
            'birthday'     => '01.01.2000',
            'password'     => 'password1',
            'avatar'       => 1234,
            'type'         => 1,
            'phone'        => '+79212222222',
            'status'       => 1
        },
        'result' => {
            'message'   => "phone '+79212222222' already used",
            'status'    => 'fail',
        },
        'comment' => "Telephone already used:"
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/add_by_phone' => form => $data );
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