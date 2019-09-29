package Freee::Helpers::TableObj;

use utf8;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Data::Dumper;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Creating table structures for vue

    $app->helper( '_table_obj' => sub {
        my ( $self, $params ) = @_ ;

        return {} unless ($$params{'body'} || ref $$params{'body'} ne 'ARRAY');

        # дефолтные установки, если не заданы в $params
        my $table;
        $$table{'settings'}{'readonly'} = 0 unless $$params{'settings'}{'readonly'};
        $$table{'settings'}{'removable'} = 1 unless $$params{'settings'}{'removable'};
        $$table{'settings'}{'massEdit'} = 0 unless $$params{'settings'}{'massEdit'};
        $$table{'settings'}{'totalCount'} = scalar( @{$$params{'body'}} );

        # выводим все колонки, если не заданы в $params
        unless ( @{$$params{'header'}} || !$$params{'header'} ) {
            foreach my $head (sort {$a cmp $b} keys %{$$params{'body'}[0]}) {
                push @{$$table{'header'}}, {
                    'key'   => $head,
                    'label' => $head,
                };
            }
            $$table{'body'} = $$params{'body'};
        }
        # выводим указанные колонки, а вот данные выводим все
        else {
            $$table{'header'} = $$params{'header'};
            $$table{'body'} = $$params{'body'};
        }

        return $table;
    });
}

1;
