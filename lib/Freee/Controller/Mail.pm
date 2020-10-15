package Freee::Controller::Mail;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw( from_json to_json );

use Data::Dumper;

sub index {
    my $self = shift;

    $self->render(
        'template'      => 'mail/greeting'
        # 'template'      => 'index'
    );
}

sub send_mail {
    my $self = shift;
    my ( $data, $files, $resp );

    # # проверка данных
    # $data = $self->_check_fields();

    if ( $self->param( 'files' ) ) {
        # проверка существования загружаемых фото
        $files = from_json( $self->param( 'files' ) );
        foreach ( @$files ) {
            unless( $self->model('Utils')->_exists_in_table('media', 'id', $_ ) ) {
                push @!, "file with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! ) {
        $data = {
            'to'       => $self->param( 'to' ),
            'copy'     => $self->param( 'copy' ),         # не обязательно
            'from'     => $self->param( 'from' ),         # по умолчанию из настроек
            'subject'  => $self->param( 'subject' ),
            'body'     => $self->param( 'body' ),
            'files'    => $files                          # не обязательно
        };

        # отправка письма
        $resp->{'result'} = $self->model('Mail')->_send_mail( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();

    $self->render( 'json' => $resp );
}

1;