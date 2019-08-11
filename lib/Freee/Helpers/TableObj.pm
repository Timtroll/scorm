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
        my ( $self, $Params ) = @_ ;


        my $table->{'header'} = [
            { "key" => "name",          "label" => "Расшифровка" },
            { "key" => "label",         "label" => "Расшифровка" },
            { "key" => "value",         "label" => "Расшифровка" },
            { "key" => "type",          "label" => "Расшифровка" },
            { "key" => "placeholder",   "label" => "Расшифровка" },
            { "key" => "mask",          "label" => "Расшифровка" },
            { "key" => "selected",      "label" => "Расшифровка" },
            { "key" => "editable",      "label" => "Расшифровка" }
        ];
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

        return $table->{'header'};
        # return $table->{'body'}[0];
    });
}

1;
