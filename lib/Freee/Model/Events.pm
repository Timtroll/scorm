package Freee::Model::Events;

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
sub _insert_event {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result, $students );

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

        unless ( @! ) {
            # добавление в universal_links
            $students = decode_json( $$data{'student_ids'} );
            $sql = 'INSERT INTO "public"."universal_links" ( "a_link_id", "a_link_type", "b_link_id", "b_link_type", "owner_id" ) VALUES ( :a_link_id, :a_link_type, :b_link_id, :b_link_type, :owner_id )';

            foreach my $student_id ( @$students ) {
                $sql = 'INSERT INTO "public"."universal_links" ( "a_link_id", "a_link_type", "b_link_id", "b_link_type", "owner_id" ) VALUES ( :a_link_id, :a_link_type, :b_link_id, :b_link_type, :owner_id )';
                $sth = $self->{'app'}->pg_dbh->prepare( $sql );
                $sth->bind_param( ':a_link_id', $id );
                $sth->bind_param( ':a_link_type', 7 );
                $sth->bind_param( ':b_link_id', $student_id );
                $sth->bind_param( ':b_link_type', 2 );
                $sth->bind_param( ':owner_id', $$data{'owner_id'} );
                $result = $sth->execute();
                $sth->finish();
                unless ( $result ) {
                    push @!, "Can not insert student into universal_links";
                    $self->{'app'}->pg_dbh->rollback;
                    return;
                }
            }
        }

        # закрытие транзакции
        $self->{'app'}->pg_dbh->commit;
    }

    return $id;
}

# удаление события
# my $true = $self->_delete_event( 99 );
# возвращается true/false
sub _delete_event {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    push @!, 'no id' unless $$data{'id'};

    unless( @! ) {

        # открываем транзакцию
        $self->{'app'}->pg_dbh->begin_work;

        # удаление записи из таблицы streams
        $sql = 'DELETE FROM "public"."events" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        if ( $result eq '0E0' ) {
            push @!, "Could not delete Event '$$data{'id'}'";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }

        # удаление записи из таблицы universal_links
        $sql = 'DELETE FROM "public"."universal_links" WHERE "a_link_id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        if ( $result eq '0E0' ) {
            push @!, "Could not delete universal_link '$$data{'id'}'";
            $self->{'app'}->pg_dbh->rollback;
            return;
        }

        # закрытие транзакции
        $self->{'app'}->pg_dbh->commit;
    }

    return $result;
}

1;