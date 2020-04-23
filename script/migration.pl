#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp qw(slurp);
use DBI;

# миграция: чтение и запуск sql файлов из scorm/sql

my $filename = '../freee.conf';
my $dir = '../sql';

# чтение конфигурации
my $config = slurp( $filename, { err_mode => 'carp' } ) or do { 
    logging( "can't read file $filename: $!" ); 
    exit; 
};

# преобразование текста файла конфигурации в объект
$config = eval( $config );
my $db = $config->{'dbs'}->{'databases'}->{'pg_main'};

# редактирование параметра обработки ошибок
if (
    $db &&
    $db->{'options'} &&
    $db->{'options'}->{'RaiseError'} 
) {
    $db->{'options'}->{'RaiseError'} = 0;
}

# подключение к базе данных
my $dbh = DBI->connect(
    $db->{'dsn'},
    $db->{'username'},
    $db->{'password'},
    $db->{'options'}
);
if ( DBI->errstr ) {
    logging( "connection doesn't work " . DBI->errstr . " in $filename script\n" );
    exit;    
}

# чтение файлов директории скриптов
my @list = `ls $dir 2>&1`;
if ( $? ){
    logging( "can't read directory $dir: @list" ); 
    exit; 
};

# обработка файлов директории  
foreach ( @list ){
    my $filename = $dir . '/' . $_;
    chomp ( $filename );

    # фильтрация не sql файлов и папок
    next if ( -d $filename || $_ !~ /\.sql$/);

    # чтение содержимого файлов
    my $sql = slurp( $filename ) or do { 
        logging( "can't read file $filename: $!" ); 
        exit; 
    };

    # выполение скриптов
    my $sth = $dbh->prepare( $sql );
    my $res = $sth->execute();
    if ( DBI->errstr ) {
        logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
        exit;    
    }
}

# логирование ошибки
# logging( "комментарий и текст ошибки" );
sub logging {
    my $logdata = shift;
    my $logname = '../log/migration.log';

    open(my $log, '>>', $logname) or warn "Can't open log file!";
    print $log "$logdata\n";
    close $logname;
}