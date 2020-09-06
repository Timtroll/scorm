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
        $sql = 'SELECT id, login, password, groups FROM "public"."users" WHERE "login" = :login AND "password" = :password';

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