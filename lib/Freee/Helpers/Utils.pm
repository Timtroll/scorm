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

    # проверяем наличие таблицы и указанное поле на дубликат
    # my $row = $self->_exists_in_table(<table>, '<id>', <value>, <excude_id>);
    #  <table>       - имя таблицы, где будем искать
    #  <id>         - название поле, которое будем искать
    #  <value>      - значение поля, которое будем искать
    #  <excude_id>  - исключаем указанный id
    # возвращается 1/undef
    $app->helper( '_exists_in_table' => sub {
        my ($self, $table,  $name, $val, $excude_id) = @_;

        return unless $name;

        # Проверяем наличие таблицы в базе данных
        my $sql = "SELECT count(*) FROM pg_catalog.pg_tables WHERE schemaname != 'information_schema' and schemaname != 'pg_catalog' and tablename = '".$table."'";
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;
        return unless $row->{'count'};

        # проверяем поле name на дубликат
        $sql = "SELECT id FROM \"public\".".$table." WHERE \"".$name."\"='".$val."'";
        # исключаем из поиска id
        $sql .='AND "id"<>'.$excude_id if $excude_id;

        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

        return $row;
    });

    # включение/отключение (1/0) определенного поля в указанной таблице по id
    # my $true = $self->_toggle_route( <table>, <id>, <field>, <val> );
    # <id>    - id записи 
    # <field> - имя поля в таблице
    # <val>   - 1/0
    # возвращается true/false
    $app->helper( '_toggle' => sub {
        my ($self, $data) = @_;

        return unless $data;
        return unless ($$data{'table'} || $$data{'id'} || $$data{'value'} || $$data{'fieldname'});

        my $result;
        my $sql ='UPDATE "public"."'.$$data{'table'}.'" SET "'.$$data{'fieldname'}.'"='.$$data{'value'}.' WHERE "id"='.$$data{'id'};
        eval {
            $result = $self->pg_dbh->do($sql) + 0;
        };
        warn $@ if $@;
        return if $@;

        return $result;
    });

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
            $obj->{folder} = 0;
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
                $index{$pid}->{folder} = 1;
                push @{$index{$pid}->{$children_key}}, $obj;
            }
        }   

        warn "Tree: @tree (", $#tree + 1, " items)\n" if DEBUGGING;

        return \@tree;
    });

    # получение значения поля folder по id
    # my $true = folder_check( <id> );
    # возвращается 1/0
    $app->helper('_folder_check' => sub {
        # my $id = shift;
        my ($self, $id) = @_;

        return unless $id;

        my $result;
        my $sql = 'SELECT folder FROM "public"."settings" WHERE "id"='.$id;
        eval {
            $result = $self->pg_dbh->selectrow_array($sql);
        };
        warn $@ if $@;

        return $result ? $result : 0;
    });

    # генерация строки из случайных букв и цифр
    # my $string = _random_string( length );
    # возвращается строка
    $app->helper('_random_string' => sub {
        my ($self, $length) = @_;

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
}

1;