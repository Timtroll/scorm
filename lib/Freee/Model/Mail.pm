package Freee::Model::Mail;

use Mojo::Base 'Freee::Model::Base';

use Email::MIME;
use Data::Dumper;

sub _send_mail {
    my ( $self, $data ) = @_;

    warn Dumper( $data );

    my $message = Email::MIME->create(
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

    warn Dumper( $message );
    return 1;
}

1;