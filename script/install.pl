#!/usr/bin/perl -CS

# должен вызываться только из корневой директории для не существующей базы данных
# миграция: чтение и запуск sql файлов из scorm/sql
# для миграции обязателен параметр с адресом конфигурации, которая находится вне git
# для миграции тестовой базы данных добавить при вызове параметр test
# ./script/install.pl
# обязательные опции:
# --path=../temp_freee.conf
# --rebuild=1/0 - создание базы и конфигурации (1) или только конфигурации (0)
# --mode=all   - создание баз данных. all   - все пересоздаются
#                                     scorm - только база данных scorm
#                                     test  - только база данных scorm_test
# необязательные опции:
# --start=test  - по окончании работы скрипта, старт mojo с указанной базой, если не указано, то стартует с базой scorm

use utf8;
use strict;
use warnings;

use lib './lib';
use IO::All;
use Freee::EAV;
use Digest::SHA qw( sha256_hex );
use Install;
use DBI qw(:sql_types);
use Data::Dumper;
use Freee::Mock::Install;

use DDP;

# binmode(STDOUT);
# binmode(STDERR);

my ( $self, $path_sql, $path_conf, $path_log, $check_scorm, $config_update, @bd_array );

# чтение параметров
my %options;
foreach my $parameter ( @ARGV ) {
    $parameter =~ s/^\-+//g;
    my @array = split(/=/, $parameter);
    $options{$array[0]} = $array[1];
}

helpme('help') unless scalar( keys %options );

# Проверяем наличие ключей при вызове
helpme('need_config') if ( ! exists $options{'path'} || ! -e $options{'path'});

helpme('need_mode') unless exists $options{'mode'};
my $mode = $options{'mode'};
helpme('need_mode') unless grep( /^$mode$/, ( 'all', 'test', 'scorm' ) );

$options{'rebuild'} = ( exists $options{'rebuild'} && $options{'rebuild'} ) ? 1 : 0;

$mode = $options{'start'};
$options{'start'} = ( exists $options{'start'} && $options{'start'} && grep( /^$mode$/, ( 'test', 'scorm' ) ) ) ? $options{'start'} : 'scorm';

# командный автомат
my $command = join('', map { $options{$_} if $_ ne 'path' } sort keys %options); 

p $command;

# читаем дефолтный конфиг
$config_update < io $options{'path'};
$config_update = { eval $config_update }->{'config_update'};
helpme('need_config') if ( $@ );

# генерируем secrets
push @{$config_update->{'secrets'}}, generate_secret( 40 );

# Соединяеся с базой для создания/удаления баз
$self->{dbh} = connect_db( $config_update->{'databases'}->{'pg_postgres'} );

# скрипт запущен как 
my %command = (
    # ./script/install.pl mode=all start=test rebuild=1 path=../temp_freee.conf
    'all1test' => \&all_one_test(),
    # ./script/install.pl mode=test start=test rebuild=1 path=../temp_freee.conf
    'scorn1test' => \&scorn_one_test,
    # ./script/install.pl mode=scorm start=test rebuild=1 path=../temp_freee.conf
    'scorm1test' => \&scorm_one_test,

    # ./script/install.pl mode=all start=scorm rebuild=1 path=../temp_freee.conf
    'all1scorm' => \&all_one_scorm,
    # ./script/install.pl mode=test start=scorm rebuild=1 path=../temp_freee.conf
    'test1scorm' => \&test_one_scorm,
    # ./script/install.pl mode=scorm start=scorm rebuild=1 path=../temp_freee.conf
    'scorm1scorm' => \&scorm_one_scorm,

    # ./script/install.pl mode=all start=test rebuild=0 path=../temp_freee.conf
    'all0test' => \&all_test,
    # ./script/install.pl mode=test start=test rebuild=0 path=../temp_freee.conf
    'test0test' => \&test_test,
    # ./script/install.pl mode=scorm start=test rebuild=0 path=../temp_freee.conf
    'scorm0test' => \&scorm_test,

    # ./script/install.pl mode=all start=scorm rebuild=0 path=../temp_freee.conf
    'all0scorm' => \&all_scorm,
    # ./script/install.pl mode=test start=scorm rebuild=0 path=../temp_freee.conf
    'test0scorm' => \&test_scorm,
    # ./script/install.pl mode=scorm start=scorm rebuild=0 path=../temp_freee.conf
    'scorm0scorm' => \&scorm_scorm,
);

warn 'All setting required';

exit;

# ./script/install.pl mode=all start=test rebuild=1 path=../temp_freee.conf
# --rebuild=1   - создание базы и конфигурации (1)
# --mode=all    - создание баз данных. all - все пересоздаются
# --start=test  - по окончании работы скрипта, старт mojo с базой test
sub all_one_test {

    # проверяем наличие баз scorm,scorm_test удаляем и создаем заново, если нужно
    # ( rebuild=1 ) -  персоздаем базу
    my @bases = ('scorm', 'scorm_test');
    if ( $options{'rebuild'} ) {
        @bases = ('scorm') if $options{'mode'} eq 'scorm';
        @bases = ('scorm_test') if $options{'mode'} eq 'test';

        foreach my $db_name (@bases) {
            if ( check_db( $self, $db_name ) ) {
                # удаляем старую базу scorm
                delete_db( $self, $db_name );
            }

            # создаем базу
            create_db( $self, $db_name );

            # создаем таблицы
            # коннект к нужной базе
            my $connect = ( $db_name =~ /test/ ) ? $config_update->{'databases'}->{'pg_main_test'} : $config_update->{'databases'}->{'pg_main'};
            $self->{dbh} = connect_db( $connect );
            create_tables( $self );

            # для удаления и создания таблицы - коннект под юзером postgres
            $self->{dbh} = connect_db( $config_update->{'databases'}->{'pg_postgres'} );
print "\n";
        }
    }


    # перезаписываем конфиг mojo предварительной удалив лишнее и сгенерировав secrets
    delete $config_update->{'databases'}->{'pg_postgres'};
    delete $config_update->{'users'};
    write_config( $config_update );

die;
    # стартуем mojo с базой scorm_test
    mojo_do( 'stop' );

    # загрузка дефолтных значений
    load_defaults( $self, $config_update );
}

# ./script/install.pl mode=test start=test rebuild=1 path=../temp_freee.conf
# --rebuild=1   - создание базы и конфигурации (1)
# --mode=test   - test  - только база данных scorm_test
# --start=test  - по окончании работы скрипта, старт mojo с базой test
sub scorn_one_test {
    # пересоздаем базу scorm_test

    # перезаписываем конфиг mojo

    # стартуем mojo с базой scorm_test
}

# ./script/install.pl mode=scorm start=test rebuild=1 path=../temp_freee.conf
# --rebuild=1   - создание базы и конфигурации (1)
# --mode=scorm  - test  - только база данных scorm_test
# --start=test  - по окончании работы скрипта, старт mojo с базой test
sub scorm_one_test {
    # пересоздаем базу scorm_test

    # перезаписываем конфиг mojo

    # стартуем mojo с базой scorm_test
}




# unless (keys %options) {
#     helpme('help');
#     exit;
# }

# foreach( 'path', 'rebuild' ) {
#     unless ( exists $options{$_} ) {
#         logging( "required parameter $_ doesn't exist" );
#         exit;
#     }
# }

# # проверка параметров test
# if ( $options{'mode'} &&  $options{'mode'} ne 'test' || $options{'start'} &&  $options{'start'} ne 'test' ) {
#     logging( "wrong format '$options{'mode'}' of 'test' parameter" ); 
#     exit;
# }

# # поиск и чтение шаблона конфигурации
# if ( -s $options{'path'} ) {
#     my $filename = $options{'path'};
#     $config_update = slurp( $filename, encoding => 'utf8' );
#     $config_update = eval( $config_update );
# }
# else {
#     logging( 'file doesnt exist');
#     helpme('need_config');
#     exit;
# }

# # проверка параметра создания бд
# if ( $options{'rebuild'} ) {
#     # подключение к базе postgres
#     $self->{dbh} = DBI->connect(
#         'dbi:Pg:dbname=postgres;host=localhost;port=5432',
#         'troll',
#         'Yfenbkec_1',
#         { 
#             'pg_enable_utf8' => 1, 
#             'pg_auto_escape' => 1, 
#             'AutoCommit' => 1, 
#             'PrintError' => 1, 
#             'RaiseError' => 1, 
#             'pg_server_prepare' => 0 
#         }
#     );
#     if ( DBI->errstr ) {
#         logging( "connection to database doesn't work:" . DBI->errstr );
#         exit;
#     }

#     # проверка существования базы scorm
#     $check_scorm = check_db( $self, 'scorm' );

#     # создаём базы
#     if ( $options{'mode'} ) {
# print "11\n";

#         # проверка отсутствия базы scorm_test
#         if ( check_db( $self, 'scorm_test' ) ) {
#             delete_db_test( $self );
#         }

#         if ( $check_scorm ) {
#             # массив только scorm_test
#             @bd_array = ( 'scorm_test' );
#         }
#         else {
#             # массив из test, scorm
#             if ( $options{'start'} ) {
#                 @bd_array = ( 'scorm', 'scorm_test' );
#             }
#             else {
#                 @bd_array = ( 'scorm_test', 'scorm' );
#             }
#         }
#     }
#     else{
# print "22\n";
#         unless( $check_scorm ) {
#             # массив только scorm
#             @bd_array = ( 'scorm' );
#         }
#     }
# p @bd_array;
#     # для каждого эл-та массива
#     foreach( @bd_array ) {
#         # остановка mojo
#         mojo_do( 'stop' );

# print "1111111111111111111\n";
#         # если это тестовая база
#         if ( $_ eq 'scorm_test' ) {
#             # заполнение параметров конфига для тестовой базы ---
#             create_db( $self, '/_create_test_db.sql' );

#             connect_db( $self, $config_update, 'pg_main_test' );
#         }
#         else {
#             # заполнение параметров конфига для основной базы ---
#             create_db( $self, '/_create_db.sql' );

#             connect_db( $self, $config_update, 'pg_main' );
#         }

#         # запись конфигурации в файл freee.conf
#         write_config();
# print "1111111111111111111\n";

#         # запуск скриптов, создающих таблицы
#         create_tables( $self );

#         # старт mojo
#         mojo_do( 'start' );

#         # загрузка дефолтных значений
#         load_defaults( $self, $config_update );

#     }
# }
# else {
#     # остановка mojo
#     mojo_do( $path_conf, 'stop' );

#     # заполнение параметров конфига
#     # $$config{ 'test' } = $$temp_freee::config_update{ 'test' } if $$temp_freee::config_update{ 'test' };
#     $$config{ 'test' } = $$config_update{ 'test' } if $$config_update{ 'test' };
#     my $main = $options{'mode'} ? 'pg_main_test' : 'pg_main';
#     update_config( $config_update, $main );

#     # запись конфигурации в файл freee.conf
#     write_config();

#     # старт mojo
#     mojo_do( 'start' );

# }

# # конец программы
# warn 'All setting required';
# exit;

####################################################################

sub helpme {
    my $mess_key = shift;

    my %messages = (
        'need_mode'  => "mode must be set as 'all'/'test'/'scorm' value",
        'need_mode'  => "mode must be set as 'all'/'test'/'scorm' value",
        'need_config' => q~Default config file not exists or wrong file format.

Default data config must be like this:

package temp_freee;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw( $config_update );

our $config_update = {
    # Данные добавляемого админа
    'debug'                 => 1,
    'test'                  => 0,
    'login'                 => 'login',
    'password'              => 'password',

    # данные доступа к базе postgres
    'pglogin'               => 'loginPG',
    'pgpassword'            => 'passwordPG',

    # данные доступа к базам данных
    'expires'               => '6000',
    'pg_main_username'      => 'username1',
    'pg_main_password'      => 'password1',
    'pg_main_test_username' => 'username2',
    'pg_main_test_password' => 'password2,
    'export_settings_path'  => '/home/<user>/settings'
};
~,
        'help' => q~
You can use these options:
    --path='./temp_freee.conf   - path to default data
    --mode=test                 - create test DB if need
    --rebuild=1/0               - create DB and config if '1', else create configuration only
    --start=test                - start mojo with test DB if need (default - starting with man DB)
~,
    );

    if ($mess_key && exists $messages{$mess_key} ) {
        print $messages{$mess_key};
    }
    else {
        print $mess_key;
    }
    die;
}