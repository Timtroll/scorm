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
use Mojo::JSON qw( decode_json );

use Data::Dumper;

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
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
    },
    4 => {
        'data' => {
            'name'      => 'name4',
            'label'     => 'label4',
            'status'    => 1
        },
        'result' => {
            'id'        => '4',
            'status'    => 'ok' 
        }
    }
};
diag "Create groups:";
foreach my $test (sort {$a <=> $b} keys %{$data}) {
    $t->post_ok( $host.'/groups/add' => {token => $token} => form => $$data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$data{$test}{'result'} );
}
diag "";

# Ввод пользователя
diag "Add users:";
my $test_data = {
    1 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '1@email.ru',
            'phone'        => '+7(921)1111111',
            'status'       => 1,
            'groups'       => "[1]"
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
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '2@email.ru',
            'phone'        => '+7(921)1111112',
            'status'       => 1,
            'groups'       => "[1,2]"
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        }
    },
    3 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '3@email.ru',
            'phone'        => '+7(921)1111113',
            'status'       => 1,
            'groups'       => "[2,1,3]"
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        }
    },
    4 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '4@email.ru',
            'phone'        => '+7(921)1111114',
            'status'       => 1,
            'groups'       => "[3,2,1]"
        },
        'result' => {
            'id'        => 4,
            'status'    => 'ok'
        }
    },
    5 => {
        'data' => {
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'password'     => 'password1',
            'avatar'       => 1,
            'email'        => '5@email.ru',
            'phone'        => '+7(921)1111115',
            'status'       => 1,
            'groups'       => "[3,2,4]"
        },
        'result' => {
            'id'        => 5,
            'status'    => 'ok'
        }
    }
};


foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    $t->post_ok( $host.'/user/add_user' => {token => $token} => form => $$test_data{$test}{'data'} );
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
            'id' => 1
        },
        'result' => {
            "list" => {
                "body" => [
                    {
                        "id" =>  1,
                        "timezone" => 3,
                        "password" =>  '',
                        "email" =>  "1\@email.ru",
                        "phone" =>  "+7(921)1111111",
                        "status" =>  1,
                        "eav_id" =>  1,
                        "groups" => "[1]"
                    },
                    {
                        "id" =>  2,
                        "timezone" => 3,
                        "password" =>  '',
                        "email" =>  "2\@email.ru",
                        "phone" =>  "+7(921)1111112",
                        "status" =>  1,
                        "eav_id" =>  2,
                        "groups" => "[1,2]"
                    },
                    {
                        "id" =>  3,
                        "timezone" => 3,
                        "password" => '',
                        "email" =>  "3\@email.ru",
                        "phone" =>  "+7(921)1111113",
                        "status" =>  1,
                        "eav_id" =>  3,
                        "groups" => "[2,1,3]"
                    },
                    {
                        "id" =>  4,
                        "timezone" => 3,
                        "password" =>  '',
                        "email" =>  "4\@email.ru",
                        "phone" =>  "+7(921)1111114",
                        "status" =>  1,
                        "eav_id" =>  4,
                        "groups" => "[3,2,1]"
                    }
                ],
                "settings" => {
                    "editable" => 1,
                    "massEdit" => 0,
                    "page" => {
                        "current_page" => 1,
                        "per_page" => 100,
                        "total" => 4
                    },
                    "removable" => 1,
                    "sort" => {
                        "name" => "id",
                        "order" => "asc"
                    }
                }
            },
            'status' => 'ok'
        },
        'comment' => 'No status:' 
    },    
    2 => {
        'data' => {
            'id'     => 1,
            'status' => 1
        },
        'result' => {
            "list" => {
                "body" => [
                    {
                        "id" =>  1,
                        "timezone" =>  3,
                        "password" =>  '',
                        "email" =>  "1\@email.ru",
                        "phone" =>  "+7(921)1111111",
                        "status" =>  1,
                        "eav_id" =>  1,
                        "groups" => "[1]"
                    },
                    {
                        "id" =>  2,
                        "timezone" =>  3,
                        "password" =>  '',
                        "email" =>  "2\@email.ru",
                        "phone" =>  "+7(921)1111112",
                        "status" =>  1,
                        "eav_id" =>  2,
                        "groups" => "[1,2]"
                    },
                    {
                        "id" =>  3,
                        "timezone" =>  3,
                        "password" =>  '',
                        "email" =>  "3\@email.ru",
                        "phone" =>  "+7(921)1111113",
                        "status" =>  1,
                        "eav_id" =>  3,
                        "groups" => "[2,1,3]"
                    },
                    {
                        "id" =>  4,
                        "timezone" =>  3,
                        "password" =>  '',
                        "email" =>  "4\@email.ru",
                        "phone" =>  "+7(921)1111114",
                        "status" =>  1,
                        "eav_id" =>  4,
                        "groups" => "[3,2,1]"
                    }
                ],
                "settings" => {
                    "editable" => 1,
                    "massEdit" => 0,
                    "page" => {
                        "current_page" => 1,
                        "per_page" => 100,
                        "total" => 4
                    },
                    "removable" => 1,
                    "sort" => {
                        "name" => "id",
                        "order" => "asc"
                    }
                }
            },
            'status' => 'ok'
        },
        'comment' => 'status 1:' 
    },
    3 => {
        'data' => {
            'id'     => 1,
            'status' => 0
        },
        'result' => {
            "list" => {
                "body" => [],
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
            },
            'status' => 'ok'
        },
        'comment' => 'status 0:' 
    },
    4 => {
        'data' => {
            'id'     => 1,
            'page'   => 404
        },
        'result' => {
            "list" => {
                "body" => [],
                "settings" => {
                    "editable" => 1,
                    "massEdit" => 0,
                    "page" => {
                        "current_page" => 404,
                        "per_page" => 100,
                        "total" => 0
                    },
                    "removable" => 1,
                    "sort" => {
                        "name" => "id",
                        "order" => "asc"
                    }
                }
            },
            'status' => 'ok'
        },
        'comment' => 'Page 404:' 
    },
    # отрицательные тесты
    5 => {
        'result' => {
            'message'   => "_check_fields: didn't has required data in 'id'",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    6 => {
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
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/' => {token => $token} => form => $data );
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