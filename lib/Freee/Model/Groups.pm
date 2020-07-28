package Freee::Model::Groups;

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

    # получаем список групп
    my $groups;
    eval{
        $groups = $self->pg_dbh->selectall_hashref('SELECT id,label FROM "public"."groups"', 'id');
    };
    warn $@ if $@;
    return if $@;

    # синхронизация реальных роутов и роутов в группах
    foreach my $parent (sort {$a <=> $b} keys %$groups) {
        # получаем список роутов текущей группы
        my $list = {};
        eval {
            $list = $self->pg_dbh->selectall_hashref('SELECT id, label, name, parent FROM "public"."routes" WHERE "parent"='.$parent, 'name');
        };
        warn $@ if $@;
        return if $@;

        # проверка соответствия роута в таблице тому, что есть в реальном списке роутов
        foreach my $route (keys %$list) {
            # удаляем роуты, которые есть в таблице, но которых нет в реальном списке
            unless ( defined $$routs{ $route } ) {
                eval {
                    $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$$list{$route}{'id'} );
                };
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
                    "status" => 1
                };
                my $sql = 'INSERT INTO "public"."routes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).')';
                eval {
                    $self->pg_dbh->do( $sql );
                };
                warn $@ if $@;
                return if $@;
            }
        }
    }

    return $groups;
}

# читаем одну группу
# my $row = $self->_get_group( 99 );
# возвращается строка в виде объекта
sub _get_group {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result, $mess, @mess );

    push @mess, 'no id' unless $$data{'id'};

    unless( @mess ) {
        # взять запись о группе из таблицы groups
        $sql = 'SELECT * FROM "public"."groups" WHERE "id" = ?';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $result = $sth->fetchrow_hashref();
        push @mess, "Could not get Group '$$data{'id'}'" unless $result;
    }
    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

# добавление группы пользователей
# my $id = $self->_insert_group({
#     "id"          => '1',             - id элемента
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "status"      => 0                - статус группы
# });
# возвращается id записи    
sub _insert_group {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $mess, @mess );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @mess, "no data for insert";
    }

    unless ( @mess ) {
        $sql = 'INSERT INTO "public"."groups" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ).')';

        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();

        $id = $sth->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
        push @mess, "Can not insert $$data{'label'} into groups" unless $id;
    }

#???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
    # синхронизация реальных роутов в группах       ?????????????????????????????????????????????????????
    # $self->_all_groups();

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }
    return $id, $mess;
}

# изменение группы пользователей
# my $id = $self->_update_group({
#     "id"          => '1',             - id элемента
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "status"      => 0,               - по умолчанию 1
# });
# возвращается true/false
sub _update_group {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result, $mess, @mess );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @mess, "no data for update";
    }

    unless ( @mess ) {
        $sql = 'UPDATE "public"."groups" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();

        push @mess, "Can not update $$data{'label'}" if $result eq '0E0';
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }
    return $result, $mess;
}

# удаление группы
# my $true = $self->_delete_group( 99 );
# возвращается true/false
sub _delete_group {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result, $mess, @mess );

    push @mess, 'no id' unless $$data{'id'};

    unless( @mess ) {
        # удаление записи из таблицы groups
        $sql = 'DELETE FROM "public"."groups" WHERE "id" = ?';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $result = $sth->execute();

        push @mess, "Could not delete Group '$$data{'id'}'" if $result eq '0E0';
    }
    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

1;
