#!/usr/bin/perl -w

# миграция: чтение и запуск sql файлов из scorm/sql
use utf8;
use strict;
use warnings;
use lib '../lib';
use File::Slurp::Unicode qw(slurp);;
use Freee::EAV;
use DBI;

my ($config, $db, $self);

if ( -e '../freee.conf' ) {
    $config = slurp( '../freee.conf', encoding => 'utf8' );
    unless ( $config ) {
        logging( "can't read config file from ../freee.conf" ); 
        exit; 
    }
}

$config = eval( $config );
$db = $config->{'dbs'}->{'databases'}->{'pg_main'};

# подключение к базе данных
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

# my %fields = (
#     'users_id'          => [ "int4", "Id users пользователя" ],
#     'surname'           => [ "string", "Фамилия" ],
#     'name'              => [ "string", "Имя" ],
#     'patronymic'        => [ "string", "Отчество" ],
#     'city'              => [ "string", "город" ],
#     'country'           => [ "string", "страна" ],
#     'birthday'          => [ "datetime", "дата рождения" ],
#     'emailconfirmed'    => [ "string", "email подтвержден" ],
#     'phone'             => [ "string", "номер телефона" ],
#     'phoneconfirmed'    => [ "boolean", "телефон подтвержден" ],
#     'status'            => [ "boolean", "активный/неактивный" ],
#     'groups'            => [ "string", "список ID групп" ],
#     'avatar'            => [ "string", "фото" ]
# );

# Модель EAV
my $null = Freee::EAV->new( 'Base', { 'dbh' => $self->{dbh} } );

# делаем запись
my $user = Freee::EAV->new( 'User', {
    'publish'   => \1,
    'parent'    => 1
} );
$user->StoreOblect({
    'title' => 'admin',
    'User' => {
        'Surname'       => "Фамилия 111",
        'Name'          => "Имя",
        'Patronymic'    => "Отчество",
        'City'          => "город",
        'Country'       => "страна",
        'Birthday'      => "202-04-04 20:00:00",
        'Phone'         => "номер телефона"
    }
});

# 'User', {
#     'Title'         => 'тестовый юзер test',
#     'UsersId'      => 1,
# import_source => 'local',
# import_id => 1

#     'Surname'       => "Фамилия",
#     'Name'          => "Имя",
#     'Patronymic'    => "Отчество",
#     'City'          => "город",
#     'Country'       => "страна",
#     'Birthday'      => "дата рождения",
#     'EmailConfirmed'=> "email подтвержден",
#     'Phone'         => "номер телефона",
#     'PhoneConfirmed'=> "телефон подтвержден",
# #        'Groups'        => "список ID групп",
#     'Avatar'        => "фото",
#     'Status'        => "активный/неактивный",
#     ''
# });

my $id = $user->id();
# warn $user->users_id( 3 );

# читаем запись
# $user = Freee::EAV->new( 'User', { id => 1 } );
# warn $user->id();

