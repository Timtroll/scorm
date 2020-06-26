# создание пользователя
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
# clear_db();
# warn Dumper $t->app->config;

# установка адреса
my $host = $t->app->config->{'host'};

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'surname'    => 'test',
            'name'       => 'name',
            'patronymic' => 'patronymic',
            'place'      => 'place',
            'country'    => 'country',
            'timezone'   => '10',
            'birthday'   => '06.01.1972',
            'password'   => 'password',
            'newpassword'=> '',
            'avatar'     => 1,
            'type'       => 1,
            'email'      => 'troll@spam.net.ua',
            'phone'      => '+7(981) 801-0874',
            'status'     => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        },
        'comment' => 'Add user:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
warn Dumper $data;

    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/add' => form => $data );
# warn Dumper $t->status_is(200)->{tx}->{res};
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag"";
};

# done_testing();

# # очистка тестовых таблиц
# sub clear_db {
#     if ($t->app->config->{test}) {
#         $t->app->pg_dbh->do('ALTER SEQUENCE "public".settings_id_seq RESTART');
#         $t->app->pg_dbh->do('TRUNCATE TABLE "public".settings RESTART IDENTITY CASCADE');
#     }
#     else {
#         warn("Turn on 'test' option in config")
#     }
# }
