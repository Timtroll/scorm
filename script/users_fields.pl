#!/usr/bin/perl -w

# миграция: чтение и запуск sql файлов из scorm/sql
use strict;
use warnings;
use File::Slurp qw(slurp);
use DBI;

my ($config, $db, $dbh, $sth, $sql);

if ( -e '../freee.conf' ) {
    $config = slurp( '../freee.conf', { err_mode => 'carp' } );
    unless ( $config ) {
        logging( "can't read config file from ../freee.conf" ); 
        exit; 
    }
}

$config = eval( $config );
$db = $config->{'dbs'}->{'databases'}->{'pg_main'};

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

my %fields = (
    'users_id'          => [ "int4", "Id users пользователя" ],
    'surname'           => [ "string", "Фамилия" ],
    'name'              => [ "string", "Имя" ],
    'patronymic'        => [ "string", "Отчество" ],
    'city'              => [ "string", "город" ],
    'country'           => [ "string", "страна" ],
    'birthday'          => [ "datetime", "дата рождения" ],
    'emailconfirmed'    => [ "string", "email подтвержден" ],
    'phone'             => [ "string", "номер телефона" ],
    'phoneconfirmed'    => [ "boolean", "телефон подтвержден" ],
    'status'            => [ "boolean", "активный/неактивный" ],
    'groups'            => [ "string", "список ID групп" ],
    'avatar'            => [ "string", "фото" ]
);

foreach (keys %fields) {
    $sql = "DO \$\$
BEGIN
    PERFORM eav_createfield( 'user', '$_', '$fields{$_}[1]', '$fields{$_}[0]', NULL );
END;
\$\$;";
print "$sql\n";
    # $sth = $dbh->do( $sql );
    # $sth = $dbh->prepare( $sql );
    # $res = $sth->execute();
}

