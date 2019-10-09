# добавление группы настроек
# my $id = $self->insert_group({
#     "label"        => 'название',    - название для отображения, обязательное поле
#     "name",      => 'name',           - системное название, латиница, обязательное поле
#     "status"      => 0 или 1,          - активна ли группа
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

# добавляем тестовый раздел настроек
$t->post_ok( $host.'/settings/add_folder' => form => {
    "parent"        => 0,
    "name"          => 'test',
    "label"         => 'first test',
});

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'parent'      => 1,
            'name'        => 'name',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'id'        => '3',
            'status'    => 'ok'
        },
        'comment' => 'No status:' 
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'name'      => 'a',
            'parent'      => 'a',
            'label'       => 'label',
            'placeholder' => 'placeholder',
            'type'        => get_type(),
            'mask'        => 'mask',
            'value'       => 'value',
            'selected'    => '[]',
            'readonly'    => 0,
            'status'      => 0
        },
        'result' => {
            'message'   => "Validation error for 'name'. Field is empty or not exists",
            'status'    => 'fail',
        },
        'comment' => 'Name empty:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/settings/add' => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
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

# выбрать случайный html тип поля
sub get_type {
    my $i = int(rand( scalar(@$type) - 1 ));
    my $j = $$type[$i];

    return $$type[$i]{'value'};
}