package Freee::Model::MyModel;

use Mojo::Base 'Freee::Model::Base';
use DBI;
use Data::Dumper;
# получить все данные из конфига
sub get_config_data {
    my $self = shift;
# use Data::Dumper;
# warn Dumper $self;
    # return $self->app->config;
    return $self->app->config->{'dbs'}->{'databases'}->{'pg_main'};
}

sub set_ {
    my ( $self, %Param ) = @_;

    # объект с конфигурацией бд
    my $db = $self->app->config->{'dbs'}->{'databases'}->{'pg_main'};

    # подключение к базе данных
    my $dbh = DBI->connect(
        $db->{'dsn'},
        $db->{'username'},
        $db->{'password'},
        $db->{'options'}
    );
    if ( DBI->errstr ) {
        warn( "connection to database doesn't work:" . DBI->errstr );
        exit;    
    }

    # запись параметров в бд
    my $sth = $dbh->prepare( 'INSERT INTO "public"."groups" (id, label, name, status) VALUES (?, ?, ?, ?)' );
    $sth->bind_param( 1, $Param{id} );
    $sth->bind_param( 2, $Param{label} );
    $sth->bind_param( 3, $Param{name} );
    $sth->bind_param( 4, $Param{status} );
    my $res = $sth->execute();
    if ( DBI->errstr ) {
        warn( "execute doesn't work " . DBI->errstr  );
        exit;    
    }

    return( "ok" );
}

sub get_ {
    my ( $self, $id ) = @_;

    # объект с конфигурацией бд
    my $db = $self->app->config->{'dbs'}->{'databases'}->{'pg_main'};

    # подключение к базе данных
    my $dbh = DBI->connect(
        $db->{'dsn'},
        $db->{'username'},
        $db->{'password'},
        $db->{'options'}
    );
    if ( DBI->errstr ) {
        warn( "connection to database doesn't work:" . DBI->errstr );
        exit;    
    }

    # чтение значения бд
    my $sql = 'SELECT id, label, name, status FROM "public"."groups" WHERE id =' . $id;
    my $res = $dbh->selectall_arrayref( $sql );
    unless ( $res ){
        warn( "can't select with id:" . $id);
        exit;
    }

    return( $res );
}

1;