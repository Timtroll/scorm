package Freee::Model::Users;

use Mojo::Base 'MojoX::Model';

sub check {
  my ($self, $name, $pass) = @_;
warn 'Users = check';
  # Constant
  return int rand 2;
  # return int rand 2;

  # Or Mojo::Pg
  # return $self->app->pg->db->query('...')->array->[0];

  # Or HTTP check
  # return $self->app->ua->post($url => json => {user => $name, pass => $pass})->res->tx->json('/result');
}

1;