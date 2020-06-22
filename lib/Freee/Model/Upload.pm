package Freee::Model::Upload;

use Mojo::Base 'Freee::Model::Base';

# выводит данные о файле
# ( $data, $error ) = $self->_get_media( $data, [] );
# возвращает true/false
sub get_media {
    my ( $self, $data, $obj ) = @_;

    my ( $str, $sth, $result, $url, $url_path, $host, $sql, $count, $mess, @bind, @mess, @result );

    unless ( @$obj ) {
        $obj = [ 'id', 'filename', 'title', 'size', 'mime', 'description','extension'];
    }
    $str = '"' . join( '","', @$obj ) . '"';

    # получение запрошенных данных о файле
    unless ( $$data{'search'} ) {
        push @mess, "no data for search";
    }

    # запрос данных
    unless ( @mess ) {
        if ( $$data{'search'} =~ qr/^\d+$/os ) {
            $sql = 'SELECT' . $str . 'FROM "public"."media" WHERE "id" = ?';
            @bind = ( $$data{'search'} );
        }
        elsif ( $$data{'search'} =~ qr/^[\w]+$/os && length( $$data{'search'} ) == 48 ) {
            $sql = 'SELECT' . $str . 'FROM "public"."media" WHERE "filename" = ?';
            @bind = ( $$data{'search'} );
        }
        else {
            $sql = 'SELECT' . $str . 'FROM "public"."media" WHERE "title" LIKE ? OR "description" LIKE ?';
            @bind = ( '%' . $$data{'search'} . '%', '%' . $$data{'search'} . '%');
        }

        $sth = $self->pg_dbh->prepare( $sql );
        $count = 1;
        foreach my $bind ( @bind ) {
            $sth->bind_param( $count, $bind );
            $count++;
        }
        $sth->execute();
        $result = $sth->fetchall_hashref('id');
        push @mess, "can not get data from database" unless %{$result};
    }

    # добавление данных об url
    unless ( @mess ) {
        $host = $self->{'app'}->{'settings'}->{'site_url'};
        $url_path = $self->{'app'}->{'settings'}->{'upload_url_path'};
        foreach my $row ( values %{$result} ) {
            $url = $host . $url_path . $$row{'filename'} . '.' . $$row{'extension'};
            push @result, { %$row, 'url', $url };
        }
    }

    $mess = join( "\n", @mess ) if @mess;
    return \@result, $mess;
}

sub get_ {
    my $self = shift;
warn '==get==';
use Data::Dumper;
warn Dumper $self->{dbh};
warn '==get==';
    return [ keys %{$self->app} ];
    # return ;
}

1;