package Freee::Model::User;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Пользователи
###################################################################

# вводит данные о новом файле в таблицу media
# my $true = $self->model('Upload')->_insert_user( $data );
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

            # таблицы EAV
            # my $eav_data = {
            # };

            # делаем запись в EAV
# 1            $$data{'title'} = join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) );
#             my $user = Freee::EAV->new( 'User',
#                 {
#                     'publish' => \1,
#                     'parent' => 1, 
#                     'title' => $$data{'title'},
#                     'User' => {
#                         'surname'   => $$data{'surname'},
#                         'name'      => $$data{'name'},
#                         'patronymic'=> $$data{'patronymic'},
#                         'place'     => $$data{'place'},
#                         'country'   => $$data{'country'},
#                         'birthday'  => $$data{'birthday'}
#                     }
#                 }
#             );
#             my $id = $user->id();
# warn '===========';
my $id;

my $usr = Freee::EAV->new( 'User', { id => 2 } );
# взять веь объект
my $xx = $usr->_getAll();
warn Dumper $xx;
# взять нужное поле
my $yy = {
    surname     => $usr->surname(),
    name        => $usr->name(),
    patronymic  => $usr->patronymic(),
    place       => $usr->place(),
    country     => $usr->country(),
    birthday    => $usr->birthday()
};
warn Dumper $yy;
# warn $user->id();
# warn Dumper $user;

##### потом добавить заполнение поля flags ???????????????????????????????????????????????????????
            # запись данных в users
            my $sql = 'INSERT INTO "public"."users" ("email", "phone", "password", "eav_id", "timezone", "time_access", "time_update") VALUES (?, ?, ?, ?, ?, NOW(), NOW()) RETURNING "id"';
# warn $sql;
# warn Dumper $data;
            $sth = $self->{'app'}->pg_dbh->prepare( $sql );
            $sth->bind_param( 1, $$data{'email'} );
            $sth->bind_param( 2, $$data{'phone'} );
            $sth->bind_param( 3, $$data{'password'} );
            $sth->bind_param( 4, $id );
            $sth->bind_param( 5, $$data{'timezone'} );

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
        push @mess, "no data for insert";
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

1;