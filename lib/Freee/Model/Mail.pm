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
        From    => $$data{'from'},
        To      => $$data{'to'},
        Subject => $$data{'subject'},
      ],
      attributes => {
        encoding => 'quoted-printable',
        charset  => 'utf-8',
      },
      body_str => $$data{'body'}
    );

    $user = $settings->{'Username'};
    $pass = $settings->{'Password'};
    $host = $settings->{'Host'};

    $smtp = Net::SMTP::SSL->new($host, Port=>465) or die "Can't connect";
    $smtp->auth($user, $pass) or die "Can't authenticate:".$smtp->message();
    $smtp->mail( $$data{'from'} ) or die "Error:".$smtp->message();
    $smtp->to( $$data{'to'} ) or die "Error:".$smtp->message();
    $smtp->data() or die "Error:".$smtp->message();
    $smtp->datasend($msg->as_string) or die "Error:".$smtp->message();
    $smtp->dataend() or die "Error:".$smtp->message();
    $smtp->quit() or die "Error:".$smtp->message();

    return 1;
}

1;