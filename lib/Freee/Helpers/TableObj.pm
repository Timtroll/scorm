package Freee::Helpers::TableObj;

use utf8;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Data::Dumper;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Creating table structures

    $app->helper( 'table_obj' => sub {
        my ( $self, $params ) = @_ ;

        return {} unless ($$params{'body'} || ref $$params{'body'} ne 'ARRAY');

        # дефолтные установки, если не заданы в $params
        my $table;
        $$table{'settings'}{'readOnly'} = 0 unless $$params{'settings'}{'readOnly'};
        $$table{'settings'}{'editable'} = 1 unless $$params{'settings'}{'editable'};
        $$table{'settings'}{'removable'} = 1 unless $$params{'settings'}{'removable'};
        $$table{'settings'}{'massEdit'} = 0 unless $$params{'settings'}{'massEdit'};
        $$table{'settings'}{'totalCount'} = scalar( @{$$params{'body'}} );

        # выводим все колонки, если не заданы в $params
        unless ( @{$$params{'header'}} || !$$params{'header'} ) {
            foreach my $head (ksort {$a <=> $b} keys %{$$params{'body'}[0]}) {
                push @{$$table{'header'}}, {
                    'key'   => $head,
                    'label' => $head,
                };
            }
            $$table{'body'} = $$params{'body'};
        }
        else {
            $$table{'header'} = $$params{'header'};
            foreach my $tab (sort {$a <=> $b} @{$$params{'body'}}) {
                my %tab = ();
                foreach my $header (sort {$a <=> $b} @{$$params{'header'}}) {
                    $tab{$$header{'key'}} = $$tab{$$header{'key'}};
                }
                push @{$$table{'body'}}, \%tab;
            }
        }

        return $table;
    });
}

1;
