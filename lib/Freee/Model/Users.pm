package Freee::Model::Users;

use Mojo::Base -base;
use Scalar::Util 'weaken';

has 'app';

sub new {
    my $class = shift;

    if (ref $class && $class->isa(__PACKAGE__)) {
      @_ == 1 ? $_[0]->{app} = $class->{app} : push @_, app => $class->{app};
    }

    my $self = $class->SUPER::new(@_);
    weaken $self->{app};
    return $self;
}


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