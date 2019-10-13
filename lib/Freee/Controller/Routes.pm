package Freee::Controller::Routes;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;
use common;

# вывод списка роутов в виде объекта 
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
    my ( $list, $set );

    # читаем руты из базы
    unless ( $list = $self->_routes_values() ) {
        return "Can't connect to the database";
    }

    # формируем данные для вывода
    foreach my $id (sort {$a <=> $b} keys %$list) {
        my $row = {
            'id'        => $id,
            'label'     => $$list{$id}{'label'},
            'component' => "Routes",
            'opened'    => 0,
            'folder'    => 0,
            'keywords'  => "",
            'children'  => [],
            'table'     => {}
        };
        push @{$set}, $row;
    }

    # показываем доспупные роуты
    $self->render( json => $set );
}


# синхронизация между роутами в системе и таблицей
sub sync {
    my $self = shift;

    my @mess;

    my $db = $self->_sync_routes();

    my $resp->{'message'} = join("\n", "Everything is wrong") unless $db;

    $resp->{'status'} = $db ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}


# обновление роута
# my $id = $self->save({
#     "id"          => 1            - id обновляемого элемента ( >0 )
#     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "status"      => 0,           - по умолчанию 1
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",          - строка или json
#     "required"    => 0            - не обязательно, по умолчанию 0
# });
sub save {
    my ($self) = shift;
    my ($id, $parent, @mess);

    # read params
    my %data = (
        'id'        => $self->param('id'),
        'parent'    => $self->param('parent')    || 0,
        'label'     => $self->param('label'),
        'name'      => $self->param('name'),
        'value'     => $self->param('value')     || '{"/route":0}',
        'status'    => $self->param('status')    || 1,
        'readonly'  => $self->param('readonly')  || 0,
        'required'  => $self->param('required')  || 0
    );

    # проверка поля parent
    if ( $self->_parent_check_route( $data{'parent'} ) ) {
        # # проверка остальных обязательных полей
        # if ( $data{'label'} && $data{'name'} && $data{'id'} ) {
            # проверка существования обновляемой строки
            if ( $self->_id_check_route( $data{'id'} ) ) {
                # обновление
                $id = $self->_update_route( \%data );
                push @mess, "Could not update setting item '$data{'label'}'" unless $id;
            }
            else {
                push @mess, "Can't find row for updating";                
            }
        # } else {
        #     push @mess, "Required fields do not exist";
        # }
    }
    else {
        push @mess, "Wrong parent";
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}

1;
