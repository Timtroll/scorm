package Freee::Model::EAV;

use Mojo::Base -base;
use Scalar::Util 'weaken';

# has 'eav';

# sub new {
#     my $class = shift;

#     if (ref $class && $class->isa(__PACKAGE__)) {
#         scalar( @_ ) == 1 ? $_[0]->{eav} = $class->{eav} : push @_, eav => $class->{eav};
#     }

#     my $self = $class->SUPER::new(@_);
#     weaken $self->{eav};

#     return $self;
# }

sub check {
    my ($self, $name, $pass) = @_;
warn 'Model::EAV sub check()';
    # Constant
    return int rand 2;
    # return int rand 2;

    # Or Mojo::Pg
    # return $self->eav->pg->db->query('...')->array->[0];

    # Or HTTP check
    # return $self->eav->ua->post($url => json => {user => $name, pass => $pass})->res->tx->json('/result');
}

1;