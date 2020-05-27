package Freee::EAV::User;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

use Data::Dumper;

sub StoreUser {
    my ( $self, $params ) = @_;

    return undef() unless $self->{_item};
    return undef() unless defined( $params );

    my $dataset = {};
    foreach my $key ( keys %$params ) {
        if ( ref( $params->{ $key } ) && ref( $params->{ $key } ) eq 'HASH' ) {
            $dataset->{ $key } = $params->{ $key }
        }
        else {
            $self->_store( $key, $params->{ $key } );
        }
    }

    $self->_MultiStore( $dataset ) if scalar( keys %$dataset );

    return 1
}

# Данные пользователя
# $user = Freee::EAV->new( 'User', { 'id' => $param->{'id'} } );
# $user = $user->GetUser($param->{'id'});
sub GetUser {
    my ( $self, $id ) = @_;

    return undef() unless $self->{_item};
    return undef() unless $id || $id != /^\d+$/ ;

    # получаем данные из users
    my $sql = 'SELECT * FROM "public"."users" WHERE id='. $id;
    my $users = $self->{dbh}->selectrow_hashref( $sql, { Slice => {} } );
    return $user unless $users->{'eav_id'};

    # получаем данные из users_social
    my $sql = 'SELECT * FROM "public"."users_social" WHERE user_id='. $id;
    my $users_social = $self->{dbh}->selectrow_hashref( $sql, { Slice => {} } );

    # получаем данные из EAV
    my $data = $self->_getAll( $users->{'id'} );

    # объедняем данные таблиц users + users_social + EAV

    return $data;
}

1;
