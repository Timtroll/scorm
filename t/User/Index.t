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

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

# Ввод пользователей
diag "Add users:";
my $test_data = {
    1 => {
        'data' => {
        },
        'result' => {
            'id'        => $answer+1,
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
        },
        'result' => {
            'id'        => $answer+2,
            'status'    => 'ok'
        }
    },
    3 => {
        'data' => {
        },
        'result' => {
            'id'        => $answer+3,
            'status'    => 'ok'
        }
    },
    4 => {
        'data' => {
        },
        'result' => {
            'id'        => $answer+4,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    $t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

# Сохранение пользователей
diag "Save users:";
$test_data = {
    1 => {
        'data' => {
            'id'           => $answer+1,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login1',
            'email'        => '1@email.ru',
            'phone'        => '7(921)1111111',
            'status'       => 1,
            'groups'       => "[1]"
        },
        'result' => {
            'id'        => $answer+1,
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'id'           => $answer+2,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login2',
            'email'        => '2@email.ru',
            'phone'        => '7(921)1111112',
            'status'       => 1,
            'groups'       => "[1,2]"
        },
        'result' => {
            'id'        => $answer+2,
            'status'    => 'ok'
        }
    },
    3 => {
        'data' => {
            'id'           => $answer+3,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login3',
            'email'        => '3@email.ru',
            'phone'        => '7(921)1111113',
            'status'       => 1,
            'groups'       => "[2,1,3]"
        },
        'result' => {
            'id'        => $answer+3,
            'status'    => 'ok'
        }
    },
    4 => {
        'data' => {
            'id'           => $answer+4,
            'surname'      => 'фамилия_right',
            'name'         => 'имя_right',
            'patronymic',  => 'отчество_right',
            'place'        => 'place',
            'country'      => 'RU',
            'timezone'     => 3,
            'birthday'     => 807393600,
            'login'        => 'login4',
            'email'        => '4@email.ru',
            'phone'        => '7(921)1111114',
            'status'       => 1,
            'groups'       => "[3,2,1]"
        },
        'result' => {
            'id'        => $answer+4,
            'status'    => 'ok'
        }
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data} ) {
    $t->post_ok( $host.'/user/save' => {token => $token} => form => $$test_data{$test}{'data'} );
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
            'group_id' => 1,
            'status'   => 2
        },
        'result' => {
            "list" => {
                "body" => [
                    {
                        "id" =>  1,
                        "timezone" => 3,
                        "email" =>  "admin\@admin",
                        "phone" =>  '',
                        "status" =>  1,
                        "eav_id" =>  5,
                        "login" => "admin",
                        'place' => 'scorm',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "admin",
                        'surname' => "admin",
                        'patronymic' => "admin"
                    },
                    {
                        "id" =>  $answer+1,
                        "timezone" => 3,
                        "email" =>  "1\@email.ru",
                        "phone" =>  "7(921)1111111",
                        "status" =>  1,
                        "eav_id" =>  10,
                        "login" => "login1",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    },
                    {
                        "id" =>  $answer+2,
                        "timezone" => 3,
                        "email" =>  "2\@email.ru",
                        "phone" =>  "7(921)1111112",
                        "status" =>  1,
                        "eav_id" =>  11,
                        "login" => "login2",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    },
                    {
                        "id" =>  $answer+3,
                        "timezone" => 3,
                        "email" =>  "3\@email.ru",
                        "phone" =>  "7(921)1111113",
                        "status" =>  1,
                        "eav_id" =>  12,
                        "login" => "login3",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    },
                    {
                        "id" =>  $answer+4,
                        "timezone" => 3,
                        "email" =>  "4\@email.ru",
                        "phone" =>  "7(921)1111114",
                        "status" =>  1,
                        "eav_id" =>  13,
                        "login" => "login4",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    }
                ],
                "settings" => {
                    "editable" => 1,
                    "massEdit" => 0,
                    "page" => {
                        "current_page" => 1,
                        "per_page" => 100,
                        "total" => 5
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
            'group_id' => 1,
            'status'   => 1
        },
        'result' => {
            "list" => {
                "body" => [
                    {
                        "id" =>  1,
                        "timezone" => 3,
                        "email" =>  "admin\@admin",
                        "phone" =>  '',
                        "status" =>  1,
                        "eav_id" =>  5,
                        "login" => "admin",
                        'place' => 'scorm',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "admin",
                        'surname' => "admin",
                        'patronymic' => "admin"
                    },
                    {
                        "id" =>  $answer+1,
                        "timezone" => 3,
                        "email" =>  "1\@email.ru",
                        "phone" =>  "7(921)1111111",
                        "status" =>  1,
                        "eav_id" =>  10,
                        "login" => "login1",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    },
                    {
                        "id" =>  $answer+2,
                        "timezone" => 3,
                        "email" =>  "2\@email.ru",
                        "phone" =>  "7(921)1111112",
                        "status" =>  1,
                        "eav_id" =>  11,
                        "login" => "login2",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    },
                    {
                        "id" =>  $answer+3,
                        "timezone" => 3,
                        "email" =>  "3\@email.ru",
                        "phone" =>  "7(921)1111113",
                        "status" =>  1,
                        "eav_id" =>  12,
                        "login" => "login3",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    },
                    {
                        "id" =>  $answer+4,
                        "timezone" => 3,
                        "email" =>  "4\@email.ru",
                        "phone" =>  "7(921)1111114",
                        "status" =>  1,
                        "eav_id" =>  13,
                        "login" => "login4",
                        'place' => 'place',
                        'birthday' => '1995-08-03 00:00:00',
                        'import_source' => '',
                        'country' => 'RU',
                        'name' => "имя_right",
                        'surname' => "фамилия_right",
                        'patronymic' => "отчество_right"
                    }
                ],
                "settings" => {
                    "editable" => 1,
                    "massEdit" => 0,
                    "page" => {
                        "current_page" => 1,
                        "per_page" => 100,
                        "total" => 5
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
            'group_id' => 1,
            'status'   => 0
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
            'group_id'     => 1,
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
            'message'   => "/user _check_fields: didn't has required data in 'group_id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    6 => {
        'data' => {
            'group_id'        => - 404
        },
        'result' => {
            'message'   => "/user _check_fields: empty field 'group_id', didn't match regular expression",
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

# переинсталляция базы scorm_test
reset_test_db();
