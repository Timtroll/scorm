package Freee::Model::Routes;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;

use common;


#################################
# Роуты
#################################

# получение списка рутов из базы в массив хэшей
# my $routes = $self->_routes_values();
sub _routes_list {
    my ( $self, $parent ) = @_;

    my ( $sql, $sth, $list );

    unless ( $parent ) {
        push @!, 'no id';
    }
    else {
        # получаем список групп
        $sql = 'SELECT * FROM "public"."routes" WHERE "parent" = ?';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $parent );
        $sth->execute();
        $list = $sth->fetchall_hashref( 'id' );
        $sth->finish();
    }

    return $list;
}

# читаем один роут
# my $row = $self->_get_route( 99 );
# возвращается строка в виде объекта
sub _get_route {
    my ( $self, $id ) = @_;

    my ( $sql, $sth, $row );

    unless ( $id ) {
        push @!, 'no id';
    }
    else {
        # взять запись о роуте из таблицы routes
        $sql = 'SELECT * FROM "public"."routes" WHERE "id" = ?';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $id );
        $sth->execute();
        $row = $sth->fetchrow_hashref();
        $sth->finish();
    }

    return $row;
}


####### не используется ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
# добавление роута
# my $id = $self->_insert_route({
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
#     "publish"      => 0                - активность элемента, по умолчанию 1
# });
# возвращается id роута 
sub _insert_route {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."routes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ).')';

        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'routes', undef, { sequence => 'routes_id_seq' } );
        $sth->finish();
        push @!, "Can not insert $$data{'label'} into routes" unless $id;
    }

    return $id;
}

# обновление роута
# my $id = $self->_update_route({
#      "id"         => 1,           - id обновляемого элемента ( >0 )
#     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",          - строка или json
#     "required"    => 0,           - не обязательно, по умолчанию 0
#     "publish"      => 0            - по умолчанию 1
# });
# возвращается true/false
sub _update_route {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {
        $sql = 'UPDATE "public"."routes" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();
    }

    return $result;
}

1;
