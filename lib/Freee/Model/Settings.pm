package Freee::Model::Settings;

use Mojo::Base 'Freee::Model::Base';
use Data::Dumper;

###################################################################
# таблица настроек
###################################################################

# получить дерево настроек
# my $true = $self->get_tree(1); - без листьев
# my $true = $self->get_tree();  - c листьями
sub get_tree {
    my $self = shift;
    my $no_children = shift;

    my ( $list, $sql );
    if ( $no_children ) {
        $sql = 'SELECT id, label, name, parent, 1 as folder FROM "public".settings where id IN (SELECT DISTINCT parent FROM "public".settings) OR parent=0 ORDER by id';
    }
    else {
        $sql = 'SELECT id, label, name, parent FROM "public".settings ORDER by id';
    }

# напрягает eval ???
    eval {
        $list = $self->{dbh}->selectall_arrayref( $sql, { Slice => {} } );
    };
    warn $@ if $@;
    return if $@;

    $list = $self->{app}->_list_to_tree($list, 'id', 'parent', 'children');

    return $list;

    # return $self->app->config;
}

1;