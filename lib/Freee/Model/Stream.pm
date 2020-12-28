package Freee::Model::Stream;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;

use common;


#################################
# Группы пользователей
#################################

# получение списка групп из базы в виде объекта как в Mock/Groups.pm
# my $list = $self->_all_groups();
# возвращает массив хэшей
sub _all_groups {
    my $self = shift;

    my ( $sql, $sth, $groups, $list );

    # получаем список групп
    $sql = 'SELECT id,label FROM "public"."groups"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();

    $groups = $sth->fetchall_hashref( 'id' );
    $sth->finish();
    push @!, "couldn't get list of groups" unless $groups;

    # синхронизация реальных роутов и роутов в группах
    unless ( @! ) {
        foreach my $parent (sort {$a <=> $b} keys %$groups) {
            # получаем список роутов текущей группы
            $sql = 'SELECT id, label, name, parent FROM "public"."routes" WHERE "parent" = :parent';

            $sth = $self->{app}->pg_dbh->prepare( $sql );
            $sth->bind_param( ':parent', $parent );
            $sth->execute();
            $list = $sth->fetchall_hashref( 'name' );
            $sth->finish();

            unless ( $list ) {
                push @!, "couldn't get list of routes";
                last;
            }

            # проверка соответствия роута в таблице тому, что есть в реальном списке роутов
            foreach my $route ( keys %$list ) {
                # удаляем роуты, которые есть в таблице, но которых нет в реальном списке
                unless ( defined $$routs{ $route } ) {
                    $sql = 'DELETE FROM "public"."routes" WHERE "id"= :id';

                    $sth = $self->{app}->pg_dbh->prepare( $sql );
                    $sth->bind_param( ':id', $$list{$route}{'id'} );
                    $sth->execute();
                    $sth->finish();
                }
            }

            # проверка соответствия роута в реальном списке роутов тому, что есть в таблице 
            foreach my $route (keys %$routs) {
                unless ( defined $$list{$route} ) {
                    # добавляем роуты, которые есть в реальном списке, но которых нет в таблице
                    my $data = {
                        "parent" => $parent,
                        "label"  => $$routs{$route},
                        "name"   => $route,
                        "list"   => 0,
                        "add"    => 0,
                        "edit"   => 0,
                        "delete" => 0,
                        "publish" => 1
                    };
                    $sql = 'INSERT INTO "public"."routes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ).')';

                    $sth = $self->{app}->pg_dbh->prepare( $sql );
                    $sth->execute();
                    $sth->finish();
                }
            }
        }
    }

    return $groups;
}

# читаем один поток
# my $row = $self->_get_stream( 99 );
# возвращается строка в виде объекта
sub _get_stream {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    unless ( $$data{'id'} ) {
        push @!, 'No group id';
    }
    else {
        # получить запись о группе из таблицы groups
        $sql = 'SELECT id, name, age, date, master_id, publish AS status FROM "public"."streams" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();
        push @!, "Could not get Stream '$$data{'id'}'" unless $result;
    }

    return $result;
}

# добавление потока
# my $id = $self->insert_stream({
#     "name",        => 'name',            - системное название, латиница, обязательное поле
#     'age'          => 1,                 - год обучения, обязательное поле
#     'date'         => '01-09-2020',      - дата начала обучения, обязательное поле
#     'master_id'    => 11,                - id руководителя
#     "status"       => 0 или 1,           - активен ли поток, обязательное поле
# });
# возвращается id записи    
sub _insert_stream {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."streams" ( "name", "age", "date", "master_id", "publish" ) VALUES ( :name, :age, :date, :master_id, :publish )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':name', $$data{'name'} );
        $sth->bind_param( ':age', $$data{'age'} );
        $sth->bind_param( ':date', $$data{'date'} );
        $sth->bind_param( ':master_id', ( $$data{'master_id'} ? $$data{'master_id'} : undef ) );
        $sth->bind_param( ':publish', ( $$data{'status'} ? 1 : 0 ) );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'streams', undef, { sequence => 'streams_id_seq' } );
        $sth->finish();
        push @!, "Can not insert $$data{'name'} into streams" unless $id;
    }

    return $id;
}

# изменение потока
# my $id = $self->_update_stream({
# "id"        => 1             - id обновляемого элемента ( >0 )
# "name",     => 'name'        - обязательно (системное название, латиница)
# 'age'       => 1,            - год обучения, обязательное поле
# 'date'      => '01-09-2020', - дата начала обучения, обязательное поле
# 'master_id' => 11,           - id руководителя
# "status"    => 0 или 1       - активен ли поток              - по умолчанию 1
# });
# возвращается true/false
sub _update_stream {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {
        $sql = 'UPDATE "public"."streams" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();

        push @!, "Error by update $$data{'name'}" if ! defined $result;
    }

    return $result;
}

# удаление потока
# my $true = $self->_delete_stream( 99 );
# возвращается true/false
sub _delete_stream {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    push @!, 'no id' unless $$data{'id'};

    unless( @! ) {
        # удаление записи из таблицы groups
        $sql = 'DELETE FROM "public"."streams" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        push @!, "Could not delete Stream '$$data{'id'}'" if $result eq '0E0';
    }

    return $result;
}

sub _insert_user {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."universal links" ( "a_link_id", "a_link_type", "b_link_id", "b_link_type", "owner_id", "time_create" ) VALUES ( :a_link_id, :a_link_type, :b_link_id, :b_link_type, :owner_id, :time_create )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':a_link_id', $$data{'user_id'} );
        $sth->bind_param( ':a_link_type', 'User' );
        $sth->bind_param( ':b_link_id', $$data{'stream_id'} );
        $sth->bind_param( ':b_link_type', 'Stream' );
        $sth->bind_param( ':owner_id', ( $$data{'status'} ? 1 : 0 ) );
        $sth->bind_param( ':time_create', ( $$data{'status'} ? 1 : 0 ) );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'streams', undef, { sequence => 'streams_id_seq' } );
        $sth->finish();
        push @!, "Can not insert $$data{'name'} into streams" unless $id;
    }

    return $id;
}
1;
