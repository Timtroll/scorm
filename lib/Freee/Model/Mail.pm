package Freee::Model::Mail;

use Mojo::Base 'Freee::Model::Base';

use Email::MIME;
use Net::SMTP::SSL;
use common;

use Data::Dumper;

sub _send_mail {
    my ( $self, $data ) = @_;

    my ( $msg, $user, $pass, $host, $smtp );

    $msg = Email::MIME->create(
      header_str => [
        From    => $settings->{'Username'} . '@yandex.ru',
        To      => $$data{'to'},
        Subject => $$data{'subject'},
      ],
      attributes => {
        content_type => 'text/html',
        encoding     => 'quoted-printable',
        charset      => 'utf-8',
      },
      body_str => $$data{'email_body'},
    );

    $user = $settings->{'Username'};
    $pass = $settings->{'Password'};
    $host = $settings->{'Host'};

    unless ( $smtp = Net::SMTP::SSL->new($host, Port=>465) ) {
        push @!, "Can't connect";
        return;
    }
    unless (    $smtp->auth($user, $pass) ) {
        push @!, "Can't authenticate:".$smtp->message();
        return;
    }
    unless ( $smtp->mail( $settings->{'Username'} . '@yandex.ru' ) ) {
        push @!, "Error:".$smtp->message();
        return;
    }
    unless ( $smtp->to( $$data{'to'} ) ) {
        push @!, "Error:".$smtp->message();
        return;
    }
    unless ( $smtp->data() ) {
        push @!, "Error:".$smtp->message();
        return;
    }
    unless ( $smtp->datasend($msg->as_string) ) {
        push @!, "Error:".$smtp->message();
        return;
    }
    unless ( $smtp->dataend() ) {
        push @!, "Error:".$smtp->message();
        return;
    }
    unless ( $smtp->quit() ) {
        push @!, "Error:".$smtp->message();
        return;
    };

    return 1;
}

1;