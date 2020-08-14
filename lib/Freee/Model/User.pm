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

# Проверка наличия пользователя в таблице users
# ( $result, $error ) = $self->model('User')->_check_user( $data );
# $data = {
#     'email'       => 'test@test.com',
#     'phone'       => '+7(999) 222-2222'
# }
# возвращает данные пользователя или undef:
# $data = {
#     'id'          => 1,                               # берется из users
#     'email'       => 'test@test.com',                 # берется из users
#     'eav_id'      => 1,                               # берется из users
#     'phone'       => '+7(999) 222-2222',              # берется из users
#     'password'    => 'password',                      # берется из users
#     'timezone'    => '10'                             # берется из users
#     'time_create' => '2020-06-27 22:16:27.874726+03', # берется из users
#     'time_access' => '2020-06-27 22:16:27.874726+03', # берется из users
#     'time_update' => '2020-06-27 22:16:27.874726+03'  # берется из users
# }
# не нужен??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
sub _check_user {
    my ( $self, $data ) = @_;

    # my ( $sth, $dbh, $result, $mess, $user, $value, @mess );
    # if ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
    #     my $usr = Freee::EAV->new( 'User' );
    #     my $list = $usr->_list( $dbh, { Filter => { 'User.surname' => $value } } );
    #     # взять нужное поле
    #     $user = {
    #         surname     => $usr->surname(),
    #         name        => $usr->name(),
    #         patronymic  => $usr->patronymic(),
    #         place       => $usr->place(),
    #         country     => $usr->country(),
    #         birthday    => $usr->birthday()
    #     };
    # }
    # else {
    # }
    # return $user;
    # my $usr = Freee::EAV->new( 'User' );
    # my $user = $usr->_getAll();
    # my $list = $usr->_list();
        # my $list = $usr->_list( $dbh, { Filter => { 'User.surname' => $value } } );

    my ( $sth, $sql, $result );

    unless ( $$data{'email'} || $$data{'phone'} ) {
        push @!, 'no data for check';
    }

    unless ( @! ) {
        foreach ( 'email', 'phone' ) {
            if ( $$data{ $_ } ) {
                if ( $$data{'id'} ) {
                    $sql = 'SELECT "id" FROM "public"."users" WHERE' . "\"$_\"" . '=' . "'$$data{ $_ }'" . ' EXCEPT SELECT "id" FROM "public"."users" WHERE "id" = ' . $$data{'id'};
                }
                else {
                    $sql = 'SELECT "id" FROM "public"."users" WHERE' . "\"$_\"" . '=' . "'$$data{ $_ }'";
                }
                # $sql = 'SELECT "id" FROM "public"."users" WHERE ? = ?';

                $sth = $self->{app}->pg_dbh->prepare( $sql );
                # $sth->bind_param( 1, $_ );
                # $sth->bind_param( 2, $$data{ $_ } );

                $result = $sth->execute();
                unless ( $result == '0E0' ) {
                    push @!, "$_ '$$data{ $_ }' already used";
                }
            }
        }
    }

    return @! ? 0 : 1;
}

sub _get_list {
    my ( $self, $data ) = @_;

    my ( $sql, $fields, $sth, $list, @list );

    unless ( $$data{'id'} ) {
        push @!, "no data for list";
    }

    unless ( @! ) {
        # выбираемые поля
        $fields = ' id, publish, email, phone, password, eav_id, timezone, groups ';

        # взять объекты из таблицы users
        unless ( defined $$data{'status'} ) {
            $sql = 'SELECT i.'. $fields . 'FROM "public"."user_groups" AS l INNER JOIN "public"."users" AS i ON i."id" = l."user_id" WHERE l."group_id" = ?';
        }
        elsif ( $$data{'status'} ) {
            $sql = 'SELECT i.'. $fields . 'FROM "public"."user_groups" AS l INNER JOIN "public"."users" AS i ON i."id" = l."user_id" WHERE l."group_id" = ? AND i."publish" = true';
        }
        else {
            $sql = 'SELECT i.'. $fields . 'FROM "public"."user_groups" AS l INNER JOIN "public"."users" AS i ON i."id" = l."user_id" WHERE l."group_id" = ? AND i."publish" = false';
        }
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $list = $sth->fetchall_hashref('id');

        if ( $list ) {
            foreach ( sort keys %$list ) {
                $list->{ $_ }->{'status'} = delete $list->{ $_ }->{'publish'} ? 1 : 0;
                push @list, $$list{ $_ };
            }
            $list = \@list;
        }
    }

    return $list;
}
# Получить все данные пользователя из EAV и таблицы users
# ( $result, $error ) = $self->model('User')->_get_user( $data );
# $data = {
#     'id'          => 1,                               # берется из users
#     'place'       => 'place',                         # берется из EAV
#     'country'     => 'country',                       # берется из EAV
#     'birthday'    => '1972-01-06 00:00:00',           # берется из EAV
#     'surname'     => 'test',                          # берется из EAV
#     'name'        => 'name',                          # берется из EAV
#     'patronymic'  => 'patronymic',                    # берется из EAV
#     'email'       => 'test@test.com',                 # берется из users
#     'eav_id'      => 1,                               # берется из users
#     'phone'       => '+7(999) 222-2222',              # берется из users
#     'password'    => 'password',                      # берется из users
#     'timezone'    => '10'                             # берется из users
#     'time_create' => '2020-06-27 22:16:27.874726+03', # берется из users
#     'time_access' => '2020-06-27 22:16:27.874726+03', # берется из users
#     'time_update' => '2020-06-27 22:16:27.874726+03'  # берется из users
# }
sub _get_user {
    my ( $self, $data ) = @_;

    my ( $sth, $sql, $usr, $result_users, $result_eav );
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for get";
    }

    unless ( @! ) {
        # взять весь объект из таблицы users
        $sql = 'SELECT * FROM "public"."users" WHERE "id" = ?';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $result_users = $sth->fetchrow_hashref();
        push @!, "can't get object from users" unless $result_users;
    }

    unless ( @! ) {
        # взять весь объект из EAV
        $usr = Freee::EAV->new( 'User', { 'id' => $$data{'id'} } );

        $result_eav = $usr->_getAll();
        push @!, "can't get object from EAV" unless $result_eav;
    }

    return $result_users, $result_eav;
}

# Добавлением нового пользователя в EAV и таблицу users
# ( $result, $error ) = $self->model('User')->_insert_user( $data );
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
    unless ( @!) {
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
                    'date_updated' => $$data{'time_update'},
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
        @user_keys = ( "publish", "email", "phone", "password", "eav_id", "time_create", "time_access", "time_update", "timezone", "groups" );
        $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} @user_keys ).') VALUES ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } @user_keys ).')';

        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();

        $user_id = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'users_id_seq' } );
        push @!, "Can not insert $$data{'title'} into users" unless $user_id;

        # таблица users_social
        # my $user_data = {
        #     "user_id" int4 NOT NULL,
        #     "social" "public"."social" NOT NULL,
        #     "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
        #     "social_id",     => 123123123,
        #     "social_profile" => "{}"
        # };
    }

    #### зеполнение таблицы user_groups
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

    return $user_id;
}

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
            $$data{'password'} = $$data{'newpassword'};
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
        # $usr = Freee::EAV->new( 'User' );
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

sub _toggle_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql );

    unless ( $$data{'id'} && defined $$data{'status'} ) {
        push @!, 'no data for toggle';
    }

    unless ( @! ) {
        # смена значений publish
        $sql = 'UPDATE "public"."users" SET "publish" = ? WHERE "id" = ?';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'status'} );
        $sth->bind_param( 2, $$data{'id'} );

        $result = $sth->execute();
        push @!, "user with '$$data{'id'}' doesn't exist" if $result eq '0E0';
    }

    return $result;
}

sub _delete_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $sql );

    unless ( $$data{'id'} ) {
        push @!, 'no data for delete';
    }

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