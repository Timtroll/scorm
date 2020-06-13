package Freee::Helpers::Upload;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Mojo::JSON qw( encode_json );
use File::Slurp;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Upload

    # вводит данные о новом файле в таблицу media
    # my $true = $self->_insert_media( $data );
    # возвращает true/false
    $app->helper( '_insert_media' => sub {
        my ( $self, $data ) = @_;

        my ( $sth, $result, $local_path, $extension, $json, $write_result, $mess );

##### потом добавить заполнение полей type, mime, order, flags ???????????????????????????????????????????????????????
        # запись данных в базу
        $sth = $self->pg_dbh->prepare( 'INSERT INTO "public"."media" ("path", "filename", "extension", "title", "size", "type", "mime", "description", "order", "flags") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING "id"' );
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
        $mess = "Can not insert $$data{'title'}" unless $result;

        # преобразование данныхв json
        unless ( $mess ) {
            delete $$data{'content'};
            $json = encode_json ( $data );
            $mess = "Can not convert into json $$data{'title'}" unless $json;
        }

        # создание файла с описанием
        unless ( $mess ) {
            $local_path = $self->{'app'}->{'settings'}->{'upload_local_path'};
            $extension = $self->{'app'}->{'settings'}->{'desc_extension'};
            $write_result = write_file( $local_path . $$data{ 'filename' } . '.' . $extension, $json );
            $mess = "Can not write desc of $$data{'title'}" unless $write_result;
        }

        return $result, $mess;
    });

    # удаляет файл и запись о нём
    #( $true, $error ) = $self->_delete_media( $id );
    # возвращает true/false и ошибку
    $app->helper( '_delete_media' => sub {
        my ( $self, $data ) = @_;

        my ( $fileinfo, $filename, $local_path, $cmd, $sth, $result, $sql, @mess, @get );

        # поиск имени и расширения файла по id
        unless ( @mess ) {
            $sql = q( SELECT "filename", "extension" FROM "public"."media" WHERE "id" = ? );
            $sth = $self->pg_dbh->prepare( $sql );
            $sth->bind_param( 1, $$data{'id'} );
            $sth->execute();
            $fileinfo = $sth->fetchrow_hashref();
            push @mess, "Can not get file info" unless ( $fileinfo );
        }

        # удаление файла
        unless ( @mess ) {
            $filename = $$fileinfo{'filename'} . '.' . $$fileinfo{'extension'};
            $local_path = $self->{'app'}->{'settings'}->{'upload_local_path'};
            $cmd = $local_path . $filename;

            $cmd = `rm $cmd`;
            if ( $? ) {
                push @mess, "Can not delete $filename, $?";
            };
        }

        # удаление описания файла
        unless ( @mess ) {
            $filename = $$fileinfo{'filename'} . '.' . 'desc';
            $cmd = $local_path . $filename;

            $cmd = `rm $cmd`;
            if ( $? ) {
                push @mess, "Can not delete $filename description, $?";
            };
        }

        # удаление записи о файле
        unless ( @mess ) {
            $sth = $self->pg_dbh->prepare( 'DELETE FROM "public"."media" WHERE "id" = ?' );
            $sth->bind_param( 1, $$data{'id'} );
            $result = $sth->execute();
            push @mess, "Can not delete record about $$data{'id'} from db" . DBI->errstr unless ( $result );
        }

        my $mess;
        if ( @mess ) {
            $mess = join( "\n", @mess );
        }

        return $result, $mess;
    });

    # выводит запись о файле
    # my $true = $self->_get_media( $data );
    # возвращает true/false
    $app->helper( '_get_media' => sub {
        my ( $self, $data, $obj ) = @_;

        my ( $str, $sth, $result, $url, $host, $sql, $count, $mess, @bind, @mess, @result );

        unless ( @$obj ) {
            $obj = [ 'id', 'filename', 'title', 'size', 'mime', 'description', 'extension' ];
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
            $host = $self->{'app'}->{'settings'}->{ 'site_url' };
            foreach my $row ( values %{$result} ) {
                $url = join( '/', ( $host, 'upload', $$row{ 'filename' } . '.' . $$row{ 'extension' } ) );
                push @result, { %$row, 'url', $url };
            }
        }

        $mess = join( "\n", @mess ) if @mess;
        return \@result, $mess;
    });

    # обновляет описание файла
    # my $true = $self->_update_media( $data );
    # возвращает true/false
    $app->helper( '_update_media' => sub {
        my ( $self, $data ) = @_;

        my ( $sth, $media, $local_path, $url_path, $desc_extension, $rewrite_result, $json, $mess, $result, $url, $sql, $host, @mess );

        # обновление описания в бд
        $sth = $self->pg_dbh->prepare( 'UPDATE "public"."media" SET "description" = ? WHERE "id" = ? RETURNING "id"' );
        $sth->bind_param( 1, $$data{'description'} );
        $sth->bind_param( 2, $$data{'id'} );
        $result = $sth->execute();
        push @mess, "Can not update media" unless $result;

        # получение данных о файле
        unless ( @mess ) {
            $sql = q( SELECT "id", "filename", "title", "size", "mime", "description", "extension" FROM "public"."media" WHERE "id" = ? );
            $sth = $self->pg_dbh->prepare( $sql );
            $sth->bind_param( 1, $$data{'id'} );
            $sth->execute();
            $data = $sth->fetchrow_hashref();
            push @mess, "Can not get file info" unless ( $data );
        }

        # преобразование данных в json
        unless ( @mess ) {
            $json = encode_json ( $data );
            push @mess, "Can not convert into json $$data{'title'}" unless $json;
        }

        # запись нового файла с описанием
        $host = $self->{'app'}->{'settings'}->{ 'site_url' };
        $local_path = $self->{'app'}->{'settings'}->{'upload_local_path'};
        $url_path = $self->{'app'}->{'settings'}->{ 'upload_url_path' };
        $desc_extension = $self->{'app'}->{'settings'}->{'desc_extension'};
        unless ( @mess ){
            $rewrite_result = write_file( $local_path . $$data{ 'filename' } . '.' . $desc_extension, $json );
            push @mess, "Can not rewrite desc of $$data{'title'}" unless $rewrite_result;
        }

        unless ( $mess ){
            $url = $host . $url_path . $$data{ 'filename' } . '.' . $$data{ 'extension' };
        }
        else {
            $mess = join( "\n", @mess );
        }
        return $data, $mess;
    });
}

1;