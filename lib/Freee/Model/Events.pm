package Freee::Model::Events;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;

use common;

# добавление события
# my $id = $self->insert_event({
#     "comment",     => 'comment',         - комментарий
#     'time_start'   => '01-09-2020',      - дата начала события
#     'initial_id'   => 11,                - id руководителя
#     "status"       => 0 или 1,           - активен ли поток, обязательное поле
# });
# возвращается id записи    
sub _insert_event {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        # открываем транзакцию
        $self->{'app'}->pg_dbh->begin_work;

        $sql = 'INSERT INTO "public"."events" ( "initial_id", "time_start", "comment", "publish" ) VALUES ( :initial_id, :time_start, :comment, :publish )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':initial_id', $$data{'initial_id'} );
        $sth->bind_param( ':time_start', $$data{'time_start'} );
        $sth->bind_param( ':comment', $$data{'comment'} );
        $sth->bind_param( ':publish', ( $$data{'status'} ? 1 : 0 ) );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'events', undef, { sequence => 'events_id_seq' } );
        $sth->finish();
        unless ( $id ) {
            push @!, "Can not insert $$data{'name'} into streams";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }

        # закрытие транзакции
        $self->{'app'}->pg_dbh->commit;
    }

    return $id;
}

1;