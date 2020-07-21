package Freee::Model::User;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

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

    my ( $sth, $sql, $result, $error, @mess );

    unless ( $$data{'email'} || $$data{'phone'} ) {
        push @mess, 'no data for check';
    }

    unless ( @mess ) {
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
                    push @mess, "$_ '$$data{ $_ }' already used";
                }
            }
        }
    }

    if ( @mess ) {
        return( undef, join( "\n", @mess ) )
    }

    return 1;
}

sub _get_list {
    my ( $self, $data ) = @_;

    my ( $sql, $fields, $sth, $list, $mess, @list, @mess );

    unless ( $$data{'id'} ) {
        push @mess, "no data for list";
    }

    unless ( @mess ) {
        # выбираемые поля
        $fields = ' id, publish, email, phone, password, eav_id, timezone, groups ';

        # взять объекты из таблицы users
        unless ( defined $$data{'status'} ) {
            $sql = 'SELECT' . $fields . 'FROM "public"."users" WHERE "groups" LIKE ? OR "groups" LIKE ? OR "groups" LIKE ? OR "groups" LIKE ?';
        }
        elsif ( $$data{'status'} ) {
            $sql = 'SELECT' . $fields . 'FROM "public"."users" WHERE ( "groups" LIKE ? OR "groups" LIKE ? OR "groups" LIKE ? OR "groups" LIKE ? ) AND "publish" = TRUE';
        }
        else {
            $sql = 'SELECT' . $fields . 'FROM "public"."users" WHERE ( "groups" LIKE ? OR "groups" LIKE ? OR "groups" LIKE ? OR "groups" LIKE ? ) AND "publish" = FALSE';
        }
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, '%[' . $$data{'id'} . ']%' );
        $sth->bind_param( 2, '%[' . $$data{'id'} . ',%' );
        $sth->bind_param( 3, '%' .  $$data{'id'} . ',%' );
        $sth->bind_param( 4, '%' .  $$data{'id'} . ']%' );
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

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $list, $mess;
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
    # };

    # return $data;

    my ( $sth, $sql, $usr, $result_users, $result_eav, $main, $contacts, $password, $groups, $mess, @mess );
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @mess, "no data for get";
    }

    unless ( @mess ) {
        # взять весь объект из таблицы users
        $sql = 'SELECT * FROM "public"."users" WHERE "id" = ?';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $result_users = $sth->fetchrow_hashref();
        if ( $result_users ) {
    ### ???????????????????????????????????????????????????????????????????????? contacts - emailconfirmed phoneconfirmed ?
            $contacts = [
               {"email"          => $$result_users{'email'} },
               {"emailconfirmed" => 1 },
               {"phone"          => $$result_users{'phone'} },
               {"phoneconfirmed" => 1 }
            ];

            $password = [
               {"password"       => $$result_users{'password'} },
               {"newpassword"    => $$result_users{'password'} }
            ];

            $groups = [
               { "groups" => $$result_users{'groups'} }
            ]
        }
        else {
            push @mess, "can't get object from users";
        }
    }

    unless ( @mess ) {
        # взять весь объект из EAV
        $usr = Freee::EAV->new( 'User', { 'id' => $$data{'id'} } );

        $result_eav = $usr->_getAll();
        if ( $result_eav ) {
            $main = [
               {"name"       => $$result_eav{'name'} },
               {"patronymic" => $$result_eav{'patronymic'} },
               {"surname"    => $$result_eav{'surname'} },
               {"birthday"   => $$result_eav{'birthday'} },
               {"avatar"     => $$result_eav{'import_source'} },
               {"country"    => $$result_eav{'country'} },
               {"place"      => $$result_eav{'place'} },
               {"status"     => $$result_users{'publish'} ? 1 : 0 },
               {"timezone"   => $$result_users{'timezone'} },
               {"type"       => $$result_eav{'Type'} }
            ]
        }
        else {
            push @mess, "can't get object from EAV";
        }
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $main, $contacts, $password, $groups, $mess;
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

    my ( $sth, $user, $result, $mess, $sql, @mess, @user_keys );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @mess, "no data for insert";
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
    unless ( @mess) {
        # делаем запись в EAV
        $$data{'title'} = join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) );

        $user = Freee::EAV->new( 'User',
            {
                'parent' => 1, 
                'title' => $$data{'title'},
                'User' => {
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
            push @mess, "Could not insert user into EAV";
        }
    }

    unless ( @mess ) {
##### потом добавить заполнение поля users_flags ???????????????????????????????????????????????????????

        # запись данных в users
        @user_keys = ( "publish", "email", "phone", "password", "eav_id", "time_create", "time_access", "time_update", "timezone", "groups" );
        $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} @user_keys ).') VALUES ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } @user_keys ).')';

        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();

        $result = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'users_id_seq' } );
        push @mess, "Can not insert $$data{'title'} into users" unless $result;

        # таблица users_social
        # my $user_data = {
        #     "user_id" int4 NOT NULL,
        #     "social" "public"."social" NOT NULL,
        #     "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
        #     "social_id",     => 123123123,
        #     "social_profile" => "{}"
        # };
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

sub _save_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $mess, $sql, @user_keys, @mess );

    unless ( $$data{'id'} ) {
        push @mess, 'no data for save';
    }

    unless ( @mess ) {
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

        push @mess, "can't update $$data{'id'}" if $result eq '0E0';
    }

    unless ( @mess ) {
        $$data{'title'} = join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) );

        # обновление полей в EAV
        # $usr = Freee::EAV->new( 'User' );
        $usr = Freee::EAV->new( 'User',
            {
                'id'      => $$data{'id'},
                'parent'  => 1
            }
        );
        # $result = $usr->surname( $$data{'surname'} );
        # $result = $usr->name( $$data{'name'} );
        # $result = $usr->title( $$data{'title'} );
# warn Dumper { 'User' => $data };

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

        push @mess, "can't update EAV" unless $result;
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

sub _toggle_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $mess, $sql, @mess );

    unless ( $$data{'id'} && defined $$data{'status'} ) {
        push @mess, 'no data for toggle';
    }

    unless ( @mess ) {
        # смена значений publish
        $sql = 'UPDATE "public"."users" SET "publish" = ? WHERE "id" = ?';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'status'} );
        $sth->bind_param( 2, $$data{'id'} );

        $result = $sth->execute();
        push @mess, "user with '$$data{'id'}' doesn't exist" if $result eq '0E0';
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

sub _delete_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $mess, $sql, @mess );

    unless ( $$data{'id'} ) {
        push @mess, 'no data for delete';
    }

    unless ( @mess ) {
        # удаление из users
        $sql = 'DELETE FROM "public"."users" WHERE "id" = ? RETURNING "id"';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );

        $result = $sth->execute();

        push @mess, "could not delete '$$data{'id'}'" if $result eq '0E0';
    }

    unless ( @mess ) {
        # удаление из EAV
        $usr = Freee::EAV->new( 'User', { 'id' => $$data{'id'} } );
        $result = $usr->_RealDelete();

        push @mess, "can't delete from EAV" unless $result;
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}
1;