#!/usr/bin/perl -w

# миграция: чтение и запуск sql файлов из scorm/sql
use strict;
use warnings;
use File::Slurp qw(slurp);
use DBI;

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use FindBin;

my ( $filename, $config, $db, $dbh, $check_db, $sth, $res, $db_test, $dbh_test, $result, $check, $create, $delete, $cmd, $config_str, $sql );

$filename = './freee.conf';

# чтение конфигурации
$config = slurp( $filename, { err_mode => 'carp' } ) or die( "can't read file $filename: $!" );

# преобразование текста файла конфигурации в объект
$config = eval( $config );

$db = $config->{'dbs'}->{'databases'}->{'pg_main'};

# редактирование параметра обработки ошибок
if (
    $db &&
    $db->{'options'} &&
    $db->{'options'}->{'RaiseError'} 
) {
    $db->{'options'}->{'RaiseError'} = 0;
}

# подключение к основной базе данных
$dbh = DBI->connect(
    $db->{'dsn'},
    $db->{'username'},
    $db->{'password'},
    $db->{'options'}
);
die( "connection to the main base doesn't work:" . DBI->errstr ) if ( DBI->errstr );

# проверка отсутствия тестовой бд
$check_db = "SELECT FROM pg_database WHERE datname = 'scorm_test'";
$sth = $dbh->prepare( $check_db );
$res = $sth->execute();
$res = 0 unless $res == '0E0';

# создание тестовой бд
if ( $res ) {
    $create = 'CREATE DATABASE "scorm_test"';
    $sth = $dbh->prepare( $create );
    $res = $sth->execute();
    die( "creation doesn't work " . DBI->errstr ) if ( DBI->errstr );
    diag"database was created";
}

# подключение к тестовой бд
$db_test = $config->{'dbs'}->{'databases'}->{'pg_main_test'};

$dbh_test = DBI->connect(
    $db_test->{'dsn'},
    $db_test->{'username'},
    $db_test->{'password'},
    $db_test->{'options'}
);
die( "connection to the test base doesn't work:" . DBI->errstr ) if ( DBI->errstr );


### положительный тест
# создание правильного sql скрипта
$cmd = `cp ./t/Migration/right_test.sql ./t/Migration/test.sql`;
if ( $? ) {
    diag( "can't create sql file" ); 
    exit; 
};

# создание log файла
$cmd = `> ./log/migration_test.log`;
if ( $? ) {
    diag( "can't create log file" ); 
    exit; 
};

# запуск скрипта из корневого каталога
$result = `./script/migration.pl test`;

# проверка результата
$sth = $dbh_test->prepare( 'SELECT table_name FROM information_schema.columns WHERE table_schema = ?' );
$sth->bind_param( 1, $config->{'table_schema'} );
$res = $sth->execute();
$res = 0 if $res == '0E0';
ok( $res, "all right" );

# удаление созданных файлов
$cmd = `rm ./t/Migration/test.sql`;
$cmd = `rm ./log/migration_test.log`;

### синтаксическая ошибка в sql файле
# создание правильного sql скрипта
$cmd = `cp ./t/Migration/right_test.sql ./t/Migration/test.sql`;
if ( $? ) {
    diag( "can't create sql file" ); 
    exit; 
};
# добавление ошибки в sql файл
$cmd = `echo "this file has an error" >> ./t/Migration/test.sql`;

# создание log файла
$cmd = `> ./log/migration_test.log`;
if ( $? ) {
    diag( "can't create log file" ); 
    exit; 
};

# запуск скрипта из корневого каталога
$result = `./script/migration.pl test`;

# проверка результата
$filename = './log/migration_test.log';
$res = slurp( $filename, { err_mode => 'carp' } ) or die( "can't read file $filename: $!" );
$res = $res =~ qq(execute doesn't work ERROR:  syntax error at or near "this");
ok( $res, "sql file syntactic error" );

# удаление созданных файлов
$cmd = `rm ./t/Migration/test.sql`;
$cmd = `rm ./log/migration_test.log`;

### логическая ошибка в sql файле
# создание правильного sql скрипта
$cmd = `cp ./t/Migration/right_test.sql ./t/Migration/test.sql`;
if ( $? ) {
    diag( "can't create sql file" ); 
    exit; 
};
# добавление ошибки в sql файл
$cmd = `echo 'CREATE TABLE "groups"();' >> ./t/Migration/test.sql`;

# создание log файла
$cmd = `> ./log/migration_test.log`;
if ( $? ) {
    diag( "can't create log file" ); 
    exit; 
};

# запуск скрипта из корневого каталога
$result = `./script/migration.pl test`;

# проверка результата
$filename = './log/migration_test.log';
$res = slurp( $filename, { err_mode => 'carp' } ) or die( "can't read file $filename: $!" );
$res = $res =~ qq(execute doesn't work ERROR:  relation "groups" already exists);
ok( $res, "sql file logic error" );

# удаление созданных файлов
$cmd = `rm ./t/Migration/test.sql`;
$cmd = `rm ./log/migration_test.log`;


# отключение от тестовой бд
$res = $sth->finish;
$res = $dbh_test->disconnect  or warn "can't disconnect: $dbh->errstr";

# проверка существования тестовой бд
$sth = $dbh->prepare( $check_db );
$res = $sth->execute();
$res = 0 if $res == '0E0';

# удаление тестовой бд
if ( $res ) {
    $delete = 'DROP DATABASE "scorm_test"';
    $sth = $dbh->prepare( $delete );
    $res = $sth->execute();
    die( "delete doesn't work " . DBI->errstr ) if ( DBI->errstr );
    diag"database was deleted";
}

done_testing();