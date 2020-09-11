package Freee::Model::Auth;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Предметы
###################################################################

# проверка существования пользователя
# my $true = $self->model('Auth')->_exists_in_users( $login, $pass} );
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
#     'publish'       1,
#     'time_access'   "2020-09-11 02:33:27.102561+03",
#     'time_create'   "2020-09-11 02:33:27.102561+03",
#     'time_update'   "2020-09-11 02:33:27.102561+03",
#     'timezone'      3
# }
sub _exists_in_users {
    my ( $self, $login, $pass ) = @_;

    my ($sql, $sth, $row);

    if ( $login && $pass ) {
        # ищем польщователя
        $sql = q(SELECT u.*, '[ ' || string_agg( g.group_id::varchar , ', ' ) || ' ]' AS "groups" FROM "users" AS u  
            INNER JOIN "user_groups" AS g ON g."user_id" = u."id" 
            WHERE u."login"  = :login AND u."password"  = :password 
            GROUP BY u."id");
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':login', $login );
        $sth->bind_param( ':password', $pass );
        $sth->execute();
        $row = $sth->fetchall_hashref('login');

        if ( ref($row) eq 'HASH' && keys %$row && !@! ) {
            if (keys %$row == 1) {
                # получаем список групп


                # выгребаем группу пользователя
                $sql = q(SELECT u.*, '[ ' || string_agg( g.group_id::varchar , ', ' ) || ' ]' AS "groups" FROM "users" AS u  
                    INNER JOIN "user_groups" AS g ON g."user_id" = u."id" 
                    WHERE u."login"  = :login AND u."password"  = :password 
                    GROUP BY u."id");
                $sth = $self->{app}->pg_dbh->prepare( $sql );
                $sth->bind_param( ':login', $login );
                $sth->bind_param( ':password', $pass );
                $sth->execute();
                $row = $sth->fetchall_hashref('login');

                unless ( @! ) {
                    return $$row{$login};
                }
                else {
                    push @!, "Can not get user groups";
                }
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

1;