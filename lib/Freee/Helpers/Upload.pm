package Freee::Helpers::Upload;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

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

        my $sth = $self->pg_dbh->prepare( 'INSERT INTO "public"."media" ("path", "filename", "extension", "title", "size", "type", "mime", "description", "order", "flags") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
        $sth->bind_param( 1, $$data{'path'} );
        $sth->bind_param( 2, $$data{'filename'} );
        $sth->bind_param( 3, $$data{'extension'} );
        $sth->bind_param( 4, $$data{'title'} );
        $sth->bind_param( 5, $$data{'size'} );
        $sth->bind_param( 6, '' );
        $sth->bind_param( 7, '' );
        $sth->bind_param( 8, $$data{'description'} );
        $sth->bind_param( 9, 0 );
        $sth->bind_param( 10, 0 );
        my $result = $sth->execute();

        return $result;
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
                push @mess, "Can not delete $local_path . $filename, $?";
            };
        }

        # удаление записи о файле
        unless ( @mess ) {
            $sth = $self->pg_dbh->prepare( 'DELETE FROM "public"."media" WHERE "id" = ?' );
            $sth->bind_param( 1, $$data{'id'} );
            $result = $sth->execute();
            push @mess, "Can not delete record about $$data{'id'} from db" . DBI->errstr unless ( $result );
        }

        return $result, \@mess;
    });

    # выводит запись о файле
    # my $true = $self->_get_media( $id );
    # возвращает true/false
    $app->helper( '_get_media' => sub {
        my ( $self, $data, $obj ) = @_;

        my $str = '*';
        if ( @$obj ) {
            $str = '"' . join( '","', @$obj ) . '"';
        }

        my $sth;
        if ( $$data{'id'} ) {
            $sth = $self->pg_dbh->prepare( 'SELECT' . $str . 'FROM "public"."media" WHERE "id" = ?' );
            $sth->bind_param( 1, $$data{'id'} );
        }
        elsif ( $$data{'filename'} ) {
            $sth = $self->pg_dbh->prepare( 'SELECT * FROM "public"."media" WHERE "filename" = ?' );
            $sth->bind_param( 1, $$data{'filename'} );
        }
        $sth->execute();
        my $result = $sth->fetchrow_hashref;

        return $result;
    });
}

1;