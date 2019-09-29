package Freee::Helpers::Proto;

use utf8;
use strict;
use warnings;

use base 'Mojolicious::Plugin';

use common;

sub register {
    my ($self, $app) = @_;

    $app->helper( '_proto_leaf' => sub {
        my $self = shift;
        my $table = shift;

        my $list = $self->pg_dbh->selectall_arrayref(
            "SELECT column_name, data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '$table'",
            {}
        );

        my %field_types =(
            'id'            => 'InputNumber',
            'name'          => 'InputText',
            'label'         => 'InputText',
            'mask'          => 'InputText',
            'placeholder'   => 'InputText',
            'readonly'      => 'InputBoolean',
            'required'      => 'InputBoolean',
            'selected'      => 'InputDoubleList',
            'type'          => 'InpuType',
            'value'         => 'InputText',
            'parent'        => 'InputNumber'
        );
        my $out = [];
        foreach my $col (@$list) {
            my $proto = {
                "name"          => $$col[0],
                "label"         => "",
                "mask"          => "",
                "placeholder"   => "",
                "readonly"      => 0,
                "required"      => 1,
                "selected"      => "[]",
                # "type"          => "InputNext",
                "type"          => $field_types{$$col[0]},
                "value"         => ""
            };
            push @{$out}, $proto;
        }

        return $out;

    });

    $app->helper( '_input_components' => sub {
        return $config->{'inputComponents'};
    });
}

1;