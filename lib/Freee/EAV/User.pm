package Freee::EAV::User;

use parent 'Freee::EAV::Base';
use strict;
use warnings;

use Data::Dumper;

sub new {
    my ( $self, $class, $params ) = @_;
    # my ( $path, $class, $params ) = @_;
    $self = {};
    bless $self;
warn "1-new\n";
warn Dumper ( $params );
warn Dumper ( $class );
    if ( defined( $params ) && ref( $params ) && ref( $params ) eq 'HASH' ) {
        if ( exists( $params->{id} ) ) {
warn "2-new\n";
            return $self->_Get( $params );
        } else {
warn "3-new\n";
            return $self->_Store( $params );
        }
    }
warn "4-new\n";
    return undef();
}

sub _Store {
    my ( $self, $params ) = @_;
warn "1-store\n";
    my $EAVObject = $self->SUPER::new( 'Free::EAV::User', $params );
    # my $EAVObject = $self->SUPER::new( 'Free::EAV::User' );
    # my $EAVObject = $self->SUPER::new( $params );
warn Dumper( $EAVObject );
warn "2-store\n";
    return undef() unless defined( $EAVObject );
warn "3-store\n";
    my $fields = [ 'email', 'password', 'eav_id', 'timezone' ];

    $params->{eav_id} = $EAVObject->id();

    $EAVObject->{_user} = $EAVObject->{dbh}->selectrow_hashref( 'INSERT INTO "public"."users" ( '.join( ', ', map { '"'.$_.'"' } @$fields ).' ) VALUES ('.join( ', ', map { $EAVObject->{dbh}->quote( $params->{ $_ } ) } @$fields ).') RETURNING *' );

    $EAVObject->import_id( $EAVObject->{_user}->{id} );

    # add data into users_social


    return $EAVObject;
}

# Данные пользователя
# $user = Freee::EAV->new( 'User', { 'id' => $param->{'id'} } );
# $user = $user->GetUser();
sub _Get {
    my ( $self, $params ) = @_;
warn "1-get\n";
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
