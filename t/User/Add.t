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
use Mojo::JSON qw( decode_json );
use Install qw( reset_test_db );
use Test qw( get_last_id_user clear_db );

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

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'parent'    => 0
        },
        'result' => {
            'id'        => $answer + 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/add' => {token => $token} => form => $data );
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
clear_db( $t->app->config->{test}, $t->app->pg_dbh );