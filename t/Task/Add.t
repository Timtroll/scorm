# добавить задание
# my $id = $self->_insert_task({
# 'parent'      => 'ID родителя',                   # До 9 цифр, обязательное поле
# 'name'        => 'название',                      # До 256 букв и цифр, обязательное поле
# 'label'       => 'описание поля для отображения', # До 256 букв, цифр и знаков, обязательное поле
# 'description' => 'краткое содержание',            # До 256 букв, цифр и знаков, обязательное поле
# 'content'     => 'полное содержание',             # До 2048 букв, цифр и знаков, обязательное поле
# 'attachment'  => 'массив ID вложенных файлов',    # До 255 цифр в массиве, обязательное поле
# 'keywords'    => 'ключевые слова и фразы',        # До 2048 символов, слова, разделенные запятыми, обязательное поле
# 'url'         => 'https://test.com',                  # До 256 символов, электронный адрес, обязательное поле
# 'seo'         => 'дополнительное поле для seo',   # До 2048 букв, цифр и знаков, обязательное поле
# 'status'      => '1'                              # 0 или 1, обязательное поле
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
use Test qw( get_last_id_EAV );

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
my $answer = get_last_id_EAV( $t->app->pg_dbh );

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
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

    $t->post_ok( $host.'/task/add' => {token => $token} => form => $data );
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