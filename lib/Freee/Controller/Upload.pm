package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my ( $data, $error, $result, $local_path, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    $local_path = $self->{ 'app' }->{ 'config' }->{ 'upload_local_path' };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        $result = write_file( $local_path . $$data{ 'filename' } . '.' . $$data{ 'extension' }, $$data{ 'content' } );
        push @mess, "Can not write $$data{'title'}" unless $result;
    }

    unless ( @mess ) {
        $result = $self->_insert_media( $data );
        push @mess, "Can not insert $$data{'title'}" unless $result;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my ( $data, $error, $result, $resp, $filename, $fileinfo, $cmd, $local_path, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

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

    my ( $data, $error, $media, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверка данных
        unless ( $$data{'id'} || $$data{'filename'} ) {
            push @mess, 'no data for search!';
        }
    }

    if ( ( $$data{'filename'} ) && ( $$data{'filename'} =~ m/\./ ) ){
        $$data{'filename'} =~ /^(.*?)\.(.*?)$/;
        $$data{'extension'} = $2;
        $$data{'filename'} = $1;
    }

    unless ( @mess ) {
        $media = $self->_get_media( $data, [] );
        push @mess, "Can not get file" unless $media;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $media if $media;
    $self->render( 'json' => $resp );
}

sub update {
    my $self = shift;

    my ( $data, $error, $update, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        $update = $self->_update_media( $data );
        push @mess, "Can not update file" unless $update;
        push @mess, "Id doesn't exist" if $update eq '0E0';
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

1;