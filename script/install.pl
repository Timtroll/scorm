#!/usr/bin/perl -w

# должен вызываться только из корневой директории для не существующей базы данных
# миграция: чтение и запуск sql файлов из scorm/sql
# для миграции обязателен параметр с адресом конфигурации, которая находится вне git
# для миграции тестовой базы данных добавить при вызове параметр test
# ./script/install.pl
# обязательные опции:
# --path=../temp_freee.conf
# --rebuild=1/0 - создание базы и конфигурации (1) или только конфигурации (0)
# --mode=scorm/test - создание баз данных.
#                                     scorm - только база данных scorm
#                                     test  - только база данных scorm_test
# необязательные опции:
# --start=test  - по окончании работы скрипта, старт mojo с указанной базой, если не указано, то стартует с базой scorm

use utf8;
use strict;
use warnings;

use lib './lib';
use Digest::SHA qw( sha256_hex );
use Install;
use DBI qw(:sql_types);
use Data::Dumper;
use Freee::Mock::Install;
use common;

$| = 1;

my ( $self, $path_sql, $path_conf, $path_log, $check_scorm, $config_update, $base );

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

# читаем дефолтный конфиг
$config_update = read_file( $options{'path'}, undef );
$config_update = { eval( $config_update ) }->{'config_update'};
helpme('need_config') if ( $@ );

# генерируем secrets
push @{$config_update->{'secrets'}}, generate_secret( 40 );

mojo_do( 'stop' );

# Соединяеся с базой
$self->{dbh} = connect_db( $config_update->{'databases'}->{'pg_postgres'} );

# останавливаем все соединения с базой
my $name = ( $options{'mode'} eq 'test' ) ? 'scorm_test' : 'scorm';
# $name = 'scorm_test' if $options{'mode'} eq 'test';
# $name = 'scorm' if $options{'mode'} eq 'scorm';

my $sql = 'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE "datname" = \''.$name.'\' ORDER BY "backend_start" ASC LIMIT ( SELECT COUNT(*) FROM pg_stat_activity WHERE "datname" = \''.$name.'\' )::integer';
my $sth = $self->{dbh}->prepare( $sql );
$sth->execute();
$sth->finish();

# создание/удаление баз
all_one_test();

warn 'All setting required';

exit;

# ./script/install.pl mode=all start=test rebuild=1 path=../temp_freee.conf
# --rebuild=1   - создание базы и конфигурации (1)
# --mode=all    - создание баз данных. all - все пересоздаются
# --start=test  - по окончании работы скрипта, старт mojo с базой test
sub all_one_test {

    # проверяем наличие баз scorm,scorm_test удаляем и создаем заново, если нужно
    # ( rebuild=1 ) -  персоздаем базу

    if ( $options{'rebuild'} ) {
        $base = ('scorm') if $options{'mode'} eq 'scorm';
        $base = ('scorm_test') if $options{'mode'} eq 'test';

        if ( check_db( $self, $base ) ) {
            # удаляем старую базу scorm
            delete_db( $self, $base );
        }

        # создаем базу
        create_db( $self, $base );

        # создаем таблицы
        # коннект к нужной базе
        my $connect = ( $base =~ /test/ ) ? $config_update->{'databases'}->{'pg_main_test'} : $config_update->{'databases'}->{'pg_main'};
        $self->{dbh} = connect_db( $connect );
        create_tables( $self );

        # для удаления и создания таблицы - коннект под юзером postgres
        $self->{dbh} = connect_db( $config_update->{'databases'}->{'pg_postgres'} );
    }


    # перезаписываем конфиг mojo предварительной удалив лишнее и сгенерировав secrets
    delete $config_update->{'databases'}->{'pg_postgres'};

    my %config_users = %$config_update{'users'};

    delete $config_update->{'users'};
    write_config( $config_update );

    if ( $options{'rebuild'} ) {
        my $connect = ( $base =~ /test/ ) ? $config_update->{'databases'}->{'pg_main_test'} : $config_update->{'databases'}->{'pg_main'};
        $self->{dbh} = connect_db( $connect );
        $config_update->{'test'} = $base eq 'scorm' ? 0 : 1;

        # стартуем mojo с базой scorm_test
        write_config( $config_update );

        # загрузка дефолтных значений
        load_defaults( $self, \%config_users, $config_update->{'host'}, $config_update->{'secrets'}->[0] );
    }
}

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
