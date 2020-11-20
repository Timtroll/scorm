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
use File::Slurp::Unicode qw(slurp write_file);
use Freee::EAV;
use Digest::SHA qw( sha256_hex );
use Install;
use DBI qw(:sql_types);
use Data::Dumper;
use DDP;
use Freee::Mock::Install;

my ( $path_sql, $path_conf, $path_log, $self, $check_scorm, $config_update, @bd_array );
$config_update = 1;
# чтение параметров
my %hash;
foreach my $parameter ( @ARGV ) {
    $parameter = substr( $parameter, 2 );
    my @array = split(/=/, $parameter);
    $hash{$array[0]} = $array[1];
}
unless (keys %hash) {
    helpme('help');
    exit;
}

foreach( 'path', 'rebuild' ) {
    unless ( exists $hash{$_} ) {
        logging( "required parameter $_ doesn't exist" );
        exit;
    }
}

# проверка параметров test
if ( $hash{'mode'} &&  $hash{'mode'} ne 'test' || $hash{'start'} &&  $hash{'start'} ne 'test' ) {
    logging( "wrong format '$hash{'mode'}' of 'test' parameter" ); 
    exit;    
}

# поиск и чтение шаблона конфигурации
if ( -s $hash{'path'} ) {
    my $filename = $hash{'path'};
    $config_update = slurp( $filename, encoding => 'utf8' );
    $config_update = eval( $config_update );
}
else {
    logging( 'file doesnt exist');
    helpme('need_config');
    exit;
}

# проверка параметра создания бд
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

    # проверка существования базы scorm
    $check_scorm = check_db( $self, 'scorm' );

    # создаём базы
    if ( $hash{'mode'} ) {
        # проверка отсутствия базы scorm_test
        if ( check_db( $self, 'scorm_test' ) ) {
            delete_db_test( $self );
        }

        if ( $check_scorm ) {
            # массив только scorm_test
            @bd_array = ( 'scorm_test' );
        }
        else {
            # массив из test, scorm
            if ( $hash{'start'} ) {
                @bd_array = ( 'scorm', 'scorm_test' );
            }
            else {
                @bd_array = ( 'scorm_test', 'scorm' );
            }
        }
    }
    else{
        unless( $check_scorm ) {
            # массив только scorm
            @bd_array = ( 'scorm' );
        }
    }

    # для каждого эл-та массива
    foreach( @bd_array ) {
        # остановка mojo
        mojo_do( 'stop' );

        # если это тестовая база
        if ( $_ eq 'scorm_test' ) {
            # заполнение параметров конфига для тестовой базы ---
            create_db( $self, '/_create_test_db.sql' );

            connect_db( $self, $config_update, 'pg_main_test' );
        }
        else {
            # заполнение параметров конфига для основной базы ---
            create_db( $self, '/_create_db.sql' );

            connect_db( $self, $config_update, 'pg_main' );
        }

        # запись конфигурации в файл freee.conf
        write_config();

        # запуск скриптов, создающих таблицы
        create_tables( $self );

        # старт mojo
        mojo_do( 'start' );

        # загрузка дефолтных значений
        load_defaults( $self, $config_update );

    }
}
else {
    # остановка mojo
    mojo_do( $path_conf, 'stop' );

    # заполнение параметров конфига
    # $$config{ 'test' } = $$temp_freee::config_update{ 'test' } if $$temp_freee::config_update{ 'test' };
    $$config{ 'test' } = $$config_update{ 'test' } if $$config_update{ 'test' };
    my $main = $hash{'mode'} ? 'pg_main_test' : 'pg_main';
    update_config( $config_update, $main );

    # запись конфигурации в файл freee.conf
    write_config();

    # старт mojo
    mojo_do( 'start' );

}

# конец программы
warn 'All setting required';
exit;

####################################################################