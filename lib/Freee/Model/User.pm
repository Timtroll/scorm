package Freee::Model::User;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Поля пользователя
###################################################################
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
sub _check_user {
    my ( $self, $data ) = @_;

    my ( $sth, $usr, $result, $user, $mess, @mess );

    if ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {

        my $usr = Freee::EAV->new( 'User' );
        $list = $usr->_list( $dbh, { Filter => { 'user.surname' => $value } } );

        # взять нужное поле
        $user = {
            surname     => $usr->surname(),
            name        => $usr->name(),
            patronymic  => $usr->patronymic(),
            place       => $usr->place(),
            country     => $usr->country(),
            birthday    => $usr->birthday()
        };
        warn Dumper $user;
# warn $user->id();
# warn Dumper $user;
    }
    else {
        return;
    }

    return $user;
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

    my ( $sth, $result, $mess, @mess );

    if ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
warn '===========';
        # взять весь объект из EAV
        my $usr = Freee::EAV->new( 'User', { id => 2 } );
        my $user = $usr->_getAll();
warn Dumper $user;

        # взять весь объект из таблицы users

    }
    else {
        return;
    }

    return 1;
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

    my ( $sth, $result, $mess, @mess );

    # проверка входных данных
    if ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {

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

        foreach ("email", "phone", "password", "eav_id", "timezone") {
            if ( defined($$data{'email'}) ) {
                if ($$data{'email'}) {

                }
                else {

                }
            }
        }
        # делаем запись в EAV
        $$data{'title'} = join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) );
        my $user = Freee::EAV->new( 'User',
            {
                'publish' => \1,
                'parent' => 1, 
                'title' => $$data{'title'},
                'User' => {
                    'surname'   => $$data{'surname'},
                    'name'      => $$data{'name'},
                    'patronymic'=> $$data{'patronymic'},
                    'place'     => $$data{'place'},
                    'country'   => $$data{'country'},
                    'birthday'  => $$data{'birthday'}
                }
            }
        );
        my $eav_id = $user->id();

        if ($eav_id) {
##### потом добавить заполнение поля users_flags ???????????????????????????????????????????????????????
            # запись данных в users
            my $sql = 'INSERT INTO "public"."users" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).')';

            $sth->execute();

            $result = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'media_id_seq' } );
            push @mess, "Can not insert $$data{'title'}" unless $result;
warn "result = $result";

            # таблица users_social
            # my $user_data = {
            #     "user_id" int4 NOT NULL,
            #     "social" "public"."social" NOT NULL,
            #     "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
            #     "social_id",     => 123123123,
            #     "social_profile" => "{}"
            # };
        }
        else {
            push @mess, "Could not insert user into EAV";
        }
    }
    else {
        push @mess, "no data for insert";
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

1;