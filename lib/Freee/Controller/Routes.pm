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

    my ( $list, $data, $error, $table, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        # проверка существования роута указанной группы
        unless (@mess) {
            if ( $self->model('Utils')->_exists_in_table('groups', 'id', $$data{'parent'}) ) {
                # список роутов указанной группы
                $list = $self->_routes_list( $$data{'parent'} );
                push @mess, "Could not get list Routes for group '$$data{'parent'}'" unless $list;

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
                } unless @mess;
            }
            else {
                push @mess, "Routes for Group id '$$data{'parent'}' is not exists";
            }
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $table unless @mess;

    $self->render( 'json' => $resp );
}

# получение данных о роуту
# my $row = $self->edit()
# 'id' - id роута
sub edit {
    my $self = shift;

    my ($id, $data, $error, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_route( $$data{'id'} );
            push @mess, "Could not get Route '$$data{'id'}'" unless $data;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

# обновление роута
# my $id = $self->save();
# "id"          => 1            - id обновляемого элемента ( >0 )
# "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
# "label"       => 'название',  - обязательно (название для отображения)
# "name",       => 'name'       - обязательно (системное название, латиница)
# "status"      => 0,           - по умолчанию 1
# "readonly"    => 0,           - не обязательно, по умолчанию 0
# "value"       => "",          - строка или json
# "required"    => 0            - не обязательно, по умолчанию 0
sub save {
    my ($self) = shift;

    my ( $id, $data, $error, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->model('Utils')->_exists_in_table('routes', 'id', $$data{'id'}) ) {
                # обновление данных группы
                $id = $self->_update_route( $data );
                push @mess, "Could not update Route named '$$data{'name'}'" unless $id;
            }
            else {
                push @mess, "Route '$$data{'id'}' is not exists";
            }
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ($toggle, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'table'} = 'routes';
        $toggle = $self->model('Utils')->_toggle( $data ) unless @mess;
        push @mess, "Could not toggle Group '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}

1;
