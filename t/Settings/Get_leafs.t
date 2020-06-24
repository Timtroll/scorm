#!/usr/bin/perl -w
# выбираем листья ветки дерева
# my $id = $self->get_leafs();
# 'id' - id фолдера для которого выбираем листья
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;
use Mojo::JSON qw(decode_json encode_json);

use Data::Dumper;

BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

my $t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и готовим таблицу групп
$t->app->config->{test} = 1 unless $t->app->config->{test};
clear_db();

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# Ввод фолдера
diag "Add folder:";
my $data = {
    'name'      => 'test',
    'label'     => 'test',
    'parent'    => 0,
    'status'    => 1
};
$t->post_ok( $host.'/settings/add_folder' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# Ввод настройки
diag "Add setting:";
$data = {
    'name'      => 'name',
    'label'     => 'label',
    'status'    => 1,
    'parent'    => 1
};
$t->post_ok( $host.'/settings/add' => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag "Can't connect";
    exit;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id' => 0
        },
        'result' => {
           'status' => 'ok',
           'list' => {
                'body' => [
                    {
                        'placeholder'   => '',
                        'parent'        => 0,
                        'id'            => 1,
                        'selected'      => '',
                        'name'          => 'test',
                        'readonly'      => 0,
                        'mask'          => '',
                        'required'      => 0,
                        'status'        => 1,
                        'value'         => '',
                        'type'          => '',
                        'label'         => 'test',
                        'folder'        => 1
                    }
                ],
                'settings' => {
                    'removable' => 1,
                    'sort' => {
                        'order'         => 'asc',
                        'name'          => 'id'
                    },
                    'massEdit' => 0,
                    'page' => {
                        'per_page'      => 100,
                        'total'         => 1,
                        'current_page'  => 1
                    },
                    'editable' => 1
                }
            }
        },
        'comment' => 'Root folder:'
    },
    2 => {
        'data' => {
            'id'    => 2
        },
        'result' => {
            'list' => {
                'body' => [],
                'settings' => {
                    'sort' => {
                        'order'     => 'asc',
                        'name'      => 'id'
                    },
                    'removable' => 1,
                    'editable'  => 1,
                    'page' => {
                        'current_page'  => 1,
                        'per_page'      => 100,
                        'total'         => 0
                    },
                    'massEdit' => 0
                }
            },
            'status' => 'ok'
        },
        'comment' => 'Folder without leafs:'
    },
    3 => {
        'data' => {
            'id'    => 1
       },
        'result' => {
            'list' => {
                'settings' => {
                    'editable' => 1,
                    'page' => {
                          'current_page' => 1,
                          'total' => 1,
                          'per_page' => 100
                    },
                    'massEdit' => 0,
                    'removable' => 1,
                    'sort' => {
                        'name' => 'id',
                        'order' => 'asc'
                    }
                },
                'body' => [
                    {
                        'readonly' => 0,
                        'label' => 'label',
                        'id' => 2,
                        'folder' => 0,
                        'parent' => 1,
                        'name' => 'name',
                        'type' => '',
                        'required' => 0,
                        'placeholder' => '',
                        'mask' => '',
                        'value' => '',
                        'selected' => '',
                        'status' => 1
                    }
                ]
            },
            'status' => 'ok'
        },
        'comment' => 'Folder with leaf:'
    },
    
    # отрицательные тесты
    4 => {
        'data' => {
            'id'    => 404,
        },
        'result' => {
            'message'   => "Setting id '404' not exists",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    5 => {
        'data' => {
            'id'    => 'mistake',
        },
        'result' => {
            'message'   => "Validation error for 'id'. Field has wrong type",
            'status'    => 'fail'
        },
        'comment' => 'Wrong field type:' 
    },
    6 => {
        'result' => {
            'message'   => "Validation error for 'id'. Field is empty or not exists",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/settings/get_leafs' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}