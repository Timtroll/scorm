package Freee::Model::Reset;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

sub _reset {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );
    unless ( $$data{'email'} && $$data{'newpassword'} ) {
        push @!, 'no data for reset';
        return;
    }

    unless ( @! ) {
        # обновление пароля в users
        $sql = 'UPDATE "public"."users" SET "password" = :password WHERE "email" = :email';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':password', $$data{'newpassword'} );
        $sth->bind_param( ':email', $$data{'email'} );
        $result = $sth->execute();
        $sth->finish();

        if ( $result eq '0E0' ) {
            push @!, "can't update password in users";
            return;
        }
    }

    return 1;
}

1;