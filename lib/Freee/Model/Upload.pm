package Freee::Model::Upload;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# загружаемые файлы
###################################################################

# вводит данные о новом файле в таблицу media
# my $true = $self->model('Upload')->_insert_media( $data );
sub _insert_media {
    my ( $self, $data ) = @_;

    my ( $sth, $result, $mess, @mess );

    # проверка входных данных
    unless ( $data ) {
        push @mess, "no data for insert";
    }

##### потом добавить заполнение полей type, mime, order, flags ???????????????????????????????????????????????????????
    unless ( @mess ) {
        # запись данных в базу
        $sth = $self->{'app'}->pg_dbh->prepare( 'INSERT INTO "public"."media" ("path", "filename", "extension", "title", "size", "type", "mime", "description", "order", "flags") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING "id"' );
        $sth->bind_param( 1, $$data{'path'} );
        $sth->bind_param( 2, $$data{'filename'} );
        $sth->bind_param( 3, $$data{'extension'} );
        $sth->bind_param( 4, $$data{'title'} );
        $sth->bind_param( 5, $$data{'size'} );
        $sth->bind_param( 6, '' );
        $sth->bind_param( 7, $$data{'mime'} );
        $sth->bind_param( 8, $$data{'description'} );
        $sth->bind_param( 9, 0 );
        $sth->bind_param( 10, 0 );
        $sth->execute();

        $result = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'media_id_seq' } );
        push @mess, "Can not insert $$data{'title'}" unless $result;
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

# возвращает имя и расширение файла
# ( $fileinfo, $error ) = $self->model('Upload')->_check_media( $id );
sub _check_media {
    my ( $self, $id ) = @_;

    my ( $result, $sth, $sql, $mess, @mess );

    # проверка входных данных
    unless ( $id ) {
        push @mess, "no data for check";
    }

    # поиск имени и расширения файла по id
    unless ( @mess ) {
        $sql = q( SELECT "filename", "extension" FROM "public"."media" WHERE "id" = ? );
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $id );
        $sth->execute();

        $result = $sth->fetchrow_hashref();
        push @mess, "Can not get file info" unless ( $result );
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

# удаляет файл и запись о нём
# ( $fileinfo, $error ) = $self->model('Upload')->_delete_media( $id );
sub _delete_media {
    my ( $self, $id ) = @_;

    my ( $result, $sth, $sql, $mess, @mess );

    # проверка входных данных
    unless ( $id ) {
        push @mess, "no id for delete";
    }

    # удаление записи о файле
    unless ( @mess ) {
        $sql = 'DELETE FROM "public"."media" WHERE "id" = ?';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $id );

        $result = $sth->execute();
        push @mess, "Can not delete record $id from db" . DBI->errstr unless ( $result );
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $result, $mess;
}

# выводит данные о файле
# ( $data, $error ) = $self->model('Upload')->_get_media( $data );
sub _get_media {
    my ( $self, $data ) = @_;

    my ( $sth, $result, $sql, $count, $mess, @bind, @mess );

    # проверка входных данных
    unless ( $$data{'search'} ) {
        push @mess, "no data for search";
    }

    # запрос данных
    unless ( @mess ) {
        if ( $$data{'search'} =~ qr/^\d+$/os ) {
            $sql = 'SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "id" = ?';
            @bind = ( $$data{'search'} );
        }
        elsif ( $$data{'search'} =~ qr/^[\w]+$/os && length( $$data{'search'} ) == 48 ) {
            $sql = 'SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "id" = ?';
            @bind = ( $$data{'search'} );
        }
        else {
            $sql = 'SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "title" LIKE ? OR "description" LIKE ?';
            @bind = ( '%' . $$data{'search'} . '%', '%' . $$data{'search'} . '%');
        }

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $count = 1;
        foreach my $bind ( @bind ) {
            $sth->bind_param( $count, $bind );
            $count++;
        }
        $sth->execute();

        $result = $sth->fetchall_hashref('id');
        push @mess, "can not get data from database" unless %{$result};
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }
    return $result, $mess;
}

# обновляет описание файла
# ( $data, $error ) = $self->model('Upload')->_update_media( $data );
sub _update_media {
    my ( $self, $data ) = @_;

    my ( $sth, $result, $sql, $mess, @mess );

    # проверка входных данных
    unless ( $$data{'id'} ) {
        push @mess, "no data for update";
    }
    else {
        # обновление описания в бд
        $sth = $self->{app}->pg_dbh->prepare( 'UPDATE "public"."media" SET "description" = ? WHERE "id" = ? RETURNING "id"' );
        $sth->bind_param( 1, $$data{'description'} );
        $sth->bind_param( 2, $$data{'id'} );

        $result = $sth->execute();
        push @mess, "Can not update media" unless $result;
    }

    # получение данных о файле
    unless ( @mess ) {
        $sql = q( SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "id" = ? );
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $data = $sth->fetchrow_hashref();
        push @mess, "Can not get file info" unless ( $data );
    }

    if ( @mess ) {
        $mess = join( "\n", @mess );
    }

    return $data, $mess;
}

1;