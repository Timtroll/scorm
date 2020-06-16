#!/usr/bin/perl -w

# миграция: чтение и запуск sql файлов из scorm/sql
use utf8;
use strict;
use warnings;
use lib '../lib';
use File::Slurp::Unicode qw(slurp);;
use Freee::EAV;
use Freee::EAV::User;
use DBI;

use Data::Dumper;

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
#my $null = Freee::EAV->new( 'Base', { 'dbh' => $self->{dbh} } );

my $UH = Freee::EAV->new( 'User', { dbh => $self->{dbh} } );
use DDP;
p $UH->{Root};
p $UH->{Root}->id();
die;


# делаем запись
my $user = Freee::EAV->new( 'User',
    {
        'publish' => \1,
        'parent' => 1, 
        'title' => 'admin',
        'User' => {
            'place'         => "адрес",
            'country'       => "страна",
            'birthday'      => "202-04-04 20:00:00",
            'patronymic'    => "Отчество 3",
            'name'          => "Имя 2",
            'surname'       => "Фамилия 112",

            # 'publish'     => $$data{'status'} ? \1 : \0, 
            # 'parent'      => 1,
            # 'email'       => $$data{'email'},
            # 'password'    => $$data{'password'},
            # 'time_create' => $$data{'time_create'},
            # 'time_access' => $$data{'time_access'},
            # 'time_update' => $$data{'time_update'},
            # 'timezone'    => $$data{'timezone'}
        }
    }
);

# # читаем запись
# $user = Freee::EAV->new( 'User', { 'id' => 2 } );
# # warn Dumper $user;
# warn Dumper $user->GetUser(2);


# my $id = $user->id();


# warn $user->users_id( 3 );

# читаем запись
# $user = Freee::EAV->new( 'User', { id => 1 } );
# warn $user->id();

