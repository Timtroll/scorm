#  Редактирование пользователя
# my $id = $self->_delete_user({
# 'id' => '1', # Id пользователя, до 9 цифр, обязательно
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
    $t->post_ok( $host.'/groups/add' => {token => $token} => form => $$data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$data{$test}{'result'} );
}
diag "";

# Ввод пользователя
diag "Add user:";
$data = {
    'surname'      => 'фамилия_right',
    'name'         => 'имя_right',
    'patronymic',  => 'отчество_right',
    'place'        => 'place',
    'country'      => 'RU',
    'timezone'     => 3,
    'birthday'     => 807303600,
    'password'     => 'password1',
    'avatar'       => 1,
    'email'        => 'emailright@email.ru',
    'phone'        => '+7(921)2222222',
    'status'       => 1,
    'groups'       => "[1,2,3]"
};
$t->post_ok( $host.'/user/add_user' => {token => $token} => form => $data );
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
                "id"   => 1,
                "tabs" => [
                    {
                        "fields" => [
                            {"name" => "имя_right"},
                            {"patronymic" => "отчество_right"},
                            {"surname" => "фамилия_right"},
                            {"birthday" => 807303600},
                            {"avatar" => 1},
                            {"country" =>
                                {
                                    "selected" => [
                                        ['AB', 'Абхазия'],
                                        ['AU', 'Австралия'],
                                        ['AT', 'Австрия'],
                                        ['AZ', 'Азербайджан'],
                                        ['AL', 'Албания'],
                                        ['DZ', 'Алжир'],
                                        ['AO', 'Ангола'],
                                        ['AD', 'Андорра'],
                                        ['AG', 'Антигуа и Барбуда'],
                                        ['AR', 'Аргентина'],
                                        ['AM', 'Армения'],
                                        ['AF', 'Афганистан'],
                                        ['BS', 'Багамские Острова'],
                                        ['BD', 'Бангладеш'],
                                        ['BB', 'Барбадос'],
                                        ['BH', 'Бахрейн'],
                                        ['BZ', 'Белиз'],
                                        ['BY', 'Белоруссия'],
                                        ['BE', 'Бельгия'],
                                        ['BJ', 'Бенин'],
                                        ['BG', 'Болгария'],
                                        ['BO', 'Боливия'],
                                        ['BA', 'Босния и Герцеговина'],
                                        ['BW', 'Ботсвана'],
                                        ['BR', 'Бразилия'],
                                        ['BN', 'Бруней'],
                                        ['BF', 'Буркина-Фасо'],
                                        ['BI', 'Бурунди'],
                                        ['BT', 'Бутан'],
                                        ['VU', 'Вануату'],
                                        ['VA', 'Ватикан'],
                                        ['GB', 'Великобритания'],
                                        ['HU', 'Венгрия'],
                                        ['VE', 'Венесуэла'],
                                        ['TL', 'Восточный Тимор'],
                                        ['VN', 'Вьетнам'],
                                        ['GA', 'Габон'],
                                        ['HT', 'Гаити'],
                                        ['GY', 'Гайана'],
                                        ['GM', 'Гамбия'],
                                        ['GH', 'Гана'],
                                        ['GT', 'Гватемала'],
                                        ['GN', 'Гвинея'],
                                        ['GW', 'Гвинея-Бисау'],
                                        ['DE', 'Германия'],
                                        ['HN', 'Гондурас'],
                                        ['PS', 'Государство Палестина'],
                                        ['GD', 'Гренада'],
                                        ['GR', 'Греция'],
                                        ['GE', 'Грузия'],
                                        ['DK', 'Дания'],
                                        ['DJ', 'Джибути'],
                                        ['DM', 'Доминика'],
                                        ['DO', 'Доминиканская Республика'],
                                        ['CD', 'ДР Конго'],
                                        ['EG', 'Египет'],
                                        ['ZM', 'Замбия'],
                                        ['ZW', 'Зимбабве'],
                                        ['IL', 'Израиль'],
                                        ['IN', 'Индия'],
                                        ['ID', 'Индонезия'],
                                        ['JO', 'Иордания'],
                                        ['IQ', 'Ирак'],
                                        ['IR', 'Иран'],
                                        ['IE', 'Ирландия'],
                                        ['IS', 'Исландия'],
                                        ['ES', 'Испания'],
                                        ['IT', 'Италия'],
                                        ['YE', 'Йемен'],
                                        ['CV', 'Кабо-Верде'],
                                        ['KZ', 'Казахстан'],
                                        ['KH', 'Камбоджа'],
                                        ['CM', 'Камерун'],
                                        ['CA', 'Канада'],
                                        ['QA', 'Катар'],
                                        ['KE', 'Кения'],
                                        ['CY', 'Кипр'],
                                        ['KG', 'Киргизия'],
                                        ['KI', 'Кирибати'],
                                        ['CN', 'Китай'],
                                        ['KP', 'КНДР'],
                                        ['CO', 'Колумбия'],
                                        ['KM', 'Коморские Острова'],
                                        ['CR', 'Коста-Рика'],
                                        ['CI', 'Кот-д`Ивуар'],
                                        ['CU', 'Куба'],
                                        ['KW', 'Кувейт'],
                                        ['LA', 'Лаос'],
                                        ['LV', 'Латвия'],
                                        ['LS', 'Лесото'],
                                        ['LR', 'Либерия'],
                                        ['LB', 'Ливан'],
                                        ['LY', 'Ливия'],
                                        ['LT', 'Литва'],
                                        ['LI', 'Лихтенштейн'],
                                        ['LU', 'Люксембург'],
                                        ['MU', 'Маврикий'],
                                        ['MR', 'Мавритания'],
                                        ['MG', 'Мадагаскар'],
                                        ['MW', 'Малави'],
                                        ['MY', 'Малайзия'],
                                        ['ML', 'Мали'],
                                        ['MV', 'Мальдивские Острова'],
                                        ['MT', 'Мальта'],
                                        ['MA', 'Марокко'],
                                        ['MH', 'Маршалловы Острова'],
                                        ['MX', 'Мексика'],
                                        ['MZ', 'Мозамбик'],
                                        ['MD', 'Молдавия'],
                                        ['MC', 'Монако'],
                                        ['MN', 'Монголия'],
                                        ['MM', 'Мьянма'],
                                        ['NA', 'Намибия'],
                                        ['NR', 'Науру'],
                                        ['NP', 'Непал'],
                                        ['NE', 'Нигер'],
                                        ['NG', 'Нигерия'],
                                        ['NL', 'Нидерланды'],
                                        ['NI', 'Никарагуа'],
                                        ['NZ', 'Новая Зеландия'],
                                        ['NO', 'Норвегия'],
                                        ['AE', 'ОАЭ'],
                                        ['OM', 'Оман'],
                                        ['PK', 'Пакистан'],
                                        ['PW', 'Палау'],
                                        ['PA', 'Панама'],
                                        ['PG', 'Папуа - Новая Гвинея'],
                                        ['PY', 'Парагвай'],
                                        ['PE', 'Перу'],
                                        ['PL', 'Польша'],
                                        ['PT', 'Португалия'],
                                        ['CG', 'Республика Конго'],
                                        ['KR', 'Республика Корея'],
                                        ['RU', 'Россия'],
                                        ['RW', 'Руанда'],
                                        ['RO', 'Румыния'],
                                        ['SV', 'Сальвадор'],
                                        ['WS', 'Самоа'],
                                        ['SM', 'Сан-Марино'],
                                        ['ST', 'Сан-Томе и Принсипи'],
                                        ['SA', 'Саудовская Аравия'],
                                        ['MK', 'Северная Македония'],
                                        ['SC', 'Сейшельские Острова'],
                                        ['SN', 'Сенегал'],
                                        ['VC', 'Сент-Винсент и Гренадины'],
                                        ['KN', 'Сент-Китс и Невис'],
                                        ['LC', 'Сент-Люсия'],
                                        ['RS', 'Сербия'],
                                        ['SG', 'Сингапур'],
                                        ['SY', 'Сирия'],
                                        ['SK', 'Словакия'],
                                        ['SI', 'Словения'],
                                        ['SB', 'Соломоновы Острова'],
                                        ['SO', 'Сомали'],
                                        ['SD', 'Судан'],
                                        ['SR', 'Суринам'],
                                        ['US', 'США'],
                                        ['SL', 'Сьерра-Леоне'],
                                        ['TJ', 'Таджикистан'],
                                        ['TH', 'Таиланд'],
                                        ['TZ', 'Танзания'],
                                        ['TG', 'Того'],
                                        ['TO', 'Тонга'],
                                        ['TT', 'Тринидад и Тобаго'],
                                        ['TV', 'Тувалу'],
                                        ['TN', 'Тунис'],
                                        ['TM', 'Туркмения'],
                                        ['TR', 'Турция'],
                                        ['UG', 'Уганда'],
                                        ['UZ', 'Узбекистан'],
                                        ['UA', 'Украина'],
                                        ['UY', 'Уругвай'],
                                        ['FM', 'Федеративные Штаты Микронезии'],
                                        ['FJ', 'Фиджи'],
                                        ['PH', 'Филиппины'],
                                        ['FI', 'Финляндия'],
                                        ['FR', 'Франция'],
                                        ['HR', 'Хорватия'],
                                        ['CF', 'ЦАР'],
                                        ['TD', 'Чад'],
                                        ['ME', 'Черногория'],
                                        ['CZ', 'Чехия'],
                                        ['CL', 'Чили'],
                                        ['CH', 'Швейцария'],
                                        ['SE', 'Швеция'],
                                        ['LK', 'Шри-Ланка'],
                                        ['EC', 'Эквадор'],
                                        ['GQ', 'Экваториальная Гвинея'],
                                        ['ER', 'Эритрея'],
                                        ['SZ', 'Эсватини'],
                                        ['EE', 'Эстония'],
                                        ['ET', 'Эфиопия'],
                                        ['ZA', 'ЮАР'],
                                        ['OS', 'Южная Осетия'],
                                        ['SS', 'Южный Судан'],
                                        ['JM', 'Ямайка'],
                                        ['JP', 'Япония']
                                    ], 
                                    "value"    => "RU"
                                }
                            },
                            {"place" => "place"},
                            {"status" => "1"},
                            {"timezone" => 
                                {
                                    "selected" => [
                                        [-12  , 'UTC-12'],
                                        [-11  , 'UTC-11'],
                                        [-10  , 'UTC−10'],
                                        [-9.5 , 'UTC-9:30'],
                                        [-9   , 'UTC-9'],
                                        [-8   , 'UTC-8'],
                                        [-7   , 'UTC-7'],
                                        [-6   , 'UTC-6'],
                                        [-5   , 'UTC-5'],
                                        [-4   , 'UTC-4'],
                                        [-3.5 , 'UTC−3:30'],
                                        [-3   , 'UTC-3'],
                                        [-2   , 'UTC−2'],
                                        [-1   , 'UTC-1'],
                                        [0    , 'UTC+0'],
                                        [1    , 'UTC+1'],
                                        [2    , 'UTC+2'],
                                        [3    , 'UTC+3'],
                                        [3.5  , 'UTC+3:30'],
                                        [4    , 'UTC+4'],
                                        [4.5  , 'UTC+4:30'],
                                        [5    , 'UTC+5'],
                                        [5.5  , 'UTC+5:30'],
                                        [5.75 , 'UTC+5:45'],
                                        [6    , 'UTC+6'],
                                        [6.5  , 'UTC+6:30'],
                                        [7    , 'UTC+7'],
                                        [8    , 'UTC+8'],
                                        [8.75 , 'UTC+8:45'],
                                        [9    , 'UTC+9'],
                                        [9.5  , 'UTC+9:30'],
                                        [10   , 'UTC+10'],
                                        [10.5 , 'UTC+10:30'],
                                        [11   , 'UTC+11'],
                                        [12   , 'UTC+12'],
                                        [12.75, 'UTC+12:45'],
                                        [13   , 'UTC+13'],
                                        [14   , 'UTC+14']
                                    ], 
                                    "value"    => 3
                                }
                            },
                            {"type" => 'User'}
                        ],
                        "label" => "Основные"
                    },
                    {
                        "fields" => [
                           {"email" => "emailright\@email.ru"},
                           {"emailconfirmed" => 1},
                           {"phone" => '+7(921)2222222'},
                           {"phoneconfirmed" => 1}
                       ],
                        "label" => "Контакты"
                    },
                    {
                        "fields" => [
                            {"password"    => ''},
                            {"newpassword" => ''}
                       ],
                        "label" => "Пароль"
                    },
                    {
                        "fields" => [
                           {"groups" => "[1,2,3]" }
                       ],
                        "label" => "Группы"
                    }
               ]
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
            'message'   => "can't get object from users",
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
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/edit' => {token => $token} => form => $data );
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