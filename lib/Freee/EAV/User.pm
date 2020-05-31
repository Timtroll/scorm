package Freee::EAV::User;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

use Data::Dumper;

sub new {
    my ( $class, $params ) = @_;
    my $self = {};
    bless $self;

    if ( defined( $params ) && ref( $params ) && ref( $params ) eq 'HASH' ) {
        if ( exists( $params->{id} ) ) {
            return $self->_Get( $params );
        } else {
            return $self->_Store( $params );
        }
    }

    return undef();
}

sub _Store {
    my ( $self, $params ) = @_;

    my $EAVObject = $self->SUPER::new( 'Free::EAV::User', $params );
    return undef() unless defined( $EAVObject );

    my $fields = [ 'email', 'password', 'eav_id', 'timezone' ];

    $params->{eav_id} = $EAVObject->id();

    $EAVObject->{_user} = $EAVObject->{dbh}->selectrow_hashref( 'INSERT INTO "public"."users" ( '.join( ', ', map { '"'.$_.'"' } @$fields ).' ) VALUES ('.join( ', ', map { $EAVObject->{dbh}->quote( $params->{ $_ } ) } @$fields ).') RETURNING *' );

    $EAVObject->import_id( $EAVObject->{_user}->{id} );

    #add data into users_social

    return $EAVObject;
}

# Данные пользователя
# $user = Freee::EAV->new( 'User', { 'id' => $param->{'id'} } );
# $user = $user->GetUser();
sub _Get {
    my ( $self, $params ) = @_;

    my $EAVObject = $self->SUPER::new( 'Free::EAV::User', { import_id => $params->{id} } );
    return undef() unless defined( $EAVObject );

    # получаем данные из users
    $EAVObject->{_user} = $EAVObject->{dbh}->selectrow_hashref( 'SELECT * FROM "public"."users" WHERE "id"='.int( $params->{id} || 0 ).' LIMIT 1' );
    return undef() if !defined( $user ) || !$user->{eav_id};

    # получаем данные из users_social
    $sql = 'SELECT * FROM "public"."users_social" WHERE user_id='. int( $params->{id} || 0 );
    my $sth = $EAVObject->{dbh}->prepare( $sql );
    $sth->execute();
    $EAVObject->{_social} = $sth->fetchall_arrayref({});
    $sth->finish();

    return $EAVObject;
}

1;
