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

    my ( $sth, $result );

    # проверка входных данных
    unless ( $data ) {
        push @!, "no data for insert";
    }

##### потом добавить заполнение полей type, mime, order, flags ???????????????????????????????????????????????????????
    unless ( @! ) {
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
        push @!, "Can not insert $$data{'title'}" unless $result;
    }

    return $result;
}

# возвращает имя и расширение файла
# ( $fileinfo, $error ) = $self->model('Upload')->_check_media( $id );
sub _check_media {
    my ( $self, $id ) = @_;

    my ( $result, $sth, $sql );

    # проверка входных данных
    unless ( $id ) {
        push @!, "no data for check";
    }

    # поиск имени и расширения файла по id
    unless ( @! ) {
        $sql = q( SELECT "filename", "extension" FROM "public"."media" WHERE "id" = ? );
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $id );
        $sth->execute();

        $result = $sth->fetchrow_hashref();
        push @!, "Can not get file info" unless ( $result );
    }

    return $result;
}

# удаляет файл и запись о нём
# ( $fileinfo, $error ) = $self->model('Upload')->_delete_media( $id );
sub _delete_media {
    my ( $self, $id ) = @_;

    my ( $result, $sth, $sql );

    # проверка входных данных
    unless ( $id ) {
        push @!, "no id for delete";
    }

    # удаление записи о файле
    unless ( @! ) {
        $sql = 'DELETE FROM "public"."media" WHERE "id" = ?';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $id );

        $result = $sth->execute();
        push @!, "Can not delete record $id from db" . DBI->errstr unless ( $result );
    }

    return $result;
}

# выводит данные о файле
# ( $data, $error ) = $self->model('Upload')->_get_media( $data );
sub _get_media {
    my ( $self, $data ) = @_;

    my ( $sth, $result, $sql, $count, @bind );

    # проверка входных данных
    unless ( $$data{'search'} ) {
        push @!, "no data for search";
    }

    # запрос данных
    unless ( @! ) {
        if ( $$data{'search'} =~ qr/^\d+$/os ) {
            $sql = 'SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "id" = ?';
            @bind = ( $$data{'search'} );
        }
        elsif ( $$data{'search'} =~ qr/^[\da-zA-Z]+$/os && length( $$data{'search'} ) == 48 ) {
            $sql = 'SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "filename" = ?';
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
        push @!, "can not get data from database" unless %{$result};
    }

    return $result;
}

# обновляет описание файла
# ( $data, $error ) = $self->model('Upload')->_update_media( $data );
sub _update_media {
    my ( $self, $data ) = @_;

    my ( $sth, $result, $sql );

    # проверка входных данных
    unless ( $$data{'id'} ) {
        push @!, "no data for update";
    }
    else {
        # обновление описания в бд
        $sth = $self->{app}->pg_dbh->prepare( 'UPDATE "public"."media" SET "description" = ? WHERE "id" = ? RETURNING "id"' );
        $sth->bind_param( 1, $$data{'description'} );
        $sth->bind_param( 2, $$data{'id'} );

        $result = $sth->execute();
        push @!, "Can not update media" unless $result;
    }

    # получение данных о файле
    unless ( @! ) {
        $sql = q( SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "id" = ? );
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( 1, $$data{'id'} );
        $sth->execute();

        $data = $sth->fetchrow_hashref();
        push @!, "Can not get file info" unless ( $data );
    }

    return $data;
}

1;