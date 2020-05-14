#!/usr/bin/perl -w

# миграция: чтение и запуск sql файлов из scorm/sql
use utf8;
use strict;
use warnings;
use File::Slurp::Unicode qw(slurp);;
use DBI;

my ( $path, $config, $test, $db, $dbh, $pwd, @path, @log_path, @list );

# проверка тестового режима
if ( @ARGV ) {
    $test = shift @ARGV;
}

unless ( $test ) {
    @path = ( './freee.conf', '../freee.conf' );
    @log_path = ( './log/migration.log', '../log/migration.log' );
}
else {
    @path = ( './freee.conf' );
    @log_path = ( './log/migration_test.log' );
}

# поиск и чтение конфигурации 
foreach $path ( @path ) {
    if ( -e $path ) {
        $config = slurp( $path, encoding => 'utf8' );
        unless ( $config ) {
            logging( "can't read config file from $path" ); 
            exit; 
        }
        last;
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
    $db->{'dsn'},
    $db->{'username'},
    $db->{'password'},
    $db->{'options'}
);
if ( DBI->errstr ) {
    logging( "connection to database doesn't work:" . DBI->errstr );
    exit;    
}

# проверка директории запуска файла
$pwd = `pwd`;
chomp $pwd;

if ( $config->{'root'} eq $pwd ) {
    unless ( $test ){
        $path = './sql';
    }
    else {
        $path = './t/Migration';
    }
} 
else {
    $path = '../sql';
}

# чтение файлов директории скриптов
@list = `ls $path 2>&1`;
if ( $? ) {
    logging( "can't read directory $path: @list" ); 
    exit; 
};
# обработка файлов директории  
foreach ( @list ) {
    my ( $filename, $sql, $sth, $res );
    $filename = $path . '/' . $_;
    chomp ( $filename );

    # фильтрация не sql файлов и папок
    next if ( -d $filename || $_ !~ /\.sql$/);

    # чтение содержимого файлов
    # $sql = slurp( $filename, { err_mode => 'carp' } );
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

# логирование ошибки
# logging( "комментарий и текст ошибки" );
sub logging {
    my $logdata = shift;
    my $log;

    foreach my $path ( @log_path ) {

        if ( -e $path ) {
            open( $log, '>>', $path ) or warn "Can't open log file!";
                print $log "$logdata\n";
            close( $log );
        }
    }

}