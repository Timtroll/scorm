package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my ( $data, $error, $result, $local_path, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    $local_path = './upload/';

    unless ( @mess ){
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ){
        $result = write_file( $local_path . $$data{ 'filename' }, $$data{ 'content' } );
        push @mess, "Could not write $$data{'title'}" unless $result;
    }

    unless ( @mess ){
        $result = $self->_insert_media( $data );
        push @mess, "Could not insert $$data{'title'}" unless $result;
    }

    $self->render(
        'json'    => {
            'controller'    => 'upload',
            'route'         => 'index',
            'status'        => 'ok'
        }
    );
}

1;