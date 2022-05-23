package Freee::Model::Schedule;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;
use Mojo::JSON qw( decode_json );

use common;

# добавление события
# my $id = $self->insert_event({
#     "comment",     => 'comment',         - комментарий
#     'time_start'   => '01-09-2020',      - дата начала события
#     'initial_id'   => 11,                - id руководителя
#     "status"       => 0 или 1,           - активен ли поток, обязательное поле
# });
# возвращается id записи    
sub _insert_schedule {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result, $students );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {

        $sql = 'INSERT INTO "public"."schedule" ( "teacher_id", "course_id", "time_start", "time_start_sec", "duration", "publish" ) VALUES ( :teacher_id, :course_id, :time_start, :time_start_sec, :duration, :publish )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':teacher_id', $$data{'teacher_id'} );
        $sth->bind_param( ':course_id', $$data{'course_id'} );
        $sth->bind_param( ':time_start', $$data{'time_start'} );
        $sth->bind_param( ':time_start_sec', $$data{'time_start_sec'} );
        $sth->bind_param( ':duration', $$data{'duration'} );
        $sth->bind_param( ':publish', ( $$data{'status'} ? 1 : 0 ) );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'schedule', undef, { sequence => 'schedule_id_seq' } );
        $sth->finish();
        unless ( $id ) {
            push @!, "Can not insert into schedule";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }
    }

    return $id;
}

sub _get_list_on_time {
    my ( $self, $data ) = @_;

    my ( $sql, $fields, $sth );
    my $list = {};

    # выбираемые поля
    $fields = ' id, teacher_id, course_id, time_start, duration, publish AS status ';

    # взять объекты из таблицы users
    $sql = 'SELECT' .  $fields . 'FROM "public"."schedule" WHERE "time_start_sec" BETWEEN ' . $$data{'time_start_sec'} . ' AND ' . ( $$data{'time_start_sec'} + $$data{'time'} ) . ' ORDER BY id';
    $sth = $self->{app}->pg_dbh->prepare( $sql );

    $sth->execute();
    $list = $sth->fetchall_arrayref({});

    $sth->finish();

    return $list;
}
    
# $self->index();
sub _get_list {
    my ( $self, $data ) = @_;

    my ( $sql, $fields, $sth );
    my $list = {};

    # выбираемые поля
    $fields = ' id, teacher_id, course_id, time_start, duration, publish AS status ';

    # взять объекты из таблицы users
    $sql = 'SELECT' .  $fields . 'FROM "public"."schedule" ORDER BY id';

    if ( $$data{'order'} eq 'DESC' ) {
        $sql .= ' DESC';
    }
    else {
        $sql .= ' ASC';
    }

    $sql .= ' LIMIT :limit' if $$data{'limit'};
    $sql .= ' OFFSET :offset' if $$data{'offset'};

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':limit', $$data{'limit'} ) if $$data{'limit'};
    $sth->bind_param( ':offset', $$data{'offset'} ) if $$data{'offset'};
    $sth->execute();
    $list = $sth->fetchall_arrayref({});
    $sth->finish();

    return $list;
}

# удаление события
# my $true = $self->_delete_event( 99 );
# возвращается true/false
sub _delete_schedule {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    push @!, 'no id' unless $$data{'id'};

    unless( @! ) {

        # удаление записи из таблицы streams
        $sql = 'DELETE FROM "public"."schedule" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        if ( $result eq '0E0' ) {
            push @!, "Could not delete Schedule '$$data{'id'}'";
            return;
        }
    }

    return $result;
}

# читаем одно событие
# my $row = $self->_get_event( 99 );
# возвращается строка в виде объекта
sub _get_schedule {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    unless ( $$data{'id'} ) {
        push @!, 'No group id';
    }
    else {
        # получить запись о событии из таблицы events
        $sql = 'SELECT id, teacher_id, course_id, time_start, duration, publish AS status FROM "public"."schedule" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();
        unless ( $result ) {
            push @!, "Could not get Schedule '$$data{'id'}'";
            return;
        }
    }

    return $result;
}

# сохранить эвент
# $self->save( $data );
sub _update_schedule {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result, @fields );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {

        @fields = qw( teacher_id course_id time_start time_start_sec duration publish );
        $sql = 'UPDATE "public"."schedule" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } @fields ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();

        push @!, "Error by update $$data{'id'}" if ! defined $result;

    }

    return $result;
}

1;
