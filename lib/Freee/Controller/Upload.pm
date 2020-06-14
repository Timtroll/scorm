package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my ( $data, $error, $result, $filename, $resp, $url, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {

        # генерация случайного имени
        my $name_length = $self->{'app'}->{'settings'}->{'upload_name_length'};
        $filename = $self->_random_string( $name_length );

        while ( $self->_exists_in_directory( './upload/'.$fullname ) ) {
            $filename = $self->_random_string( $name_length );
        }
        # путь файла
        $$data{ 'path' } = 'local';

        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

        # получение mime
        $$data{'mime'} = $$mime{$$data{'extension'}} || '';

        # запись файла
        $result = write_file(
            $self->{'app'}->{'settings'}->{'upload_local_path'} . $filename . '.' . $$data{'extension'},
            $$data{'content'}
        );
        push @mess, "Can not write $$data{'title'}" unless $result;

        unless ( @mess ) {
            # ввод данных в таблицу
            ( $result, $error ) = $self->_insert_media( $data );
            push @mess, $error unless $result;

                # получение url
            unless ( @mess ) {
                $url = $self->{'app'}->{'settings'}->{'site_url'} . $self->{'app'}->{'settings'}->{'upload_url_path'} . $filename . '.' . $$data{ 'extension' };
            }
        }
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'id'} = $result if $result;
    $resp->{'mime'} = $$data{'mime'} if $result;
    $resp->{'url'} = $url if $result;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

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

    my ( $data, $error, $resp, $url, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # получение записи
    unless ( @mess ) {
        ( $data, $error ) = $self->_get_media( $data, [] );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @mess;
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

    unless ( @mess ) {
        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

        # обновление записи
        ( $data, $error ) = $self->_update_media( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'id'} = $$data{'id'} unless @mess;
    $resp->{'mime'} = $$data{'mime'} unless @mess;
    $resp->{'url'} = $$data{'id'} unless @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

1;