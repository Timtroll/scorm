package Freee::Helpers::Utils;

use utf8;
use strict;
use warnings;

use base 'Mojolicious::Plugin';

use common;
use Data::Dumper;

use constant DEBUGGING => 0;

sub register {
    my ($self, $app) = @_;

    # построение дерева по плоской таблице с парентами
    # $self->_list_to_tree(<list>, <id_field>, <parent>, <start_id>, <children_key>);
    # <list>        - ссылка на массив, из которого строим дерево
    # <id_field>    - название поля, которе содержит id записи
    # <parent>      - название поля, которе содержит parent записи
    # <start_id>    - с какого id начинаем строить дерево (id корня дерева)
    # <children_key> - название поля, в которое кладем дочерние объекты
    $app->helper( '_list_to_tree' => sub {
        my ($self, $list, $id_field, $parent_field, $start_id, $children_key) = @_;

        $children_key ||= 'children';
        $id_field ||= 'id';
        $parent_field ||= 'parent';
        return () unless ($list);

        my $root_id = -1;

        warn "Using id field $id_field and parent field $parent_field\n" if DEBUGGING;

        if ( defined $start_id ) {
            for ( my $i = 0; $i < scalar @{$list}; $i++ ) {
                if ( ${$list}[$i]->{$id_field} =~ /^$start_id$/ ) {
                    unshift( @{$list}, splice( @{$list}, $i, 1 ) );
                    last;
                }
            }
        }

        my (@tree, %index);
        # построение дерева
        foreach my $obj (@{$list}) {
            $obj->{'keywords'} = $obj->{'label'};
            # $obj->{folder} = 0;
            die "_list_to_tree:  Object undefined\n" unless $obj;

            my $id = $obj->{$id_field} || die "_list_to_tree: No $id_field in object\n";
            my $pid = $obj->{$parent_field} || $id;

            if ($root_id == -1) {
                $pid = $id;
                $root_id = $id;
            }

            warn "Adding object #$id to parent #$pid\n" if DEBUGGING;

            # добавляем объект в индекс
            if (defined $index{$id}) {
                if (defined $index{$id}->{$id_field}) {
                    warn "_list_to_tree: Duplicate object $id.\n";
                    return [];
                }
                else {
                    $obj->{$children_key} = $index{$id}->{$children_key};
                    $index{$id} = $obj;
                }
            }
            else {
                $index{$id} = $obj;
            }

            # если это корневой объект, сразу кладем его в дерево
            if ($id == $pid) {
                warn "Adding $id to tree\n" if DEBUGGING;
                push @tree, $obj;

                warn "Now there are ", $#tree + 1, " items in tree\n" if DEBUGGING;
            }
            # иначе добавляем его как дочерний элемент
            else {
                warn "Adding $id as child of $pid\n" if DEBUGGING;
                # $index{$pid}->{folder} = 1;
                push @{$index{$pid}->{$children_key}}, $obj;
            }
        }   

        warn "Tree: @tree (", $#tree + 1, " items)\n" if DEBUGGING;

        return \@tree;
    });

    # генерация строки из случайных букв и цифр
    # my $string = _random_string( length );
    # возвращается строка
    $app->helper('_random_string' => sub {
        my ( $self, $length ) = @_;

        return unless $length =~ /^\d+$/;

        my @chars = ( "A".."Z", "a".."z", 0..9 );
        my $string = join("", @chars[ map { rand @chars } ( 1 .. $length ) ]);

    });

    # проверка на наличие файла в директории
    # my $true = _exists_in_directory( directory/file.extension );
    # возвращается true/false
    $app->helper('_exists_in_directory' => sub {
        my ($self, $directory) = @_;

        return unless $directory;

        return -f $directory;
    });

    # установить в маске статус active
    $app->helper('_activate' => sub {
        my ($self, $mask, $field) = @_;

        if (exists $self->config->{UsersFlags}->{$field}) {
            # $mask |= $UsersFlags->{$field};
            return $mask;
        }

        return;
    });

    # установить в маске статус suspend
    $app->helper('_suspend' => sub {
        my ($self, $mask, $field) = @_;

        if (exists $self->config->{UsersFlags}->{$field}) {
            # $mask &= $UsersFlags->{$field};
            return $mask;
        }

        return;
    });

    $app->helper('_get_time' => sub {

        # my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime( time + 3 * 60 * 60 );
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime( time );
        my $nice_timestamp = sprintf ( "%04d%02d%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min,$sec );
        return $nice_timestamp;
    });
}
1;