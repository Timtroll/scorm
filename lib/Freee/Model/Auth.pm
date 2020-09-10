package Freee::Model::Auth;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;
use DDP;

###################################################################
# Предметы
###################################################################

# проверка существования пользователя
# my $true = $self->model('Discipline')->_exists_in_users( $$data{'parent'} );
# 'id'    - id предмета
sub _exists_in_users {
    my ( $self, $login, $pass ) = @_;

    my ($sql, $sth, $row);

    if ( $login && $pass ) {
        $sql = q(SELECT u.*, '[ ' || string_agg( g.group_id::varchar , ', ' ) || ' ]' AS "groups"
            FROM "users" AS u  
            INNER JOIN "user_groups" AS g ON g."user_id" = u."id" 
            WHERE u."login"  = :login AND u."password"  = :password 
            GROUP BY u."id");
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':login', $login );
        $sth->bind_param( ':password', $pass );
        $sth->execute();
        $row = $sth->fetchall_hashref('login');

        if ( ref($row) eq 'HASH' && keys %$row ) {
            if (keys %$row == 1) {
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

1;