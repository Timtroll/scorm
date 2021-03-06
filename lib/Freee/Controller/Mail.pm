package Freee::Controller::Mail;

use utf8;
use strict;
use warnings;

use Encode;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw( decode_json );

use Data::Dumper;

sub index {
    my $self = shift;

    $self->render(
        'template' => 'mail/greeting'
    );
}

sub send_mail {
    my $self = shift;
    my ( $data, $files, $params, $email_body, $resp, $result );

    if ( $self->param( 'files' ) ) {
        # проверка существования загружаемых фото
        $files = decode_json( $self->param( 'files' ) );
        foreach ( @$files ) {
            unless( $self->model('Utils')->_exists_in_table('media', 'id', $_ ) ) {
                push @!, "file with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! ) {
        $$params{'body'}      = $self->param( 'body' );
        $$params{'to'}        = $self->param( 'to' );
        $$params{'signature'} = $self->param( 'signature' );
        $$data{'email_body'} = $self->render_to_string(
            'template'   => 'mail/' . $self->param( 'template' ),
            'email_text' => $params
        );
        push @!, "can't render template" unless $$data{'email_body'};
    }

    unless ( @! ) {
            $$data{'to'}       = $self->param( 'to' );
            $$data{'subject'}  = $self->param( 'template' );
            $$data{'body'}     = $self->param( 'body' );
            $$data{'files'}    = $files;                          # не обязательно

        # отправка письма
        $result = $self->model('Mail')->_send_mail( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'result'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;