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
    my ( $self, $no_children ) = @_;

    my ( $list, $sql );
    if ( $no_children ) {
        $sql = 'SELECT id, label, name, parent, 1 as folder FROM "public".settings where id IN (SELECT DISTINCT parent FROM "public".settings) OR parent=0 ORDER by id';
    }
    else {
        $sql = 'SELECT id, label, name, parent FROM "public".settings ORDER by id';
    }

    $list = $self->{app}->pg_dbh->selectall_arrayref( $sql, { Slice => {} } );

    $list = $self->{app}->_list_to_tree($list, 'id', 'parent', 'children');

    return $list;

    # return $self->app->config;
}

1;