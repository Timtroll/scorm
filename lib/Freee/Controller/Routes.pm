package Freee::Controller::Routes;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Freee::Model::Utils;
use Encode;

use common;

use Data::Dumper;

# вывод списка роутов группы в виде объекта 
#    "label"       => "scorm",
#    "id"          => 1,
#    "component"   => "Routes",
#    "opened"      => 0,
#    "folder"      => 0,
#    "keywords"    => "",
#    "children"    => [],
#    "table"       => {}
sub index {
    my $self = shift;

    my ( $list, $data, $table, $resp, @list );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@!) {
        # проверка данных
        $data = $self->_check_fields();

        # проверка существования роута указанной группы
        unless ( @! ) {
            if ( $self->model('Utils')->_exists_in_table('groups', 'id', $$data{'parent'}) ) {
                # список роутов указанной группы
                $list = $self->model('Routes')->_routes_list( $$data{'parent'} );
                if ( %$list ) {
                    foreach ( sort { $a <=> $b } keys %$list ) {
                        push @list, $$list{ $_ };
                    }
                    $list = \@list;
                }

                # данные для таблицы
                $table = {
                    "settings" => {
                        "massEdit"  => 0,        # групповое редактировани
                        "editable"  => 0,        # разрешение редактирования
                        "removable" => 0,        # разрешение удаления
                        "sort" => {         # сотрировка по
                            "name"    => "name",
                            "order"   => "asc"
                        },
                        "page" => {
                          "current_page"    => 1,
                          "per_page"        => 100,
                          "total"           => scalar(@$list)
                        }
                    },
                    "body" => $list
                } unless @!;
            }
            else {
                push @!, "Routes for Group id '$$data{'parent'}' is not exists";
            }
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $table unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получение данных о роуту
# my $row = $self->edit()
# 'id' - id роута
sub edit {
    my $self = shift;

    my ( $id, $data, $result, $resp );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();

        unless ( @! ) {
            $result = $self->model('Routes')->_get_route( $$data{'id'} );
            push @!, "Could not get Route '$$data{'id'}'" unless $result;
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# обновление роута
# my $id = $self->save();
# "id"          => 1            - id обновляемого элемента ( >0 )
# "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
# "label"       => 'название',  - обязательно (название для отображения)
# "name",       => 'name'       - обязательно (системное название, латиница)
# "publish"      => 0,           - по умолчанию 1
# "readonly"    => 0,           - не обязательно, по умолчанию 0
# "value"       => "",          - строка или json
# "required"    => 0            - не обязательно, по умолчанию 0
sub save {
    my ($self) = shift;

    my ( $id, $data, $resp );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();

        # проверка существования обновляемой строки
        unless ( @! ) {
            if ( $self->model('Utils')->_exists_in_table('routes', 'id', $$data{'id'}) ) {
                # обновление данных группы
                $id = $self->model('Routes')->_update_route( $data );
                push @!, "Could not update Route named '$$data{'name'}'" unless $id;
            }
            else {
                push @!, "Route '$$data{'id'}' is not exists";
            }
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ( $toggle, $resp, $data );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    # проверка данных
    $data = $self->_check_fields() unless @!;

    unless ( @! ) {
        $$data{'table'} = 'routes';

        # проверка существования элемента для изменения
        unless ($self->model('Utils')->_exists_in_table('routes', 'id', $$data{'id'})) {
            push @!, "Id '$$data{'id'}' doesn't exist";
        }
        # изменение поля
        unless ( @! ) {
            $toggle = $self->model('Utils')->_toggle( $data );
            push @!, "Could not toggle '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
