package Freee::Model::MyModel;

use Mojo::Base 'Freee::Model::Base';

# получить все данные из конфига
sub get_config_data {
    my $self = shift;
# use Data::Dumper;
# warn Dumper $self;
    return $self->app->config;
}

sub get_ {
    my $self = shift;
warn '==get==';
use Data::Dumper;
warn Dumper $self->{dbh};
warn '==get==';
    return [ keys %{$self->app} ];
    # return ;
}

1;