#!/usr/bin/perl -w

# должен вызываться только из корневой директории для не существующей базы данных
# миграция: чтение и запуск sql файлов из scorm/sql
# для миграции обязателен параметр с адресом конфигурации, которая находится вне git
# для миграции тестовой базы данных добавить при вызове параметр test
# ./script/install.pl  
# опции:
# --path='./temp_freee.conf'
# --mode=test - создание базы данных scorm_test при её отсутствии
# --rebuild=1/0 - создание базы и конфигурации или только конфигурации
# --start=test - по окончании работы скрипта, старт mojo с тестовой базой

use utf8;
use strict;
use warnings;
use lib './lib';
use File::Slurp;
use File::Slurp::Unicode qw(slurp);
use Freee::EAV;
use Digest::SHA qw( sha256_hex );
use DBI qw(:sql_types);
use Data::Dumper;
use DDP;
use Freee::Mock::Install;

my ( $path_sql, $path_conf, $path_log, $text, $rebuild, $config_update, $db, $self, $res, $sth, $database, $filename, $create_db, $sql, $host, $url, $result, @bd_array, @list );

# чтение параметров
my %hash;
foreach my $parameter ( @ARGV ) {
    $parameter = substr( $parameter, 2 );
    my @array = split(/=/, $parameter);
    $hash{$array[0]} = $array[1];
}

# путь к директории с логированием
$path_log = './log/migration.log';

foreach( 'path', 'rebuild' ) {
    unless ( exists $hash{$_} ) {
        logging( "required parameter $_ doesn't exist" );
        exit;
    }
}

# путь к директории со скриптами миграции
$path_sql = './sql';

# путь к директории с конифгурацией
$path_conf = './freee.conf';

# проверка параметров test
if ( $hash{'mode'} &&  $hash{'mode'} ne 'test' || $hash{'start'} &&  $hash{'start'} ne 'test' ) {
    logging( "wrong format '$hash{'mode'}' of 'test' parameter" ); 
    exit;    
}

# поиск и чтение шаблона конфигурации
if ( -s $hash{'path'} ) {
    $text = slurp( $hash{'path'}, encoding => 'utf8' );
    unless ( $text ) {
        logging( "can't read config file from '$hash{'path'}'" ); 
        exit; 
    }
}
else {
    logging( 'file doesnt exist');
    exit;
}

$config_update = eval( $text );

# проверка параметра rebuild
if ( $hash{'rebuild'} ) {
    # подключение к базе postgres
    $self->{dbh} = DBI->connect(
        'dbi:Pg:dbname=postgres;host=localhost;port=5432',
        'troll',
        'Yfenbkec_1',
        { 
            'pg_enable_utf8' => 1, 
            'pg_auto_escape' => 1, 
            'AutoCommit' => 1, 
            'PrintError' => 1, 
            'RaiseError' => 1, 
            'pg_server_prepare' => 0 
        }
    );
    if ( DBI->errstr ) {
        logging( "connection to database doesn't work:" . DBI->errstr );
        exit;    
    }

    # проверка отсутствия базы scorm
    if ( check_db( 'scorm' ) ) {
        logging( 'database scorm already exists' );
        exit; 
    }

    # создаём две базы или одну
    if ( $hash{'mode'} ) {

        # проверка отсутствия базы scorm_test
        if ( check_db( 'scorm_test' ) ) {
            logging( 'database scorm_test already exists' );
            exit; 
        }

        # массив из test, scorm
        if ( $hash{'start'} ) {
            @bd_array = ( 'scorm', 'scorm_test' );
        }
        else {
            @bd_array = ( 'scorm_test', 'scorm' );
        }
    }
    else{
        # массив только scorm
        @bd_array = ( 'scorm' );
    }

    # для каждого эл-та массива
    foreach( @bd_array ) {

        # остановка mojo
        mojo_do( 'stop ');

        # если это тестовая база
        if ( $_ eq 'scorm_test' ) {
            # заполнение параметров конфига для тестовой базы ---
            create_db( '/_create_test_db.sql' );
            connect_db( 'pg_main_test' );
        }
        else {
            # заполнение параметров конфига для основной базы ---
            create_db( '/_create_db.sql' );
            connect_db( 'pg_main' );
        }

        # запись конфигурации в файл freee.conf
        write_config();

        # запуск скриптов
        create_tables();

        # старт mojo
        mojo_do( 'start ');

        # загрузка дефолтных значений
        load_defaults();
    }
}
else {
    # заполнение параметров конфига для основной базы scorm
    $$config{ 'expires' }                                           = $$config_update{ 'expires' }               if $$config_update{ 'expires' };
    $$config{ 'debug' }                                             = $$config_update{ 'debug' }                 if $$config_update{ 'debug' };
    $$config{ 'test' }                                              = $$config_update{ 'test' }                  if $$config_update{ 'test' };
    $$config{ 'export_settings_path' }                              = $$config_update{ 'export_settings_path' }  if $$config_update{ 'export_settings_path' };
    $config->{'dbs'}->{'databases'}->{'pg_main'}->{'username'}      = $$config_update{ 'pg_main_username' }      if $$config_update{ 'pg_main_username' }; 
    $config->{'dbs'}->{'databases'}->{'pg_main'}->{'password'}      = $$config_update{ 'pg_main_password' }      if $$config_update{ 'pg_main_password' };
    $config->{'dbs'}->{'databases'}->{'pg_main'}->{'options'}       = $$config_update{ 'pg_main_options' }       if $$config_update{ 'pg_main_options' };

    # если тест
    if ( $hash{'mode'} ) {
        $config->{'dbs'}->{'databases'}->{'pg_main_test'}->{'username'} = $$config_update{ 'pg_main_test_username' } if $$config_update{ 'pg_main_test_username' };
        $config->{'dbs'}->{'databases'}->{'pg_main_test'}->{'password'} = $$config_update{ 'pg_main_test_password' } if $$config_update{ 'pg_main_test_password' };
        $config->{'dbs'}->{'databases'}->{'pg_main_test'}->{'options'}  = $$config_update{ 'pg_main_test_options' }  if $$config_update{ 'pg_main_test_options' };
    }

    # запись конфигурации в файл freee.conf
    write_config();
}


####################################################################


# логирование ошибки
# logging( "комментарий и текст ошибки" );
sub logging {
    my $logdata = shift;
    my $log;

    if ( -e $path_log ) {
        open( $log, '>>', $path_log ) or warn "Can't open log file!";
            print $log "$logdata\n";
        close( $log );
    }
}

# проверка существования базы данных
# my true = check_db( database );
sub check_db {
    my $database = shift;

    my $check_db = 'SELECT datname FROM pg_database WHERE datname = ?';
    $sth = $self->{dbh}->prepare( $check_db );
    $sth->bind_param( 1, $database );
    $res = $sth->execute();
    $res = 0 if $res == '0E0';

    return $res;
}

# запуск или остановка mojo
# my true = mojo_do( do );
sub mojo_do {
    my $do = shift;

    $res = `./starting.sh $do`;
    return $res;
}

# my true = create_db(  );
# создание базы данных
sub create_db {
    $create_db = shift;

    $filename = $path_sql . $create_db;
    $sql = slurp( $filename, encoding => 'utf8' );
    $sth = $self->{dbh}->prepare( $sql );
    $res = $sth->execute();
    if ( DBI->errstr ) {
        warn "execute doesn't work " . DBI->errstr . " in $filename script";
        logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
        exit;
    }
    warn 'Db created';
}

# заполнение параметров и создание конфига 
# my true = connect_db( main );
sub connect_db {
    my $main = shift;

    # обновление конфигурации
    $$config{ 'test' }                                          = $main eq 'pg_main_test' ? 1 : 0;

    $$config{ 'expires' }                                       = $$config_update{ 'expires' }               if $$config_update{ 'expires' };
    $$config{ 'debug' }                                         = $$config_update{ 'debug' }                 if $$config_update{ 'debug' };
    $$config{ 'export_settings_path' }                          = $$config_update{ 'export_settings_path' }  if $$config_update{ 'export_settings_path' };

    $config->{'dbs'}->{'databases'}->{$main}->{'username'}      = $$config_update{ $main . '_username' }     if $$config_update{ $main . '_username' }; 
    $config->{'dbs'}->{'databases'}->{$main}->{'password'}      = $$config_update{ $main . '_password' }     if $$config_update{ $main . '_password' };
    $config->{'dbs'}->{'databases'}->{$main}->{'options'}       = $$config_update{ $main . '_options' }      if $$config_update{ $main . '_options' };

    $db = $config->{'dbs'}->{'databases'}->{$main};

    # редактирование параметра обработки ошибок
    if (
        $db &&
        $db->{'options'} &&
        $db->{'options'}->{'RaiseError'} 
    ) {
        $db->{'options'}->{'RaiseError'} = 1;
    }

    $self->{dbh} = DBI->connect(
        $db->{'dsn'},
        $db->{'username'},
        $db->{'password'},
        $db->{'options'}
    );
    if ( DBI->errstr ) {
        logging( "connection to database doesn't work:" . DBI->errstr );
        exit;
    }
}

sub create_tables {
    # создание расширения
    $filename = $path_sql . '/_create_extiention.sql';
    $sql = slurp( $filename, encoding => 'utf8' );
    $sth = $self->{dbh}->prepare( $sql );
    $res = $sth->execute();
    if ( DBI->errstr ) {
        warn "execute doesn't work " . DBI->errstr . " in $filename script";
        logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
        exit;
    }

    # чтение файлов директории скриптов
    @list = `ls $path_sql 2>&1`;
    if ( $? ) {
        logging( "can't read directory $path_sql: @list" ); 
        exit;
    };
    # обработка файлов директории  
    foreach ( @list ) {
        chomp;
        # фильтрация не sql файлов и папок
        next if ( -d $path_sql . '/' . $_ || /^\_/ || ! /\.sql$/ );

        $filename = $path_sql . '/' . $_;

        # чтение содержимого файлов
        $sql = slurp( $filename, encoding => 'utf8' );
        unless ( $sql ) { 
            logging( "can't read file $filename" ); 
            exit; 
        };

        # выполение скриптов
        $sth = $self->{dbh}->prepare( $sql );
        $res = $sth->execute();
        if ( DBI->errstr ) {
            warn "execute doesn't work " . DBI->errstr . " in $filename script";
            logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
            exit;    
        }
    }
}

# загрузка дефолтных значений
sub load_defaults {
    # загрузка дефолтных настроек
    $host = $config->{'host'};
    $url = $host . '/settings/load_default';
    # --spider - не загружать файл с ответом
    `wget --wait=3 --tries=3 --retry-connrefused --spider $url`;

    # получаем id группы unaproved
    $sql = 'SELECT * FROM "public"."groups" WHERE "name" = \'admin\'';
    $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();

    # my $groups = $sth->fetchrow_hashref();
    # unless ( (ref($groups) eq 'HASH') && $$groups{id} ) {
    #     push @!, 'Could not get Groups';
    #     $self->{dbh}->rollback;
    #     return;
    # }

    # добавляем пользователя
    my $fu = Freee::EAV->new( 'User', { dbh => $self->{dbh} } );
    my $user =    {
        'publish' => \1,
        'parent' => 1, 
        'title' => 'admin',
        'User' => {
            'place'         => "scorm",
            'country'       => "RU",
            'birthday'      => "19950803 00:00:00",
            'patronymic'    => "admin",
            'name'          => "admin",
            'surname'       => "admin",
        }
    };
    my $eav = Freee::EAV->new( 'User', $user );
    my $eav_id = $eav->id(); 

    # получение соли из конфига
    my $salt = $config->{'secrets'}->[0];
    $user = {
        'publish'     => 't', 
        'email'       => 'admin@admin',
        'login'       => $config_update->{'login'},
        'password'    => sha256_hex( $config_update->{'password'}, $salt ),
        'timezone'    => 3,
        'eav_id'      => $eav_id
    };

    $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} keys %$user ).') VALUES ( '.join( ',', map { ':'.$_ } keys %$user ).' )';
    $sth = $self->{'dbh'}->prepare( $sql );
    foreach ( keys %$user ) {
        my $type = /publish/ ? SQL_BOOLEAN : undef();
        $sth->bind_param( ':'.$_, $$user{$_}, $type );
    }
    $result = $sth->execute();

    # ввод в user_groups
    $sql = 'INSERT INTO "public"."user_groups" ( user_id, group_id ) VALUES ( 1,1 )';
    $sth = $self->{'dbh'}->prepare( $sql );
    $result = $sth->execute();
}

# запись конфигурации в файл freee.conf
sub write_config {
    # настройка dumper, чтобы не было лишнего 'var='
    $Data::Dumper::Terse = 1;

    # запись конфигурации в файл
    my $result = write_file(
        $path_conf,
        Dumper( $config )
    );
}
