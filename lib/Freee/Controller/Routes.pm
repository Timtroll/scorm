package Freee::Controller::Routes;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
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

    my ( $list, $data, $table, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Gruop id '$$data{'parent'}'" unless $data;

        # проверка существования роута указанной группы
        unless (@mess) {
            if ( $self->_exists_in_table('routes', 'parent', $$data{'parent'}) ) {
                # список роутов указанной группы
                $list = $self->_routes_list( $$data{'parent'} );
                push @mess, "Could not get list Routes for group '$$data{'parent'}'" unless $list;

                # данные для таблицы
                $table = {
                    "settings" => {
                        "massEdit" => 1,    # групповое редактировани
                        "sort" => {         # сотрировка по
                            "name"    => "id",
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






    # # читаем роуты из базы
    # unless ( $list = $self->_routes_list() ) {
    #     push @mess, "Can not get list of routes";
    # }

    # $set = [];
    # unless (@mess) {
    #     # формируем данные для вывода
    #     foreach (sort {$a <=> $b} keys %$list) {
    #         my $row = {
    #             'id'        => $_,
    #             'label'     => $$list{$_}{'label'},
    #             'component' => "Groups",
    #             'opened'    => 0,
    #             'folder'    => 1,
    #             'keywords'  => "",
    #             'children'  => [],
    #             'table'     => {}
    #         };
    #         push @{$set}, $row;
    #     }
    # }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $table unless @mess;

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

    my ( $id, $data, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Route data '$$data{'name'}'" unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->_exists_in_table('routes', 'id', $$data{'id'}) ) {
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

    my ($toggle, $resp, $data, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Group '$$data{'id'}'" unless $data;

        $toggle = $self->_toggle_route( $data ) unless @mess;
        push @mess, "Could not toggle Group '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}

1;
