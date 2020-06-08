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

#### потом добавить заполнение полей type, mime, order, flags ???????????????????????????????????????????????????????
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
            $local_path = $self->{ 'app' }->{ 'config' }->{ 'upload_local_path' };
            $extension = $self->{ 'app' }->{ 'config' }->{ 'desc_extension' };
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

        my ( $fileinfo, $filename, $local_path, $cmd, $sth, $result, @mess );

        # поиск имени и расширения файла по id
        $fileinfo = $self->_get_media( $data, ['filename','extension'] );
        push @mess, "Can not get $$data{'id'}" unless $fileinfo;

        # удаление файла
        unless ( @mess ) {
            $filename = $$fileinfo{'filename'} . '.' . $$fileinfo{'extension'};
            $local_path = $self->{ 'app' }->{ 'config' }->{ 'upload_local_path' };
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
    # my $true = $self->_get_media( $data, [] );
    # возвращает true/false
    $app->helper( '_get_media' => sub {
        my ( $self, $data, $obj ) = @_;

        # определение запроса к бд
        my $str = '*';
        if ( @$obj ) {
            $str = '"' . join( '","', @$obj ) . '"';
        }

        # получение запрошенных данных о файле
        my $sth;

        if ( $$data{'description'} ) {
            $sth = $self->pg_dbh->prepare( 'SELECT * FROM "public"."media" WHERE "description" like ?' );
            $sth->bind_param( 1, '%' . $$data{'description'} . '%' );
        }
        elsif ( ( $$data{'filename.extension'} ) && ( $$data{'filename'} ) ) {
            $sth = $self->pg_dbh->prepare( 'SELECT * FROM "public"."media" WHERE "extension" = ? and "filename" = ?' );
            $sth->bind_param( 1, $$data{'extension'} );
            $sth->bind_param( 2, $$data{'filename'} );
        }
        elsif ( $$data{'filename'} ) {
            $sth = $self->pg_dbh->prepare( 'SELECT * FROM "public"."media" WHERE "filename" = ?' );
            $sth->bind_param( 1, $$data{'filename'} );
        }
        elsif ( $$data{'id'} ) {
            $sth = $self->pg_dbh->prepare( 'SELECT' . $str . 'FROM "public"."media" WHERE "id" = ?' );
            $sth->bind_param( 1, $$data{'id'} );
        }
        elsif ( $$data{'extension'} ) {
            $sth = $self->pg_dbh->prepare( 'SELECT' . $str . 'FROM "public"."media" WHERE "extension" = ?' );
            $sth->bind_param( 1, $$data{'extension'} );
        }
        $sth->execute();
        my $result = $sth->fetchall_hashref('id');
        my @result;

        my $url;
        my $host = $self->{ 'app' }->{ 'config' }->{ 'host' }; 
        foreach my $row ( values %{$result} ) {
            $url = join( '/', ( $host, 'upload', %$row{ 'filename' } . '.' . %$row{ 'extension' } ) );
            %$row = ( %$row, 'url', $url);
            push @result, $row;
        }

        return @result;
    });

    # обновляет описание файла
    # my $true = $self->_update_media( $data );
    # возвращает true/false
    $app->helper( '_update_media' => sub {
        my ( $self, $data ) = @_;

        my ( $sth,  $media, $local_path, $extension, $rewrite_result, $json, $mess, $result, $url, $host, @result );
        # обновление описания в бд
        $sth = $self->pg_dbh->prepare( 'UPDATE "public"."media" SET "description" = ? WHERE "id" = ? RETURNING "id"' );
        $sth->bind_param( 1, $$data{'description'} );
        $sth->bind_param( 2, $$data{'id'} );
        $result = $sth->execute();

        # ошибка при отсутствии в бд id
        if ( $result eq '0E0' ) {
            $result = 0;
            $mess = "Id $$data{'id'} doesn't exist";
        }

        # получение данных о файле
        unless ( $mess ) {
            @result = $self->_get_media( $data, [] );
            $mess = "Can not get file" unless @result;
            $data = shift @result;
        }

        # преобразование данных в json
        unless ( $mess ) {
            $json = encode_json ( $data );
            $mess = "Can not convert into json $$data{'title'}" unless $json;
        }

        # запись нового файла с описанием
        unless ( $mess ){
            $local_path = $self->{ 'app' }->{ 'config' }->{ 'upload_local_path' };
            $extension = $self->{ 'app' }->{ 'config' }->{ 'desc_extension' };
            $rewrite_result = write_file( $local_path . $$data{ 'filename' } . '.' . $extension, $json );
            $mess = "Can not rewrite desc of $$data{'title'}" unless $rewrite_result;
        }

        unless ( $mess ){
            $host = $self->{ 'app' }->{ 'config' }->{ 'host' };
            $url = join( '/', ( $host, 'upload', $$data{ 'filename' } . '.' . $$data{ 'extension' } ) );
        }

        return $data, $mess;
    });
}

1;