# добавить информацию о пользователе, который зарегестрировался по электронному адресу
# my $id = $self->_insert_user({
# 'surname'      => 'фамилия',         # До 24 букв, обязательное поле
# 'name'         => 'имя',             # До 24 букв, обязательное поле
# 'patronymic',  => 'отчество',        # До 32 букв, обязательное поле
# 'place'        => 'place',           # До 64 букв, цифр и знаков, обязательное поле
# 'country'      => 'RU',              # 2 буквы кода страны, обязательное поле
# 'timezone'     => 12.75,             # цифры часового пояса, обязательное поле
# 'birthday'     => 807393600,      # 12 цифр, обязательное поле
# 'status'       => '1',               # 0 или 1, обязательное поле
# 'password'     => 'password1',       # До 64 букв, цифр и знаков, обязательное поле
# 'avatar'       => 1,                 # До 64 символов, обязательное поле
# 'type'         => 1,                 # Цифра 1-4, обязательное поле
# 'email'        => 'email@email.ru',  # До 100 букв, цифр с @, обязательное поле
# 'phone'        => '+12345678901',    # +, 11 цифр, обязательное поле,
# 'groups'       => '[1]               # До 255 цифр в массиве, обязательное поле
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

# Ввод групп
my $data = {
    1 => {
        'data' => {
            'name'      => 'name1',
            'label'     => 'label1',
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'label'     => 'label2',
            'status'    => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    },
    3 => {
        'data' => {
            'name'      => 'name3',
            'label'     => 'label3',
            'status'    => 1
        },
        'result' => {
            'id'        => '3',
            'status'    => 'ok' 
        }
    }
};
diag "Create groups:";
foreach my $test (sort {$a <=> $b} keys %{$data}) {
    $t->post_ok( $host.'/groups/add' => form => $$data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$data{$test}{'result'} );
}
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'emailright@email.ru',
            'phone'        => '+79212222222',
            'status'       => 1,
            'groups'       => "[1,2,3]"
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
            'country'      => 'RU',
            'timezone'     => 12.75,
            'password'     => 'password1',
            'email'        => 'emailright2@email.ru',
            'phone'        => '+79212222221',
            'status'       => 1,
            'groups'       => "[2]"
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
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'email@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
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
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'email@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
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
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'email@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'country'",
            'status'    => 'fail',
        },
        'comment' => 'No country:'
    },
    6 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'email@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'timezone'",
            'status'    => 'fail',
        },
        'comment' => 'No timezone:'
    },
    7 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'avatar'       => 1,
            'email'        => 'email@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'password'",
            'status'    => 'fail',
        },
        'comment' => 'No password:'
    },
    8 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'email'",
            'status'    => 'fail',
        },
        'comment' => 'No email:'
    },
    9 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'email@email.ru',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'phone'",
            'status'    => 'fail',
        },
        'comment' => 'No phone:'
    },
    10 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '+++',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "_check_fields: 'email' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => 'No status:'
    },
    11 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'emailright@email.ru',
            'phone'        => '+79211111111',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "email 'emailright\@email.ru' already used",
            'status'    => 'fail',
        },
        'comment' => "Email already used:"
    },
    12 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'emailright3@email.ru',
            'phone'        => '+79212222222',
            'status'       => 1,
            'groups'       => "[1,2,3]"
        },
        'result' => {
            'message'   => "phone '+79212222222' already used",
            'status'    => 'fail',
        },
        'comment' => "Telephone already used:"
    },
    13 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'emailright3@email.ru',
            'phone'        => '+71111111114',
            'status'       => 1,
            'groups'       => "[1,2,404,405]"
        },
        'result' => {
            'message'   => "group with id '404' doesn't exist",
            'status'    => 'fail',
        },
        'comment' => "Group doesn't exist:"
    },
    14 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'emailright3@email.ru',
            'phone'        => '+71111111114',
            'status'       => 1,
            'groups'       => "[]"
        },
        'result' => {
            'message'   => "_check_fields: 'groups' didn't match regular expression",
            'status'    => 'fail',
        },
        'comment' => "No groups:"
    },
    15 => {
        'data' => {
            'surname'      => 'фамилия',
            'name'         => 'имя',
            'patronymic',  => 'отчество',
            'place'        => 'place',
            'country'      => 'UR',
            'timezone'     => 12.75,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => 'emailright3@email.ru',
            'phone'        => '+71111111114',
            'status'       => 1,
            'groups'       => "[1]"
        },
        'result' => {
            'message'   => "_check_fields: 'country' doesn't belong to list of valid expressions",
            'status'    => 'fail',
        },
        'comment' => "Wrong country:"
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/add' => form => $data );
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
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".groups_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".groups RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('ALTER SEQUENCE "public".users_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".users RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_data_string" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_data_datetime" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('ALTER SEQUENCE "public".eav_items_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_items" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."EAV_links" RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('TRUNCATE TABLE "public"."user_groups" RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}