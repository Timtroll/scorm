# общий тест для экспорта настроек и роутов, связанных с ним

# создание группы настроек
# add folder
# my $id = $self->_insert_folder({
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "status",     => 1            - статус поля (1 - включено (ставится по умолчанию), 0 - выключено)
# });

# создание настройки
# add
# my $id = $self->_insert_setting({
# "parent"      => 0,           - обязательно (должно быть натуральным числом)
# "label"       => 'название',  - обязательно (название для отображения)
# "name",       => 'name'       - обязательно (системное название, латиница)
# "readonly"    => 0,           - не обязательно, по умолчанию 0
# "value"       => "",            - строка или json
# "type"        => "InputNumber", - тип поля из конфига
# "placeholder" => 'это название',- название для отображения в форме
# "mask"        => '\d+',         - регулярное выражение
# "selected"    => "CKEditor",    - значение по-умолчанию для select
# "required"    => 1              - обязательное поле
# });

# сохранение текущего состояния таблицы настроек
# export
# my $id = $self->_insert_export_setting({
# 'title' - обязательно (описание файла с настройками в базе)
# });

# удаление файла с экспортом и записи в таблице
# del_export
# my $id = $self->_delete_export_setting({
# 'id' - обязательно (id записи в таблице export_settings)
# });

# импорт сохранённой настройки
# import
# my $id = $self->_import_setting({
# 'id' - обязательно (id записи в таблице export_settings)
# });

# получение списка всех экспортированных настроек
# list_export
# my $list = $self->_get_list_exports({
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

use Data::Compare;
use Mojo::JSON qw( decode_json );

my ( $t, $host, $test_data, $route, $data, $result, $comment, $response, $token, $time_create, $filename, $regular, $file_path, $cmd );
$t = Test::Mojo->new('Freee');

# Включаем режим работы с тестовой базой и чистим таблицу
$t->app->config->{test} = 1 unless $t->app->config->{test};

# Чистка таблиц
clear_db();

# Установка адреса
$host = $t->app->config->{'host'};

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'yfenbkec' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
$response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
$token = $response->{'data'}->{'token'};

$test_data = {
    ### отрицательный тест - экспорт пустой таблицы
    1 => {
        'route' => '/settings/export',
        'data' => {
            'title'     => 'description',
        },
        'result' => {
            'message'   => 'can\'t get data from settings',
            'status'    => 'fail'
        },
        'comment' => 'export - empty table' 
    },

    # подготовка, создание папки для настроек:
    2 => {
        'route' => '/settings/add_folder',
        'data' => {
            'name'      => 'test',
            'label'     => 'first test',
            'parent'    => 0,
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        },
        'comment' => 'add_folder - new folder' 
    },

    # подготовка, ввод настройки:
    3 => {
        'route' => '/settings/add',
        'data' => {
            'parent'      => 1,
            'name'        => 'name2',
            'label'       => 'label2',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'add - all fields:' 
    },
    4 => {
        'route' => '/settings/add',
        'data' => {
            'parent'      => 1,
            'name'        => 'name3',
            'label'       => 'label3',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
        'comment' => 'add - no placeholder:' 
    },
    5 => {
        'route' => '/settings/add',
        'data' => {
            'parent'      => 1,
            'name'        => 'name4',
            'label'       => 'label4',
            'placeholder' => 'placeholder',
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'required'    => 0,
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => 4,
            'status'    => 'ok'
        },
        'comment' => 'add - no type:' 
    },

    # экспорт текущих настроек
    # положительные тесты
    6 => {
        'route' => '/settings/export',
        'data' => {
            'title'     => 'description',
        },
        'result' => {
            'id'        => 1,
            'status'    => 'ok'
        },
        'comment' => 'export - all right:' 
    },
    7 => {
        'route' => '/settings/export',
        'data' => {
            'title'     => 'description',
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'export - same description:' 
    },
    # отрицательные тесты
    8 => {
        'route' => '/settings/export',
        'data' => {
        },
        'result' => {
            'message'   => "/settings/export _check_fields: didn't has required data in 'title' = ''",
            'status'    => 'fail'
        },
        'comment' => 'export - no title:' 
    },

    # удаление экспорта
    # положительные тесты
    9 => {
        'route' => '/settings/del_export',
        'data' => {
            'id'     => 2,
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'del_export - all right:' 
    },
    # отрицательные тесты
    10 => {
        'route' => '/settings/del_export',
        'data' => {
            'id'     => 404,
        },
        'result' => {
            'message'   => 'Id \'404\' doesn\'t exist',
            'status'    => 'fail'
        },
        'comment' => 'del_export - id doesn\'t exist:' 
    },
    11 => {
        'route' => '/settings/del_export',
        'data' => {},
        'result' => {
            'message'   => "/settings/del_export _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'del_export - no id:' 
    },

    # импорт настроек
    # положительные тесты
    12 => {
        'route' => '/settings/import',
        'data' => {
            'id'     => 1,
        },
        'result' => {
            'status'    => 'ok'
        },
        'comment' => 'import - all right:' 
    },
    # отрицательные тесты
    13 => {
        'route' => '/settings/import',
        'data' => {
            'id'     => 2,
        },
        'result' => {
            'message'   => 'Id \'2\' doesn\'t exist',
            'status'    => 'fail'
        },
        'comment' => 'import - id doesn\'t exist:' 
    },
    14 => {
        'route' => '/settings/import',
        'data' => {},
        'result' => {
            'message'   => "/settings/import _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'import - no id:' 
    }
};

# запросы и проверка их выполнения
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $route = $$test_data{$test}{'route'};
    $data = $$test_data{$test}{'data'};
    $result = $$test_data{$test}{'result'};
    $comment = $$test_data{$test}{'comment'};

    diag ( $comment );

    # проверка подключения
    $t->post_ok( $host . $route => {token => $token} => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag "";
};

# проверка вывода списка экспортированных файлов
diag "list_export - all right:";
$result = {
    "list" => [
        {
            "id"           => 1,
            "title"        => "description"
        }
    ],
    'status'    => 'ok'
};

$t->post_ok( $host.'/settings/list_export' => {token => $token} );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');

# проверка данных ответа
$response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
# url проверяется отдельно, так как оно генерируется случайно
$time_create = $response->{'list'}->[0]->{'time_create'};
delete $response->{'list'}->[0]->{'time_create'};
$filename = $response->{'list'}->[0]->{'filename'};
delete $response->{'list'}->[0]->{'filename'};

ok( Compare( $result, $response ), "Response is correct" );
$regular = '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\+\d{2}$';
ok( $time_create =~ /$regular/, "Time_create is correct" );
$regular = '^\d{10}\.json$';
ok( $filename =~ /$regular/, "Filename is correct" );

#------------------------------------------------------------------------------------------------------------
# Чистка директории
$file_path = $t->app->{'config'}->{'export_settings_path'};

$cmd = `rm $file_path/*.json`;
ok( !$?, "Files were deleted");

# Чистка таблиц
clear_db();

done_testing();

# очистка тестовых таблиц
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');

        $t->app->pg_dbh->do('ALTER SEQUENCE "public".export_settings_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".export_settings RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}

# выбрать случайный html тип поля
sub get_type {
    my $i = int(rand( scalar(@$type) - 1 ));
    my $j = $$type[$i];

    return $$type[$i]{'value'};
}