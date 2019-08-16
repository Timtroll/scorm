package Freee::Helpers::TableObj;

use utf8;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Data::Dumper;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Postgress

    $app->helper( 'table_obj' => sub {
        my ( $self, $params ) = @_ ;

        return {} unless $$params{'body'} || ref $$params{'body'} eq 'ARRAY';

        # дефолтные установки, если не заданы в $params
        my $table;
        $$table{'settings'}{'readOnly'} = 0 unless $$params{'settings'}{'readOnly'};
        $$table{'settings'}{'editable'} = 1 unless $$params{'settings'}{'editable'};
        $$table{'settings'}{'removable'} = 1 unless $$params{'settings'}{'removable'};
        $$table{'settings'}{'massEdit'} = 0 unless $$params{'settings'}{'massEdit'};
        $$table{'settings'}{'totalCount'} = scalar( @{$$params{'body'}} );

        # выводим все колонки, если не заданы в $params
        unless ($$params{'header'}) {
            foreach my $head (@{$$table{'body'}[0]}) {
                push @{$$table{'header'}}, {
                    'key'   => $$head{'name'},
                    'label' => $$head{'label'},
                };
            }
        }
        $$table{'table'} = $$params{'body'};

        # my $table->{'header'} = [
        #     { "key" => "name",          "label" => "Расшифровка" },
        #     { "key" => "label",         "label" => "Расшифровка" },
        #     { "key" => "value",         "label" => "Расшифровка" },
        #     { "key" => "type",          "label" => "Расшифровка" },
        #     { "key" => "placeholder",   "label" => "Расшифровка" },
        #     { "key" => "mask",          "label" => "Расшифровка" },
        #     { "key" => "selected",      "label" => "Расшифровка" },
        #     { "key" => "editable",      "label" => "Расшифровка" }
        # ];
        # $table->{'body'} = [
        #     {
        #         "name"          => "fullDebugMode",
        #         "label"         => "режим обновления",
        #         "value"         => "",
        #         "type"          => "InputNumber",
        #         "placeholder"   => "",
        #         "mask"          => "",
        #         "selected"      => "",
        #         "editable"      => 1
        #     }
        # ];
        # $table->{'settings'} = {
        #     "readOnly"    => 0,
        #     "totalCount"  => scalar(@{$table->{'body'}}),
        #     "editable"    => 1,
        #     "removable"   => 1,
        #     "massEdit"    => 0
        # };
 
        # foreach my $row (@{$table->{'body'}}) {

        # }

        return $table;
    });
}

1;
