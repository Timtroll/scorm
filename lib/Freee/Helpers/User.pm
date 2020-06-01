package Freee::Helpers::User;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';
use Freee::EAV;

use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Upload

    # вводит данные о новом пользователе
    # my $true = $self->_insert_user( $data );
    # возвращает true/false
    $app->helper( '_insert_user' => sub {
        my ( $self, $data ) = @_;
        my ( $result, $mess, @mess );

#         # делаем запись в EAV
#         my $obj = { 
#             'publish' => $$data{'status'} ? \1 : \0, 
#             'parent' => 1 
#         };
# warn Dumper ( $obj );
#         my $user = Freee::EAV->new( 'User', $obj );
#         $user->StoreUser({
#             'title' => join(' ', ( $$data{'surname'}, $$data{'name'}, $$data{'patronymic'} ) ),
#             'User' => {
#                 'surname'       => $$data{'surname'},
#                 'name'          => $$data{'name'},
#                 'patronymic'    => $$data{'patronymic'},
#                 'city'          => $$data{'place'},
#                 'Country'       => $$data{'country'},
#                 'birthday'      => $$data{'birthday'},
#                 'phone'         => $$data{'phone'},
#                 'flags'         => 0,
#             }
#         });


        my $sth = $self->pg_dbh->prepare( 'INSERT INTO "public"."users" ("email", "password", "eav_id", "time_create", "time_access", "time_update", "timezone") VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING "id"' );
        $sth->bind_param( 1, $$data{'email'} );
        $sth->bind_param( 2, $$data{'password'} );
        $sth->bind_param( 3, 3 );
        $sth->bind_param( 4, $$data{'time_create'} );
        $sth->bind_param( 5, $$data{'time_access'} );
        $sth->bind_param( 6, $$data{'time_update'} );
        $sth->bind_param( 7, $$data{'timezone'} );
        $sth->execute();
        $result = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'users_id_seq' } );
        push @mess, "Can not insert user info into db" . DBI->errstr unless ( $result );


        # my $sth = $self->pg_dbh->prepare( 'INSERT INTO "public"."users" ("email", "password", "eav_id", "timezone") VALUES (?, ?, ?, ?) RETURNING "id"' );
        # $sth->bind_param( 1, $$data{'email'} );
        # $sth->bind_param( 2, $$data{'password'} );
        # $sth->bind_param( 3, $$data{'eav_id'} );
        # $sth->bind_param( 4, $$data{'timezone'} );

        # $result = $sth->execute();
        # push @mess, "Can not insert user info into db" . DBI->errstr unless ( $result );

        if ( @mess ) {
            $mess = join( "\n", @mess );
        }

        return $result, $mess;
    });
}

1;