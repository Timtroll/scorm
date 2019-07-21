package validate;

use open qw(:utf8);
binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

use utf8;
use warnings;
use strict;

use common;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK);

@ISA = qw( Exporter );
@EXPORT = qw( &prepare_validate &validate );

use Data::Dumper;

# prepare validate functions
sub prepare_validate {
    foreach my $key (keys %{$$config{'validate'}}) {
        $$clear{$key} = sub {
            my ($name, $data, $error);
            $name = shift;
            $data = shift;

            unless ($data) { return 0; }
            unless ($name) { $name = time(); }

            unless ($data =~ m/$$config{'validate'}{$key}/) {
                $error = `date`." : Incorrect '$key' input data='$data'; ";
                $error =~ s/(\n|\r)//g;
                # $$error_input{$name} = $error;

                return;
            }
            return $data;
        }
    }
}

sub validate {
    my ($self, $type, $field) = @_;

    unless ( $field =~ /^status/)  {
        unless ( exists $$config{'validate'}{$type} ) {
            # $$error_input{$field} = 'Unknown validate type';
            return 0;
        }

        if ( $self->param($field) ) {
            my $res = $$clear{$type}($field, $self->param($field));

            return $res;
        }
    }
    else {
        my $out = 0;
        if ($self->param($field)) {
            $out = 1;
        }
        return $out;
    }

    return 0;
}

1;
