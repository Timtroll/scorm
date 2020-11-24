package Install;

use utf8;
use warnings;
use strict;

use DBI qw(:sql_types);
use DDP;
use Digest::SHA qw( sha256_hex );

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK );
use File::Slurp::Unicode qw(slurp write_file);
use Data::Dumper;

binmode(STDOUT);
binmode(STDERR);

our @ISA = qw( Exporter );
our @EXPORT = qw(
    &logging &check_db &delete_db &mojo_do &create_db &connect_db &create_tables &load_defaults &add_user 
    &write_config &reset_scorm_test &generate_secret $path_log $path_sql $path_conf $config
);
our @EXPORT_OK = qw(
    &logging &check_db &delete_db &mojo_do &create_db &connect_db &create_tables &load_defaults &add_user
    &write_config &reset_scorm_test &generate_secret $path_log $path_sql $path_conf $config
);

our ( $path_log, $path_sql, $path_conf, $config );
# путь к директории с логированием
$path_log = './log/migration.log';

# путь к директории со скриптами миграции
$path_sql = './sql';

# путь к директории с конифгурацией
$path_conf = './freee.conf';

# логирование ошибки
# logging( "комментарий и текст ошибки" );
sub logging {
    my ( $logdata ) = @_;

    if ( $logdata ) {
        warn "$logdata\n";
        if ( -e $path_log) {
            open( FILE, '>>', $path_log ) or warn "Can't open log file! $!";
        }
        else {
            open( FILE, '>', $path_log ) or warn "Can't open log file! $!";
        }
            print FILE "$logdata\n";
        close( FILE );
    }
}

# проверка существования базы данных
# my $true = check_db( 'database' );
sub check_db {
    my ( $self, $database ) = @_;

    my $check_db = 'SELECT datname FROM pg_database WHERE datname = ?';
    my $sth = $self->{dbh}->prepare( $check_db );
    $sth->bind_param( 1, $database );
    my $res = $sth->execute();
    $sth->finish();

    $res = 0 if $res == '0E0';

    return $res;
}

# запуск или остановка mojo
# my $true = mojo_do( 'start/stop' );
sub mojo_do {
    my $do = shift;

    unless ( -s $path_conf || $do eq 'stop' ) {
        logging( 'config doesnt exist' );
        exit;
    }

    my $res = `./starting.sh $do`;
    return $res;
}

# удаление базы данных
# my $true = delete_db( $self, $db_name );
sub delete_db {
    my ($self, $db_name ) = @_;

    # остановка mojo
    mojo_do( 'stop' );
    # my $res = `perl starting.sh stop`;

    my $sth = $self->{dbh}->prepare( "DROP database ".$db_name );
    my $res = $sth->execute();
    $sth->finish();

    $res = 0 if $res == '0E0';

    return $res;
}

# my $true = create_db( $self, $db_name );
# создание базы данных
sub create_db {
    my ( $self, $db_name ) = @_;


    my $sth = $self->{dbh}->prepare( "CREATE DATABASE ".$db_name." WITH TEMPLATE='template1' ENCODING='UTF8' TABLESPACE='pg_default'"  );
    my $res = $sth->execute();
    $sth->finish();

    if ( DBI->errstr ) {
        warn "execute doesn't work " . DBI->errstr;
        logging( "execute doesn't work " . DBI->errstr );
        exit;
    }
    warn "Db '$db_name' created";
}

# коннект к базе 
# my $dbh = connect_db( $config );
sub connect_db {
    my ( $config ) = shift;

    # подключение к базе postgres
    my $dbh = DBI->connect(
        $config->{'dsn'},
        $config->{'username'},
        $config->{'password'},
        $config->{'options'}
    );
    if ( DBI->errstr ) {
        helpme( "connection to database doesn't work:" . DBI->errstr );
    }

    return $dbh;
}

sub create_tables {
    my $self = shift;

    # создание расширения
    my $filename = $path_sql . '/_create_extiention.sql';
    my $sql = slurp( $filename, encoding => 'utf8' );
    my $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();
    $sth->finish();

    if ( DBI->errstr ) {
        warn "execute doesn't work " . DBI->errstr . " in $filename script";
        logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
        exit;
    }

    # чтение файлов директории скриптов
    my @list = `ls $path_sql 2>&1`;
    if ( $? ) {
        logging( "can't read directory $path_sql: @list" ); 
        exit;
    };
    # обработка файлов директории  
    foreach ( @list ) {
        chomp;
        # фильтрация не sql файлов и папок
        next if ( -d $path_sql . '/' . $_ || /^\_/ || ! /\.sql$/ );

        $filename = $path_sql . '/' . $_;

        # чтение содержимого файлов
        $sql = slurp( $filename, encoding => 'utf8' );
        unless ( $sql ) { 
            logging( "can't read file $filename" ); 
            exit; 
        };

        # выполение скриптов
        $sth = $self->{dbh}->prepare( $sql );
        $sth->execute();
        $sth->finish();

        if ( DBI->errstr ) {
            warn "execute doesn't work " . DBI->errstr . " in $filename script";
            logging( "execute doesn't work " . DBI->errstr . " in $filename script\n" );
            exit;    
        }
    }
}

# загрузка дефолтных значений
sub load_defaults {
    my ( $self, $config_users, $host ) = @_;

    # загрузка дефолтных настроек
    my $url = $host . '/settings/load_default';
    # --spider - не загружать файл с ответом
    `wget --wait=3 --tries=3 --retry-connrefused --spider $url`;

    # получаем id группы unaproved
    my $sql = 'SELECT * FROM "public"."groups" WHERE "name" = \'admin\'';
    my $sth = $self->{dbh}->prepare( $sql );
    $sth->execute();

    $sth->finish();

    # my $groups = $sth->fetchrow_hashref();
    # unless ( (ref($groups) eq 'HASH') && $$groups{id} ) {
    #     push @!, 'Could not get Groups';
    #     $self->{dbh}->rollback;
    #     return;
    # }

    # добавляем админа
    # my $salt = $config_update->{'secrets'}->[0];

    my @users = ( 'admin', 'teacher', 'student' );
    foreach my $user (@users) {
        add_user( $self, $config_users->{'users'}->{$user} );
    }
    # add_user( $self,
    #     {
    #         'email'     => 'admin@admin',
    #         'login'     => $config_update->{'login'},
    #         'password'  => sha256_hex( $config_update->{'password'}, $salt ),

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
    #     }
    # );

    # # добавляем учителя
    # add_user( $self,
    #     {
    #         'email'     => 'teacher@teacher',
    #         'login'     => 'teacher',
    #         'password'  => sha256_hex( $config_update->{'password'}, $salt ),

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
    #     }
    # );

    # # добавляем студента
    # add_user( $self,
    #     {
    #         'email'     => 'student@student',
    #         'login'     => 'student',
    #         'password'  => sha256_hex( $config_update->{'password'}, $salt ),

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
    #     }
    # );
}

sub add_user {
    my ( $self, $data ) = @_;

    Freee::EAV->new( 'User', { dbh => $self->{dbh} } );
    my $user =    {
        'publish'   => \1,
        'parent'    => 1,
        'timezone'  => 3,
        'title'     => $$data{'title'},
        'User'      => $$data{'User'}
    };
    my $eav = Freee::EAV->new( 'User', $user );
    my $eav_id = $eav->id(); 

    # получение соли из конфига
    $user = {
        'publish'     => 't', 
        'email'       => $$data{'email'},
        'login'       => $$data{'login'},
        'password'    => $$data{'password'},
        'timezone'    => 3,
        'eav_id'      => $eav_id
    };

    my $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} keys %$user ).') VALUES ( '.join( ',', map { ':'.$_ } keys %$user ).' )';
    my $sth = $self->{'dbh'}->prepare( $sql );
    foreach ( keys %$user ) {
        my $type = /publish/ ? SQL_BOOLEAN : undef();
        $sth->bind_param( ':'.$_, $$user{$_}, $type );
    }
    my $result = $sth->execute();
    $sth->finish();

    # ввод в user_groups
    $sql = 'INSERT INTO "public"."user_groups" ( user_id, group_id ) VALUES ( :user_id, :group_id )';
    $sth = $self->{'dbh'}->prepare( $sql );
    $sth->bind_param( ':user_id', $$data{'user_id'} );
    $sth->bind_param( ':group_id', $$data{'group_id'} );
    $result = $sth->execute();
    $sth->finish();
}

# запись конфигурации в файл freee.conf
sub write_config {
    my $config = shift;

    # настройка dumper, чтобы не было лишнего 'var='
    $Data::Dumper::Terse = 1;

    # запись конфигурации в файл
    my $result = write_file(
        $path_conf,
        Dumper( $config )
    );
}

# генерация строки из случайных букв и цифр
# my $string = generate_secret( 32 );
# возвращается строка
sub generate_secret {
    my $length = shift;

    return unless $length =~ /^\d+$/;

    my @chars = ( "A".."Z", "a".."z", 0..9 );
    my $string = join("", @chars[ map { rand @chars } ( 0..$length ) ]);

    return $string;
};

# sub reset_scorm_test {
#     my ( $self, $config_update ) = @_;

#     # остановка mojo
#     mojo_do( 'stop' );

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

#     if ( check_db( $self, 'scorm_test' ) ) {
#         # удаление базы
#         delete_db( $self, 'scorm_test' );
#     }

#     # заполнение параметров конфига для тестовой базы ---
#     create_db( $self, 'scorm_test' );
#     connect_db( $self, $config_update, 'pg_main_test' );

#     # запуск скриптов, создающих таблицы
#     create_tables( $self );

#     # старт mojo
#     mojo_do( 'start' );

#     # загрузка дефолтных значений
#     load_defaults( $self, $config_update );
# }

1;
