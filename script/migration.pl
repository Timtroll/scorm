#!/usr/bin/perl -w

# должен вызываться только из корневой директории для не существующей базы данных
# миграция: чтение и запуск sql файлов из scorm/sql
# для миграции тестовой базы данных добавить при вызове параметр test
# ./script/migration.pl      - создание базы данных scorm при её отсутствии
# ./script/migration.pl test - создание базы данных scorm_test при её отсутствии

use utf8;
use strict;
use warnings;
use File::Slurp::Unicode qw(slurp);
use DBI;

my ( $path_sql, $path_conf, $path_log, $config, $test, $db, $dbh, $res, $sth, $database, $filename, $create_db, $sql, $host, $url, @list );

# проверка тестового режима
if ( @ARGV ) {
    $test = shift @ARGV;
}

# путь к директории со скриптами миграции
$path_sql = './sql';

# путь к директории с конифгурацией
$path_conf = './freee.conf';

# путь к директории с логированием
unless ( $test ) {
    $path_log = './log/migration.log';
}
else {
    $path_log = './log/migration_test.log';
}

# остановка демона
`./starting.sh stop`;

# поиск и чтение конфигурации 
if ( -e $path_conf ) {
    $config = slurp( $path_conf, encoding => 'utf8' );
    unless ( $config ) {
        logging( "can't read config file from $path_conf" ); 
        exit; 
    }
}

# преобразование текста файла конфигурации в объект
$config = eval( $config );
unless ( $config->{'dbs'}->{'databases'}->{'pg_main'} ){
    logging( "wrong format of config" );
    exit;
}

unless ( $test ) {
    $db = $config->{'dbs'}->{'databases'}->{'pg_main'};
} 
else {
    $db = $config->{'dbs'}->{'databases'}->{'pg_main_test'};
}

# редактирование параметра обработки ошибок
if (
    $db &&
    $db->{'options'} &&
    $db->{'options'}->{'RaiseError'} 
) {
    $db->{'options'}->{'RaiseError'} = 0;
}

# подключение к базе данных
$dbh = DBI->connect(
    'dbi:Pg:dbname=postgres;host=localhost;port=5432',
    $db->{'username'},
    $db->{'password'},
    $db->{'options'}
);
if ( DBI->errstr ) {
    logging( "connection to database doesn't work:" . DBI->errstr );
    exit;    
}

# проверка существования бд
$database = $test ? 'scorm_test' : 'scorm';
if ( check_db( $database ) ) {
    warn 'database ' . $database . ' already exists';
    logging( 'database ' . $database . ' already exists' );
    exit;    
}

# создание базы
$create_db = $test ? '/_create_test_db.sql' : '/_create_db.sql';
$filename = $path_sql . $create_db;
$sql = slurp( $filename, encoding => 'utf8' );
$sth = $dbh->prepare( $sql );
$res = $sth->execute();
if ( DBI->errstr ) {
    warn "execute doesn't work " . DBI->errstr . " in $filename script";
    logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
    exit;
}
warn 'Db created';

# подключение к базе данных
$dbh = DBI->connect(
    $db->{'dsn'},
    $db->{'username'},
    $db->{'password'},
    $db->{'options'}
);
if ( DBI->errstr ) {
    logging( "connection to database doesn't work:" . DBI->errstr );
    exit;
}

# создание расширения
$filename = $path_sql . '/_create_extiention.sql';
$sql = slurp( $filename, encoding => 'utf8' );
$sth = $dbh->prepare( $sql );
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
    $sth = $dbh->prepare( $sql );
    $res = $sth->execute();
    if ( DBI->errstr ) {
        warn "execute doesn't work " . DBI->errstr . " in $filename script";
        logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
        exit;    
    }
}

# старт демона
`./starting.sh start`;

# загрузка дефолтных настроек
$host = $config->{'host'};
$url = $host . '/settings/load_default';
# --spider - не загружать файл с ответом
`wget --wait=2 --tries=10 --retry-connrefused --spider $url`;

exit;


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
    $sth = $dbh->prepare( $check_db );
    $sth->bind_param( 1, $database );
    $res = $sth->execute();
    $res = 0 if $res == '0E0';

    return $res;
}