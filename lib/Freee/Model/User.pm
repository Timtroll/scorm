package Freee::Model::User;

use Mojo::Base 'Freee::Model::Base';

use POSIX qw(strftime);
use DBI qw(:sql_types);
use Mojo::JSON qw( decode_json );

# DBI->trace(1);

use Data::Dumper;

####################################################################
# Поля пользователя
####################################################################

# поля которые лежат в таблице users_social
my %social_fields = (
    'user_id'       => 1,
    'social'        => 1,
    'access_token'  => 1,
    'social_id'     => 1,
    'social_profile'=> 1
);

# поля которые лежат в таблице users_masks
my %masks_fields = (
    'user_id'       => 1,
    'key'           => 1,
    'mask'          => 1
);


###################################################################
# Пользователи
###################################################################

# список юзеров по группам (обязательно id группы)
# $result = $self->model('User')->_get_list( $data );
# $data = {
#   group_id => <id>, - Id группы
#   publish  => 1,    - показывать пользователей только с этим статусом
#   limit    => 10,   - количество записей
#   offset   => 0,    - смещение от начала списка
#   mode     => 'full'- список с базовыми данными, если указать 'full' (опция необязательна по)
# }
sub _get_list {
    my ( $self, $data ) = @_;

    my ( $sql, $fields, $sth, $usr, @list );
    my $list = {};

    push @!, "no data for list" unless ( $$data{'group_id'} );

    unless ( @! ) {
        # выбираемые поля
        $fields = ' id, login, publish AS status, email, phone, eav_id, timezone ';

        # взять объекты из таблицы users
        unless ( defined $$data{'publish'} ) {
            $sql = 'SELECT grp.'. $fields . 'FROM "public"."user_groups" AS usr INNER JOIN "public"."users" AS grp ON grp."id" = usr."user_id" WHERE usr."group_id" = :group_id ORDER BY "id"';
        }
        elsif ( $$data{'publish'} ) {
            $sql = 'SELECT grp.'. $fields . 'FROM "public"."user_groups" AS usr INNER JOIN "public"."users" AS grp ON grp."id" = usr."user_id" WHERE usr."group_id" = :group_id AND grp."publish" = true ORDER BY "id"';
        }
        else {
            $sql = 'SELECT grp.'. $fields . 'FROM "public"."user_groups" AS usr INNER JOIN "public"."users" AS grp ON grp."id" = usr."user_id" WHERE usr."group_id" = :group_id AND grp."publish" = false ORDER BY "id"';
        }
        $sql .= ' LIMIT :limit' if $$data{'limit'};
        $sql .= ' OFFSET :offset' if $$data{'offset'};
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':group_id', $$data{'group_id'} );
        $sth->bind_param( ':limit', $$data{'limit'} ) if $$data{'limit'};
        $sth->bind_param( ':offset', $$data{'offset'} ) if $$data{'offset'};
        $sth->execute();
        $list = $sth->fetchall_arrayref({});
        $sth->finish();

        if ( ref($list) eq 'ARRAY' ) {
            if ( $$data{'mode'} ) {
                foreach ( @$list ) {
                    $usr = Freee::EAV->new( 'User', { 'id' => $_->{'eav_id'} } );
                    $_->{'name'}          = $usr->name()          ? $usr->name() : '';
                    $_->{'patronymic'}    = $usr->patronymic()    ? $usr->patronymic() : '';
                    $_->{'surname'}       = $usr->surname()       ? $usr->surname() : '';
                    $_->{'birthday'}      = $usr->birthday()      ? $usr->birthday() : '';
                    $_->{'import_source'} = $usr->import_source() ? $usr->import_source() : '';
                    $_->{'country'}       = $usr->country()       ? $usr->country() : '';
                    $_->{'place'}         = $usr->place()         ? $usr->place() : '';
                    $_->{'phone'}         = $_->{'phone'}         ? $_->{'phone'} : '';
                }
            }
        }
    }

    return $list;
}

# Получить данные пользователя из EAV и таблицы users
# ( $result ) = $self->model('User')->_get_user( $data );
# $data = {
# id - Id пользователя
# }
# $result = {
#     'place'         => 'place',                         # берется из EAV
#     'country'       => 'country',                       # берется из EAV
#     'birthday'      => '1972-01-06 00:00:00',           # берется из EAV
#     'surname'       => 'test',                          # берется из EAV
#     'name'          => 'name',                          # берется из EAV
#     'patronymic'    => 'patronymic',                    # берется из EAV
#     'import_source' => 'https://exist.com/image',       # берется из EAV
#     'email'         => 'test@test.com',                 # берется из users
#     'phone'         => '+7(999) 222-2222',              # берется из users
#     'password'      => 'password',                      # берется из users
#     'timezone'      => '10',                            # берется из users
#     'publish'       => true,                            # берется из users
#     'groups'        => [1]                              # берется из users
# }
sub _get_user {
    my ( $self, $data ) = @_;

    my ( $sth, $sql, $usr, $result, $eav_id );
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for get";
    }
    unless ( @! ) {
        # взять пользователей
        $sql = q(SELECT u.*, '[ ' || string_agg( g.group_id::varchar , ', ' ) || ' ]' AS "groups"
            FROM "users" AS u  
            INNER JOIN "user_groups" AS g ON g."user_id" = u."id"
            WHERE u."id" = :user_id
            GROUP BY u."id");
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':user_id', $$data{'id'} );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();
        push @!, "can't get user" unless $result;
    }

    unless ( @! ) {
        # взять весь объект из EAV
        $eav_id = $result->{'eav_id'};
        $usr = Freee::EAV->new( 'User', { 'id' => $eav_id } );
        if ( $usr ) {
            $result->{'id'}            = $result->{id};
            $result->{'name'}          = $usr->name()       ? $usr->name() : '';
            $result->{'patronymic'}    = $usr->patronymic() ? $usr->patronymic() : '';
            $result->{'surname'}       = $usr->surname()    ? $usr->surname() : '';
            $result->{'birthday'}      = $usr->birthday()   ? $usr->birthday() : '';
            $result->{'import_source'} = $usr->import_source();
            $result->{'country'}       = $usr->country()    ? $usr->country() : '';
            $result->{'place'}         = $usr->place()      ? $usr->place() : '';
            $result->{'phone'}         = $result->{'phone'} ? $result->{'phone'} : '';
        }
        else {
            push @!, "object with eav_id $$data{'id'} doesn't exist";
        }
    }
    return $result;
}

# проверка существования пользователя
# my $true = $self->model('User')->_exists_in_users( $login, $pass} );
# передаем
# $login   - логин пользователя
# $pass    - пароль пользователя
# получаем
# {
#     'eav_id'        4,
#     'email'         "admin@admin",
#     'groups'        "[ 'admin' ]",
#     'id'            1,
#     'login'         "admin",
#     'phone'         undef,
#     'status'        1,
#     'time_access'   "2020-09-11 02:33:27.102561+03",
#     'time_create'   "2020-09-11 02:33:27.102561+03",
#     'time_update'   "2020-09-11 02:33:27.102561+03",
#     'timezone'      3
# }
sub _exists_in_users {
    my ( $self, $login, $pass ) = @_;

    my ($sql, $sth, $row);

    if ( $login && $pass ) {
        # ищем пользователя
        $sql = q(SELECT u.*, '[ ' || string_agg( g.group_id::varchar , ', ' ) || ' ]' AS "groups" FROM "users" AS u  
            INNER JOIN "user_groups" AS g ON g."user_id" = u."id" 
            WHERE u."login"  = :login AND u."password"  = :password
            GROUP BY u."id");
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':login', $login );
        $sth->bind_param( ':password', $pass);
        $sth->execute();
        $row = $sth->fetchall_hashref('login');
        $sth->finish();

        if ( ref($row) eq 'HASH' && keys %$row && !@! ) {
            if (keys %$row == 1) {
                $$row{$login}{'status'} = $$row{$login}{'publish'} ? 1 : 0;
                delete $$row{$login}{'publish'};
                return $$row{$login};
            }
            else {
                push @!, "Exists more then one user";
            }
        }
        else {
            push @!, "User not exists";
        }
    }
    else {
        push @!, "Empty login or password in 'users' table";
    }

    return 0;
}
# Добавлением пустой объект пользователя в EAV и таблицу users
# ( $user_id ) = $self->model('User')->_empty_user();
sub _empty_user {
    my ( $self ) = @_;

    my ( $sth, $user, $user_id, $eav_id, $data, $result, $sql, $unaproved, $parent );

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # получаем id группы unaproved
    $sql = 'SELECT * FROM "public"."groups" WHERE "name" = \'unaproved\'';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $unaproved = $sth->fetchrow_hashref();
    $sth->finish();

    unless ( (ref($unaproved) eq 'HASH') && $$unaproved{id} ) {
        push @!, 'Could not get Groups';
        $self->{'app'}->pg_dbh->rollback;
        return;
    }

    # Получаем id User сета
    # $parent = 

    # делаем запись в EAV
    my $eav = {
        'parent' => 1, 
        'title'  => 'New user',
        'User' => {
            'parent'       => 1, 
            'surname'      => '',
            'name'         => '',
            'patronymic'   => '',
            'place'        => '',
            'country'      => 'RU',
            'birthday'     => strftime( "%F %T", localtime() ),
            'import_source'=> '',
            'status'       => \0
        }
    };
    $user = Freee::EAV->new( 'User', $eav );
    $eav_id = $user->id();

    my $timezone = strftime( "%z", localtime() ) / 100;
    $data = {
        'status'   => 0,
        'email'     => '',
        'phone'     => '',
        'password'  => '',
        'eav_id'    => $eav_id,
        'timezone'  => $$data{'timezone'} ? $$data{'timezone'} : $timezone
    };
    unless ( $$data{'eav_id'} ) {
        push @!, "Could not insert user into EAV";
        $self->{'app'}->pg_dbh->rollback;
        return;
    }

    unless ( @! ) {
##### потом добавить заполнение поля users_flags ???????????????????????????????????????????????????????
        # запись данных в users
        $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ( '.join( ',', map { ':'.$_ } keys %$data ).' )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        foreach ( keys %$data ) {
            my $type = /status/ ? SQL_BOOLEAN : undef();
            $sth->bind_param( ':'.$_, $$data{$_}, $type );
        }
        $sth->execute();
        $sth->finish();

        $user_id = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'users_id_seq' } );
        $sth->finish();

        unless ( $user_id ) {
            push @!, "Can not insert 'New user' into users table ". DBI->errstr;
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    #### заполнение таблицы user_groups
    unless ( @! ) {
        $sql = 'INSERT INTO "public"."user_groups" ( "user_id", "group_id" ) VALUES ( :user_id, :group_id )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':user_id', $user_id );
        $sth->bind_param( ':group_id', $$unaproved{id} );
        $result = $sth->execute();
        $sth->finish();

        unless ( $result ) {
            push @!, "Can not insert into 'user_groups'";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $user_id, $eav_id;
}

# сохранение данных о пользователе
# $result = $self->model('User')->_save_user( $data );
# $data = {
#     'id'                => 1,
#     'surname'           => 'Фамилия',            # Фамилия
#     'name'              => 'Имя',                # Имя
#     'patronymic'        => 'Отчество',           # Отчество
#     'city'              => 'Санкт-Петербург',    # город
#     'country'           => 'Россия',             # страна
#     'timezone'          => '+3',                 # часовой пояс
#     'birthday'          => '1972-01-06 00:00:00',# дата рождения
#     'login'             => 'username@ya.ru',     # email пользователя
#     'email'             => 'login',              # login пользователя
#     'emailconfirmed'    => 1/0,                  # email подтвержден
#     'phone'             => 79312445646,          # номер телефона
#     'phoneconfirmed'    => 1/0,                  # телефон подтвержден
#     'status'            => 1/0,                  # активный / не активный пользователь
#     'groups'            => [1, 2, 3],            # список ID групп
#     'password'          => 'khasdf',             # хеш пароля
#     'avatar'            => 'https://thispersondoesnotexist.com/image'
# };
sub _save_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql, $groups, @user_keys );

    unless ( $$data{'id'} ) {
        push @!, 'no data for save';
    }

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # загружаем аватарку
    # таблица media (аватарка)
    my $media_data = {
        "path"          => 'local',
        "filename"      => 'local',
        "title"         => 'Название файла',
        "size"          => 'local',
        "mime"          => 'local',
        "description"   => 'local',
        "order"         => 'local',
        "flags"         => 0
    };

    # выгребаем 'eav_id', если его не передали
    unless ( $$data{'eav_id'} ) {
        $sql = 'SELECT eav_id FROM "public"."users" WHERE "id" = :id';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $sth->execute();
        my $row = $sth->fetchrow_hashref();
        $sth->finish();
        $$data{'eav_id'} = $$row{'eav_id'}
    }

    unless ( @! ) {
        # обновление полей в users
        $sql = 'UPDATE "public"."users" SET ' .
            join( ', ', map { 
                my $val;
                if ( /status/ ) {
                    # $val = $$data{'data_user'}{$_};
                    $val = $$data{'data_user'}{$_} ? 't' : '';
                }
                else {
                    $val = $self->{'app'}->pg_dbh->quote( $$data{'data_user'}{$_} );
                }
                "\"$_\" = " . $val
            } keys %{ $$data{'data_user'} } ) . ' WHERE "id" = :id';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        if ( $result eq '0E0' ) {
            push @!, "can't update $$data{'id'} in users";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    unless ( @! ) {
        $$data{'data_eav'}{'title'} = join(
            ' ', ( $$data{'data_eav'}{'surname'}, $$data{'data_eav'}{'name'}, $$data{'data_eav'}{'patronymic'} )
        );

        # обновление полей в EAV
        $usr = Freee::EAV->new( 'User', {
            'id'      => $$data{'eav_id'},
            'parent'  => 0
        });
warn Dumper('save model');

        $result = $usr->_MultiStore( {                 
            'User' => {
                'title'        => $$data{'data_eav'}{'title'},
                'surname'      => $$data{'data_eav'}{'surname'},
                'name'         => $$data{'data_eav'}{'name'},
                'patronymic'   => $$data{'data_eav'}{'patronymic'},
                'place'        => $$data{'data_eav'}{'place'},
                'country'      => $$data{'data_eav'}{'country'},
                'birthday'     => $$data{'data_eav'}{'birthday'},
                'import_source'=> $$data{'data_eav'}{'avatar'},
            }
        });

        unless ( $result ) {
            push @!, "can't update EAV";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    # таблица users_social
    # my $user_data = {
    #     "user_id" int4 NOT NULL,
    #     "social" "public"."social" NOT NULL,
    #     "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
    #     "social_id",     => 123123123,
    #     "social_profile" => "{}"
    # };

    unless ( @! ) {
        $sql = 'DELETE FROM "public"."user_groups" WHERE "user_id" = :user_id RETURNING "user_id"';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':user_id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();
    }

    unless ( @! ) {
        # добавление в user_groups
        $groups = decode_json( $$data{'groups'} );
        $sql = 'INSERT INTO "public"."user_groups" ( "user_id", "group_id" ) VALUES ( :user_id, :group_id ) RETURNING user_id';

        foreach my $group_id ( @$groups ) {
            $sth = $self->{'app'}->pg_dbh->prepare( $sql );
            $sth->bind_param( ':user_id', $$data{'id'} );
            $sth->bind_param( ':group_id', $group_id );
            $sth->execute();
            $result = $sth->fetchrow_array();
            $sth->finish();
            unless ( $result ) {
                push @!, "Can not update 'user_groups'";
                $self->{'app'}->pg_dbh->rollback;
                return;
            }
        }
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $result;
}

# изменение поля на 1/0
# my $true = $self->toggle( $data );
# $data = {
#     'id'    - id записи 
#     'field' - имя поля в таблице
#     'val'   - 1/0
# }
sub _toggle_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql );

    unless ( $$data{'id'} && defined $$data{'value'} ) {
        push @!, 'no data for toggle';
    }

    unless ( @! ) {
        # смена значений publish (EAV меняется триггером)
        $sql = 'UPDATE "public"."users" SET "publish" = :publish WHERE "id" = :id';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':publish', $$data{'value'} ? 't' : '' );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();
        push @!, "user with '$$data{'id'}' doesn't exist" if $result eq '0E0';
    }

    return $result;
}

# удаление пользователя
# $result = $self->model('User')->_delete_user( $data );
# $data = {
#     id => <Id> пользователя
# }
sub _delete_user {
    my ( $self, $data ) = @_;

    my ( $sth, $eav_id, $usr, $result, $sql );

    unless ( $$data{'id'} ) {
        push @!, 'no data for delete';
    }

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    unless ( @! ) {
        # для полного удаления получаем 'eav_id'
        $sql = 'SELECT eav_id FROM "public"."users" WHERE "id" = :id';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $sth->execute();
        $eav_id = $sth->fetchrow_hashref();
        $sth->finish();

        # удаление из users
        $sql = 'DELETE FROM "public"."users" WHERE "id" = :id RETURNING "id"';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        if ( ! defined $result || $result eq '0E0') {
            push @!, "Error by delete '$$data{'id'}' from users";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    unless ( @! && !$$eav_id{'eav_id'} ) {
        # удаление из EAV
        $usr = Freee::EAV->new( 'User', { 'id' => $$eav_id{'eav_id'} } );
        $result = $usr->_RealDelete();

        unless ($result) {
            push @!, "can't delete from EAV '$$eav_id{'eav_id'}'";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    unless ( @! ) {
        # удаление из user_groups
        $sql = 'DELETE FROM "public"."user_groups" WHERE "user_id" = :user_id RETURNING "user_id"';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':user_id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        if ( ! defined $result ) {
            push @!, "Could not delete '$$data{'id'}' from user_groups";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    # открываем транзакцию
    $self->{'app'}->pg_dbh->commit;

    return $result;
}

# проверка существования пользователя
# my $true = $self->model('User')->_exists_in_user( $$data{'parent'} );
# 'id'    - id пользователя
sub _exists_user_in_EAV {
    my ( $self, $id ) = @_;

    my ( $user, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $user = Freee::EAV->new( 'User', { 'id' => $id } );
    }

    return $user ? 1 : 0;
}

1;