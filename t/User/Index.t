#  Cписок юзеров по группам
# my $id = $self->_delete_user({
# 'id' => '1', # Id группы пользователей, до 9 цифр, обязательно
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

# Ввод пользователя
diag "Add user:";
my $data = {
    'surname'      => 'Фамилия',
    'name'         => 'Имя',
    'patronymic',  => 'Отчество',
    'place'        => 'Луна',
    'country'      => 'Киргизия',
    'timezone'     => '+3',
    'birthday'     => '01.01.2000',
    'password'     => 'password1',
    'avatar'       => 1234,
    'type'         => 1,
    'email'        => 'email@mail.ru',
    'phone'        => '9873636363',
    'status'       => 1
};
$t->post_ok( $host.'/user/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id' => 1
        },
        'result' => {
            "data" => {
               "list" => {
                    "body" => [
                        {
                            "surname" =>  "Фамилия",
                            "name" =>  "Имя",
                            "patronymic" =>  "Отчество",
                            "place" =>  "Луна",
                            "country" =>  "Киргизия",
                            "timezone" =>  "+3",
                            "birthday" =>  "01.01.2020",
                            "password" =>  "password1",
                            "avatar" =>  1234,
                            "type" =>  1,
                            "email" =>  "email\@mail.ru",
                            "emailconfirmed" =>  1,
                            "phone" =>  "9873636363",
                            "phoneconfirmed" =>  1,
                            "status" =>  1
                        }
                    ],
                    "settings" => {
                        "editable" => 1,
                        "massEdit" => 0,
                        "page" => {
                            "current_page" => 1,
                            "per_page" => 100,
                            "total" => 0
                        },
                        "removable" => 1,
                        "sort" => {
                            "name" => "id",
                            "order" => "asc"
                        }
                    }
                }
            },
            'status' => 'ok'
        },
        'comment' => 'All fields:' 
    },
    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "Could not take '404'",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'id'",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    4 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "_check_fields: 'id' didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id validation:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/' => form => $data );
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