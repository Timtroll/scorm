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
warn 1;
# поиск и чтение шаблона конфигурации
if ( -s $hash{'path'} ) {
    my $filename = $hash{'path'};
    $config_update = slurp( $filename, encoding => 'utf8' );
    $config_update = eval( $config_update );
    warn Dumper( $config_update );
}
else {
    logging( 'file doesnt exist');
    helpme('need_config');
    exit;
}
warn 2;
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
warn Dumper( $self );
    # проверка существования базы scorm
    $check_scorm = check_db( $self, 'scorm' );
warn 3;

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
warn 4;
    # для каждого эл-та массива
    foreach( @bd_array ) {
        # остановка mojo
        mojo_do( 'stop' );
warn 4.5;
        # если это тестовая база
        if ( $_ eq 'scorm_test' ) {
            # заполнение параметров конфига для тестовой базы ---
            create_db( $self, '/_create_test_db.sql' );
warn 4.6;
            connect_db( $self, $config_update, 'pg_main_test' );
warn 4.7;
        }
        else {
            # заполнение параметров конфига для основной базы ---
            create_db( $self, '/_create_db.sql' );
warn 4.9;
            connect_db( $self, $config_update, 'pg_main' );
warn 4.8;
        }
warn 5;
        # запись конфигурации в файл freee.conf
        write_config();
warn 6;
        # запуск скриптов, создающих таблицы
        create_tables( $self );
warn 7;
        # старт mojo
        mojo_do( 'start' );
warn 8;
        # загрузка дефолтных значений
        load_defaults( $self, $config_update );
warn 9;
    }
}
else {
    # остановка mojo
    mojo_do( $path_conf, 'stop' );
warn 2.1;
    # заполнение параметров конфига
    # $$config{ 'test' } = $$temp_freee::config_update{ 'test' } if $$temp_freee::config_update{ 'test' };
    $$config{ 'test' } = $$config_update{ 'test' } if $$config_update{ 'test' };
    my $main = $hash{'mode'} ? 'pg_main_test' : 'pg_main';
    update_config( $config_update, $main );
warn 2.2;
    # запись конфигурации в файл freee.conf
    write_config();
warn 2.3;
    # старт mojo
    mojo_do( 'start' );
warn 2.4;
}

# конец программы
warn 'All setting required';
exit;

####################################################################


# # логирование ошибки
# # logging( "комментарий и текст ошибки" );
# sub logging {
#     my $logdata = shift;
#     my $log;

#     if ( $logdata ) {
#         warn "$logdata\n";
#         open( $log, '>>', $path_log ) or warn "Can't open log file! $!";
#             print $log "$logdata\n";
#         close( $log );
#     }
# }

# # проверка существования базы данных
# # my true = check_db( database );
# sub check_db {
#     my $database = shift;

#     my $check_db = 'SELECT datname FROM pg_database WHERE datname = ?';
#     my $sth = $self->{dbh}->prepare( $check_db );
#     $sth->bind_param( 1, $database );
#     my $res = $sth->execute();
#     $sth->finish();

#     $res = 0 if $res == '0E0';

#     return $res;
# }

# # удаление базы данных
# # my true = delete_db( database );
# sub delete_db_test {
#     my $database = shift;

#     my $delete_db = 'DROP database scorm_test';
#     my $sth = $self->{dbh}->prepare( $delete_db );
#     my $res = $sth->execute();
#     $sth->finish();

#     $res = 0 if $res == '0E0';

#     return $res;
# }

# # запуск или остановка mojo
# # my true = mojo_do( do );
# sub mojo_do {
#     my $do = shift;

#     unless ( -s $path_conf || $do eq 'stop' ) {
#         logging( 'config doesnt exist' );
#         exit;
#     }

#     my $res = `./starting.sh $do`;
#     return $res;
# }

# # my true = create_db(  );
# # создание базы данных
# sub create_db {
#     my $create_db = shift;

#     my $filename = $path_sql . $create_db;
#     my $sql = slurp( $filename, encoding => 'utf8' );
#     my $sth = $self->{dbh}->prepare( $sql );
#     my $res = $sth->execute();
#     $sth->finish();

#     if ( DBI->errstr ) {
#         warn "execute doesn't work " . DBI->errstr . " in $filename script";
#         logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
#         exit;
#     }
#     warn 'Db created';
# }

# # заполнение параметров и создание конфига 
# # my true = connect_db( main );
# sub connect_db {
#     my $main = shift;

#     # обновление конфигурации
#     $$config{ 'test' } = $main eq 'pg_main_test' ? 1 : 0;
#     update_config( $main );

#     my $db = $config->{'dbs'}->{'databases'}->{$main};

#     # редактирование параметра обработки ошибок
#     if (
#         $db &&
#         $db->{'options'} &&
#         $db->{'options'}->{'RaiseError'} 
#     ) {
#         $db->{'options'}->{'RaiseError'} = 1;
#     }

#     $self->{dbh} = DBI->connect(
#         $db->{'dsn'},
#         $db->{'username'},
#         $db->{'password'},
#         $db->{'options'}
#     );
#     if ( DBI->errstr ) {
#         logging( "connection to database doesn't work:" . DBI->errstr );
#         exit;
#     }
# }

# sub create_tables {
#     # создание расширения
#     my $filename = $path_sql . '/_create_extiention.sql';
#     my $sql = slurp( $filename, encoding => 'utf8' );
#     my $sth = $self->{dbh}->prepare( $sql );
#     my $res = $sth->execute();
#     $sth->finish();

#     if ( DBI->errstr ) {
#         warn "execute doesn't work " . DBI->errstr . " in $filename script";
#         logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
#         exit;
#     }

#     # чтение файлов директории скриптов
#     my @list = `ls $path_sql 2>&1`;
#     if ( $? ) {
#         logging( "can't read directory $path_sql: @list" ); 
#         exit;
#     };
#     # обработка файлов директории  
#     foreach ( @list ) {
#         chomp;
#         # фильтрация не sql файлов и папок
#         next if ( -d $path_sql . '/' . $_ || /^\_/ || ! /\.sql$/ );

#         $filename = $path_sql . '/' . $_;

#         # чтение содержимого файлов
#         $sql = slurp( $filename, encoding => 'utf8' );
#         unless ( $sql ) { 
#             logging( "can't read file $filename" ); 
#             exit; 
#         };

#         # выполение скриптов
#         $sth = $self->{dbh}->prepare( $sql );
#         $res = $sth->execute();
#         $sth->finish();

#         if ( DBI->errstr ) {
#             warn "execute doesn't work " . DBI->errstr . " in $filename script";
#             logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
#             exit;    
#         }
#     }
# }

# # загрузка дефолтных значений
# sub load_defaults {
#     # загрузка дефолтных настроек
#     my $host = $config->{'host'};
#     my $url = $host . '/settings/load_default';
#     # --spider - не загружать файл с ответом
#     `wget --wait=3 --tries=3 --retry-connrefused --spider $url`;

#     # получаем id группы unaproved
#     my $sql = 'SELECT * FROM "public"."groups" WHERE "name" = \'admin\'';
#     my $sth = $self->{dbh}->prepare( $sql );
#     $sth->execute();
#     $sth->finish();

#     # my $groups = $sth->fetchrow_hashref();
#     # unless ( (ref($groups) eq 'HASH') && $$groups{id} ) {
#     #     push @!, 'Could not get Groups';
#     #     $self->{dbh}->rollback;
#     #     return;
#     # }

#     # добавляем админа
#     my $salt = $config->{'secrets'}->[0];
#     add_user({
#         'email'     => 'admin@admin',
#         'login'     => $temp_freee::config_update->{'login'},
#         'password'  => sha256_hex( $temp_freee::config_update->{'password'}, $salt ),

#         'user_id'   => 1,
#         'group_id'  => 1,

#         'title'     => 'admin',
#         'User' => {
#             'place'         => "scorm",
#             'country'       => "RU",
#             'birthday'      => "19950803 00:00:00",
#             'patronymic'    => "admin",
#             'name'          => "admin",
#             'surname'       => "admin"
#         }
#     });

#     # добавляем учителя
#     add_user({
#         'email'     => 'teacher@teacher',
#         'login'     => 'teacher',
#         'password'  => sha256_hex( $temp_freee::config_update->{'password'}, $salt ),

#         'user_id'   => 2,
#         'group_id'  => 2,

#         'title'     => 'teacher',
#         'User' => {
#             'place'         => "scorm",
#             'country'       => "RU",
#             'birthday'      => "19950803 00:00:00",
#             'patronymic'    => "teacher",
#             'name'          => "teacher",
#             'surname'       => "teacher"
#         }
#     });

#     # добавляем студента
#     add_user({
#         'email'     => 'student@student',
#         'login'     => 'student',
#         'password'  => sha256_hex( $temp_freee::config_update->{'password'}, $salt ),

#         'user_id'   => 3,
#         'group_id'  => 3,

#         'title'     => 'student',
#         'User' => {
#             'place'         => "scorm",
#             'country'       => "RU",
#             'birthday'      => "19950803 00:00:00",
#             'patronymic'    => "student",
#             'name'          => "student",
#             'surname'       => "student"
#         }
#     });
# }

# sub add_user {
#     my $data = shift;

#     Freee::EAV->new( 'User', { dbh => $self->{dbh} } );
#     my $user =    {
#         'publish'   => \1,
#         'parent'    => 1,
#         'timezone'  => 3,
#         'title'     => $$data{'title'},
#         'User'      => $$data{'User'}
#     };
#     my $eav = Freee::EAV->new( 'User', $user );
#     my $eav_id = $eav->id(); 

#     # получение соли из конфига
#     $user = {
#         'publish'     => 't', 
#         'email'       => $$data{'email'},
#         'login'       => $$data{'login'},
#         'password'    => $$data{'password'},
#         'timezone'    => 3,
#         'eav_id'      => $eav_id
#     };

#     my $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} keys %$user ).') VALUES ( '.join( ',', map { ':'.$_ } keys %$user ).' )';
#     my $sth = $self->{'dbh'}->prepare( $sql );
#     foreach ( keys %$user ) {
#         my $type = /publish/ ? SQL_BOOLEAN : undef();
#         $sth->bind_param( ':'.$_, $$user{$_}, $type );
#     }
#     my $result = $sth->execute();
#     $sth->finish();

#     # ввод в user_groups
#     $sql = 'INSERT INTO "public"."user_groups" ( user_id, group_id ) VALUES ( :user_id, :group_id )';
#     $sth = $self->{'dbh'}->prepare( $sql );
#     $sth->bind_param( ':user_id', $$data{'user_id'} );
#     $sth->bind_param( ':group_id', $$data{'group_id'} );
#     $result = $sth->execute();
#     $sth->finish();
# }

# # запись конфигурации в файл freee.conf
# sub write_config {
#     # настройка dumper, чтобы не было лишнего 'var='
#     $Data::Dumper::Terse = 1;

#     # запись конфигурации в файл
#     my $result = write_file(
#         $path_conf,
#         Dumper( $config )
#     );
# }

# # заполнение параметров конфига
# sub update_config {
#     my $main = shift;

#     $$config{ 'url' }                                           = $$temp_freee::config_update{ 'url' }                   if $$temp_freee::config_update{ 'url' };

#     $$config{ 'expires' }                                       = $$temp_freee::config_update{ 'expires' }               if $$temp_freee::config_update{ 'expires' };
#     $$config{ 'debug' }                                         = $$temp_freee::config_update{ 'debug' }                 if $$temp_freee::config_update{ 'debug' };
#     $$config{ 'export_settings_path' }                          = $$temp_freee::config_update{ 'export_settings_path' }  if $$temp_freee::config_update{ 'export_settings_path' };

#     $config->{'dbs'}->{'databases'}->{$main}->{'username'}      = $$temp_freee::config_update{ $main . '_username' }     if $$temp_freee::config_update{ $main . '_username' }; 
#     $config->{'dbs'}->{'databases'}->{$main}->{'password'}      = $$temp_freee::config_update{ $main . '_password' }     if $$temp_freee::config_update{ $main . '_password' };
#     $config->{'dbs'}->{'databases'}->{$main}->{'options'}       = $$temp_freee::config_update{ $main . '_options' }      if $$temp_freee::config_update{ $main . '_options' };
# }

# sub helpme {
#     my $swith = shift;

#     my %messages = (
#         'help' => q~
# You can use these options:
#     --path='./temp_freee.conf   - path to default data
#     --mode=test                 - create test DB if need
#     --rebuild=1/0               - create DB & config if '1', else create configuration only
#     --start=test                - start mojo with test DB if need (default - starting with man DB)
# ~,
#         'need_config' => q~
# Default data config muse like this:

# package temp_freee;

# use Exporter;
# our @ISA = 'Exporter';
# our @EXPORT = qw( $config_update );

# our $config_update = {
#     # Данные добавляемого админа
#     'debug'                 => 1,
#     'test'                  => 0,
#     'login'                 => 'login',
#     'password'              => 'password',

#     # данные доступа к базе postgres
#     'pglogin'               => 'loginPG',
#     'pgpassword'            => 'passwordPG',

#     # данные доступа к базам данных
#     'expires'               => '6000',
#     'pg_main_username'      => 'username1',
#     'pg_main_password'      => 'password1',
#     'pg_main_test_username' => 'username2',
#     'pg_main_test_password' => 'password2,
#     'export_settings_path'  => '/home/<user>/settings'
# };~,
#     );

#     if ($swith && exists $messages{$swith} ) {
#         warn $messages{$swith};
#     }
#     else {
#         warn 'Message was not defined';
#     }
# }