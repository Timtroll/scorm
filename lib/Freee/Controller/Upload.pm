package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my ( $data, $error, $result, $local_path, $resp, $url, $host, @mess );

    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    
    $local_path = $self->{ 'app' }->{ 'config' }->{ 'upload_local_path' };
    $host = $self->{ 'app' }->{ 'config' }->{ 'host' };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # запись файла
    unless ( @mess ) {
        $result = write_file( $local_path . $$data{ 'filename' } . '.' . $$data{ 'extension' }, $$data{ 'content' } );
        push @mess, "Can not write $$data{'title'}" unless $result;
    }

    # получение mime
    unless ( @mess ) {
        $$data{ 'mime' } = $$mime{$$data{ 'extension' }} || '';
    }

    # ввод данных в таблицу
    unless ( @mess ) {
        ( $result, $error ) = $self->_insert_media( $data );
        push @mess, $error unless $result;
    }

    # получение url
    unless ( @mess ) {
        $url = join( '/', ( $host, 'upload', $$data{ 'filename' } . '.' . $$data{ 'extension' } ) );
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $result if $result;
    $resp->{'url'} = $url if $result;
    $resp->{'mime'} = $$data{ 'mime' } if $result;

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my ( $data, $error, $result, $resp, $filename, $fileinfo, $cmd, $local_path, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # удаление записи
    unless ( @mess ) {
        ( $result, $error ) = $self->_delete_media( $data );
        push @mess, $error unless $result;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

sub search {
    my $self = shift;

    my ( $data, $error, $resp, $url, @mess, @media );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # проверка данных
    unless ( @mess ) {
        unless ( $$data{'id'} || $$data{'filename'} || $$data{'description'} || $$data{'extension'} ) {
            push @mess, 'no data for search!';
        }
    }

    # разделение на имя и расширение файла
    if ( ( $$data{'filename'} ) && ( $$data{'filename'} =~ m/\./ ) ){
        $$data{'filename'} =~ /^(.*?)\.(.*?)$/;
        $$data{'filename.extension'} = $2;
        $$data{'filename'} = $1;
    }

    # получение записи
    unless ( @mess ) {
        @media = $self->_get_media( $data, [] );
        push @mess, "Can not get file" unless @media;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = \@media if @media;
    $self->render( 'json' => $resp );
}

sub update {
    my $self = shift;

    my ( $data, $error, $url, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # обновление записи
    unless ( @mess ) {
        ( $url, $error ) = $self->_update_media( $data );
        push @mess, $error unless $url;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'url'} = $url if $url;

    $self->render( 'json' => $resp );
}

1;