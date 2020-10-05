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

# читаем одну группу
# my $row = $self->_get_group( 99 );
# возвращается строка в виде объекта
sub _get_group {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    unless ( $$data{'id'} ) {
        push @!, 'No group id';
    }
    else {
        # получить запись о группе из таблицы groups
        $sql = 'SELECT * FROM "public"."groups" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();
        push @!, "Could not get Group '$$data{'id'}'" unless $result;
    }

    return $result;
}

# получить id группы по названию
# my $id = $self->get_group_id( 'name' );
#   'get_group_id' - имя группы в таблице
sub _get_group_id {
    my ( $self, $name ) = @_;

    my ( $sql, $sth, $result );

    unless ( $name ) {
        push @!, 'No group name';
    }
    else {
        # получить имя группы
        $sql = 'SELECT * FROM "public"."groups" WHERE "name" = :name';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':name', $name );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();
        push @!, "Could not get Group name '$name'" unless $result;
    }

    return $result;
}

# добавление группы пользователей
# my $id = $self->_insert_group({
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "publish"      => 0                - статус группы
# });
# возвращается id записи    
sub _insert_group {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."groups" ( "label", "name", "publish" ) VALUES ( :label, :name, :publish )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':label', $$data{'label'} );
        $sth->bind_param( ':name', $$data{'name'} );
        $sth->bind_param( ':publish', ( $$data{'publish'} ? 1 : 0 ) );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
        $sth->finish();
        push @!, "Can not insert $$data{'label'} into groups" unless $id;
    }

    # синхронизация реальных роутов в группах
    unless ( @! ) {
        $self->_all_groups();
    }

    return $id;
}

# изменение группы пользователей
# my $id = $self->_update_group({
#     "id"          => '1',             - id элемента
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "publish"      => 0,               - по умолчанию 1
# });
# возвращается true/false
sub _update_group {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {
        $sql = 'UPDATE "public"."groups" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();

        push @!, "Error by update $$data{'label'}" if ! defined $result;
    }

    return $result;
}

# удаление группы
# my $true = $self->_delete_group( 99 );
# возвращается true/false
sub _delete_group {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    push @!, 'no id' unless $$data{'id'};

    unless( @! ) {
        # удаление записи из таблицы groups
        $sql = 'DELETE FROM "public"."groups" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        push @!, "Could not delete Group '$$data{'id'}'" if ! defined $result;
    }

    return $result;
}

1;
