package Freee::Helpers::Tree;

use utf8;
use strict;
use warnings;

use base 'Mojolicious::Plugin';

use constant DEBUGGING => 0;

sub register {
    my ($self, $app) = @_;

    $app->helper( '_list_to_tree' => sub {
        my ($self, $list, $idField, $parentField, $startId, $TreeChildrenKey) = @_;

        $TreeChildrenKey ||= 'children';
        $idField ||= 'id';
        $parentField ||= 'parent';
        return () unless ($list);

        my $root_id = -1;

        warn "Using id field $idField and parent field $parentField\n" if DEBUGGING;

        # If given a startId the find that object in the list and ensure that
        # that is processed first.  Patch from Kevin White [kevin.white/oupjournals-org]
        if ( defined $startId ) {
            for ( my $i = 0; $i < scalar @{$list}; $i++ ) {
                if ( ${$list}[$i]->{$idField} =~ /^$startId$/ ) {
                    unshift( @{$list}, splice( @{$list}, $i, 1 ) );
                    last;
                }
            }
        }

        my @tree;
        my %index;
        # Put objects into a nested tree structure
        foreach my $obj (@{$list}) {
            $obj->{'keywords'} = $obj->{'label'};
            $obj->{folder} = 0;
            die "list_to_tree:  Object undefined\n" unless $obj;
            my $id = $obj->{$idField} || die "list_to_tree:  No $idField in object\n";
            my $pid = $obj->{$parentField} || $id;

            if ($root_id == -1) {
                $pid = $id;
                $root_id = $id;
            }

            warn "Adding object #$id to parent #$pid\n" if DEBUGGING;

            # Add object node to index
            if (defined $index{$id}) {
                if (defined $index{$id}->{$idField}) {
                    warn "_list_to_tree:  Duplicate object $id.\n";
                    return [];
                }
                else {
                    $obj->{$TreeChildrenKey} = $index{$id}->{$TreeChildrenKey};
                    $index{$id} = $obj;
                }
            }
            else {
                $index{$id} = $obj;
            }

            # If this is a root object, put into tree directly

            if ($id == $pid) {
                warn "Adding $id to tree\n" if DEBUGGING;
                push @tree, $obj;

                warn "Now there are ", $#tree + 1, " items in tree\n" if DEBUGGING;
            }
            # Add it as a child of the appropriate parent object
            else {
                warn "Adding $id as child of $pid\n" if DEBUGGING;
                $index{$pid}->{folder} = 1;
                push @{$index{$pid}->{$TreeChildrenKey}}, $obj;
            }
        }   

        warn "Tree:  @tree  (", $#tree+1, " items)\n" if DEBUGGING;

        return \@tree;
    });
}

1;
