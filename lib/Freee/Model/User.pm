package Freee::Model::User;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;
use Mojo::JSON qw( from_json );

###################################################################
# Поля пользователя
####################################################################
# поля которые лежат в EAV
my %eav_fields = (
    'surname'     => 1,
    'name'        => 1,
    'patronymic'  => 1,
    'place'       => 1,
    'country'     => 1,
    'birthday'    => 1
);

# поля которые лежат в таблице users
my %users_fields = (
    'id'            => 1,
    'email'         => 1,
    'phone'         => 1,
    'password'      => 1,
    'eav_id'        => 1,
    'time_create'   => 1,
    'time_access'   => 1,
    'time_update'   => 1,
    'timezone'      => 1
);

# поля которые лежат в таблице users_social
my %social_fields = (
    'user_id'        => 1,
    'social'         => 1,
    'access_token'   => 1,
    'social_id'      => 1,
    'social_profile' => 1
);

# поля которые лежат в таблице users_masks
my %masks_fields = (
    'user_id' => 1,
    'key'     => 1,
    'mask'    => 1
);


###################################################################
# Пользователи
###################################################################

# список юзеров по группам (обязательно id группы)
# $result = $self->model('User')->_get_list( $data );
# $data = {
# id - Id группы
# status - показывать группы только с этим статусом
# }
sub _get_list {
    my ( $self, $data ) = @_;

    my ( $sql, $fields, $sth, $list, @list );

    push @!, "no data for list" unless ( $$data{'id'} );

    unless ( @! ) {
        # выбираемые поля
        my $masks_fields;
        $fields = ' id, publish, email, phone, eav_id, timezone, groups ';

        # взять объекты из таблицы users
        unless ( defined $$data{'status'} ) {
            $sql = 'SELECT grp.'. $fields . 'FROM "public"."user_groups" AS usr INNER JOIN "public"."users" AS grp ON grp."id" = usr."user_id" WHERE usr."group_id" = ?';
        }
        elsif ( $$data{'status'} ) {
            $sql = 'SELECT grp.'. $fields . 'FROM "public"."user_groups" AS usr INNER JOIN "public"."users" AS grp ON grp."id" = usr."user_id" WHERE usr."group_id" = ? AND grp."publish" = true';
        }
        else {
            $sql = 'SELECT grp.'. $fields . 'FROM "public"."user_groups" AS usr INNER JOIN "public"."users" AS grp ON grp."id" = usr."user_id" WHERE usr."group_id" = ? AND grp."publish" = false';
        }
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();
        $list = $sth->fetchall_hashref('id');

        if ( ref($list) eq 'HASH' ) {
            foreach ( sort keys %$list ) {
                $list->{ $_ }->{'password'} = '';
                $list->{ $_ }->{'status'} = $list->{ $_ }->{'publish'} ? 1 : 0;
                delete $list->{ $_ }->{'publish'};
                push @list, $$list{ $_ };
            }
            $list = \@list;
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

    my ( $sth, $sql, $usr, $result );
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for get";
    }

    unless ( @! ) {
        # взять весь объект из таблицы users
        $sql = 'SELECT publish, email, phone, password, timezone, groups FROM "public"."users" WHERE "id" = ?';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $result = $sth->fetchrow_hashref();
        push @!, "can't get object from users" unless $result;
    }

    unless ( @! ) {
        # взять весь объект из EAV
        $usr = Freee::EAV->new( 'User', { 'id' => $$data{'id'} } );
        if ( $usr ) {
            $result->{'id'}            = $usr->id();
            $result->{'name'}          = $usr->name();
            $result->{'patronymic'}    = $usr->patronymic();
            $result->{'surname'}       = $usr->surname();
            $result->{'birthday'}      = $usr->birthday();
            $result->{'import_source'} = $usr->import_source();
            $result->{'country'}       = $usr->country();
            $result->{'place'}         = $usr->place();
        }
        else {
            push @!, "object with id 'data{'id'} doesn't exist";
        }
    }

    return $result;
}

# Добавлением нового пользователя в EAV и таблицу users
# ( $user_id ) = $self->model('User')->_insert_user( $data );
# $data = {
#     'place'       => 'place',                         # кладется в EAV
#     'country'     => 'country',                       # кладется в EAV
#     'birthday'    => '1972-01-06 00:00:00',           # кладется в EAV
#     'surname'     => 'test',                          # кладется в EAV
#     'name'        => 'name',                          # кладется в EAV
#     'patronymic'  => 'patronymic',                    # кладется в EAV
#     'email'       => 'test@test.com',                 # кладется в users
#     'phone'       => '+7(999) 222-2222',              # кладется в users
#     'password'    => 'password',                      # кладется в users
#     'timezone'    => '10',                            # кладется в users
# }
sub _insert_user {
    my ( $self, $data ) = @_;

    my ( $sth, $user, $user_id, $result, $sql, $groups, @user_keys );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    # открытие транзакции

            # загружаем аватарку
            # таблица media (аватарка)
#             my $media_data = {
#                 "path"      => 'local',
#                 "filename"  => 'local',
#                 "title"     => 'Название файла',
#                 "size"      => 'local',
# #?                "type" varchar(32) COLLATE "default",
#                 "mime"      => 'local',
#                 "description"      => 'local',
#                 "order"      => 'local',
#                 "flags"     => 0
#             };
    unless ( @! ) {
        # делаем запись в EAV
        $$data{'title'} = join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) );

        $user = Freee::EAV->new( 'User',
            {
                'parent' => 0, 
                'title' => $$data{'title'},
                'User' => {
                    'parent'       => 0, 
                    'surname'      => $$data{'surname'},
                    'name'         => $$data{'name'},
                    'patronymic'   => $$data{'patronymic'},
                    'place'        => $$data{'place'},
                    'country'      => $$data{'country'},
                    'birthday'     => $$data{'birthday'},
                    'import_source'=> $$data{'avatar'},
                    'publish'      => $$data{'publish'}
                }
            }
        );
        $$data{'eav_id'} = $user->id();

        unless ( $$data{'eav_id'} ) {
            push @!, "Could not insert user into EAV";
        }
    }

    unless ( @! ) {
##### потом добавить заполнение поля users_flags ???????????????????????????????????????????????????????

        # запись данных в users
        @user_keys = ( "publish", "email", "phone", "password", "eav_id", "timezone", "groups" );
        $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} @user_keys ).') VALUES ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } @user_keys ).')';

        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();

        $user_id = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'users_id_seq' } );
        push @!, "Can not insert $$data{'title'} into users". DBI->errstr unless $user_id;

        # таблица users_social
        # my $user_data = {
        #     "user_id" int4 NOT NULL,
        #     "social" "public"."social" NOT NULL,
        #     "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
        #     "social_id",     => 123123123,
        #     "social_profile" => "{}"
        # };
    }

    #### заполнение таблицы user_groups
    unless ( @! ) {
        $groups = from_json( $$data{'groups'} );
        $sql = 'INSERT INTO "public"."user_groups" ( "user_id", "group_id" ) VALUES ( ?, ? )';

        foreach my $group_id ( @$groups ) {
            $sth = $self->{'app'}->pg_dbh->prepare( $sql );
            $sth->bind_param( 1, $user_id );
            $sth->bind_param( 2, $group_id );
            $result = $sth->execute();
            push @!, "Can not insert into 'user_groups'" unless $result;
        }
    }
# закрытвание транзакции 
# $self->{'app'}->pg_dbh

    return $user_id;
}

# сохранение данных о пользователе
# $result = $self->model('User')->_save_user( $data );
# $data = {
#     'id'                => 1,
#     'surname'           => 'Фамилия',           # Фамилия
#     'name'              => 'Имя',               # Имя
#     'patronymic'        => 'Отчество',          # Отчество
#     'city'              => 'Санкт-Петербург',   # город
#     'country'           => 'Россия',            # страна
#     'timezone'          => '+3',                # часовой пояс
#     'birthday'          => 123132131,           # дата рождения (в секундах)
#     'email'             => 'username@ya.ru',    # email пользователя
#     'emailconfirmed'    => 1,                   # email подтвержден
#     'phone'             => 79312445646,         # номер телефона
#     'phoneconfirmed'    => 1,                   # телефон подтвержден
#     'status'            => 1,                   # активный / не активный пользователь
#     'groups'            => [1, 2, 3],           # список ID групп
#     'password'          => 'khasdf',            # хеш пароля
#     'avatar'            => 'https://thispersondoesnotexist.com/image'
# };
sub _save_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql, $groups, @user_keys );

    unless ( $$data{'id'} ) {
        push @!, 'no data for save';
    }

    unless ( @! ) {
        # обновление полей в users
        @user_keys = ( "publish", "email", "phone", "time_access", "time_update", "timezone", "groups" );

        if ( $$data{'password'} ) {
            push @user_keys, 'password';
        }

        $sql = 'UPDATE "public"."users" SET ('.join( ',', map { "\"$_\""} @user_keys ).') = ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } @user_keys ).') WHERE "id" = ? RETURNING "id"';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );

        $result = $sth->execute();

        push @!, "can't update $$data{'id'} in users" if $result eq '0E0';
    }

    unless ( @! ) {
        $$data{'title'} = join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) );

        # обновление полей в EAV
        $usr = Freee::EAV->new( 'User',
            {
                'id'      => $$data{'id'},
                'parent'  => 0
            }
        );

        $result = $usr->_MultiStore( {                 
            'User' => {
                'title'   => $$data{'title'},
                'surname'      => $$data{'surname'},
                'name'         => $$data{'name'},
                'patronymic'   => $$data{'patronymic'},
                'place'        => $$data{'place'},
                'country'      => $$data{'country'},
                'birthday'     => $$data{'birthday'},
                'import_source'=> $$data{'avatar'},
                'date_updated' => $$data{'time_update'}
            }
        });

        push @!, "can't update EAV" unless $result;
    }

# ???????? решить проблему транзакцией
    unless ( @! ) {
        # удаление из user_groups
        $sql = 'DELETE FROM "public"."user_groups" WHERE "user_id" = ? RETURNING "user_id"';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $result = $sth->execute();
        push @!, "could not delete '$$data{'id'}' from user_groups" if $result eq '0E0';
    }

    unless ( @! ) {
        # добавление в user_groups
        $groups = from_json( $$data{'groups'} );
        $sql = 'INSERT INTO "public"."user_groups" ( "user_id", "group_id" ) VALUES ( ?, ? ) RETURNING user_id';

        foreach my $group_id ( @$groups ) {
            $sth = $self->{'app'}->pg_dbh->prepare( $sql );
            $sth->bind_param( 1, $$data{'id'} );
            $sth->bind_param( 2, $group_id );
            $sth->execute();
            $result = $sth->fetchrow_array();
            unless ( $result ) {
                push @!, "Can not update 'user_groups'";
                last;
            }
        }
    }

    return $result;
}

# изменение поля на 1/0
# my $true = $self->toggle( $data );
# $data = {
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
# }
sub _toggle_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql );

    unless ( $$data{'id'} && defined $$data{'status'} ) {
        push @!, 'no data for toggle';
    }

    unless ( @! ) {
        # смена значений publish (EAV меняется триггером)
        $sql = 'UPDATE "public"."users" SET "publish" = ? WHERE "id" = ?';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'status'} );
        $sth->bind_param( 2, $$data{'id'} );

        $result = $sth->execute();
        push @!, "user with '$$data{'id'}' doesn't exist" if $result eq '0E0';
    }

    return $result;
}

# удаление пользователя
# $result = $self->model('User')->_delete_user( $data );
# $data = {
# id - Id пользователя
# }
sub _delete_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql );

    unless ( $$data{'id'} ) {
        push @!, 'no data for delete';
    }
# ??? делать транзакцией
    unless ( @! ) {
        # удаление из users
        $sql = 'DELETE FROM "public"."users" WHERE "id" = ? RETURNING "id"';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );

        $result = $sth->execute();

        push @!, "could not delete '$$data{'id'}' from users" if $result eq '0E0';
    }

    unless ( @! ) {
        # удаление из EAV
        $usr = Freee::EAV->new( 'User', { 'id' => $$data{'id'} } );
        $result = $usr->_RealDelete();

        push @!, "can't delete from EAV" unless $result;
    }

    unless ( @! ) {
        # удаление из user_groups
        $sql = 'DELETE FROM "public"."user_groups" WHERE "user_id" = ? RETURNING "user_id"';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );

        $result = $sth->execute();

        push @!, "could not delete '$$data{'id'}' from user_groups" if $result eq '0E0';
    }

    return $result;
}

1;