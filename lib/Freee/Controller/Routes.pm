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

# показываем все роуты
    $self->render( json => $set );
}


# новый роут
# my $id = $self->insert_route({
#     "parent"      => 5,               - id родителя (должно быть натуральным числом), 0 - фолдер
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
#     "required"    => 0,               - не обязательно, по умолчанию 0
#     "readOnly"    => 0,               - не обязательно, по умолчанию 0
#     "removable"   => 0,               - не обязательно, по умолчанию 0
#     "status"      => 0                - по умолчанию 1
# });
sub add {
    my ($self, $data) = @_;

    my ($id, @mess, $resp);

    # read params
    my %data = (
        'parent'    => $self->param('parent')    || 0,
        'label'     => $self->param('label'),
        'name'      => $self->param('name'),
        'value'     => $self->param('value')     || '{"/route":0}',
        'status'    => $self->param('status')    || 1,
        'required'  => $self->param('required')  || 0,
        'readOnly'  => $self->param('readOnly')  || 0,
        'removable' => $self->param('removable') || 0
    );

    # проверка parent
    if ( $self->_parent_check_route( $data{'parent'} ) ) { 
        #проверка остальных полей
        if (  $data{'label'} && $data{'name'} ) {
            #добавление
            $id = $self->_insert_route( \%data );
            push @mess, "Could not add new route item '$data{'label'}'" unless $id;
        }
        else {
            push @mess, "Required fields do not exist";
        }
    }
    else {
        push @mess, "Wrong parent";
    }

    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;
    $self->render( 'json' => $resp );
}


# обновление роута
# my $id = $self->insert_route({
#      "id"         => 1            - id обновляемого элемента ( >0 )
#     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "status"      => 0,           - по умолчанию 1
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",          - строка или json
#     "required"    => 0            - не обязательно, по умолчанию 0
# });
sub update {
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
        'readOnly'  => $self->param('readOnly')  || 0,
        'removable' => $self->param('removable') || 0,
        'required'  => $self->param('required')  || 0
    );

    # проверка поля parent
    if ( $self->_parent_check_route( $data{'parent'} ) ) {
        # проверка остальных обязательных полей
        if ( $data{'label'} && $data{'name'} && $data{'id'} ) {
            # проверка существования обновляемой строки
            if ( $self->_id_check_route( $data{'id'} ) ) {
                # обновление
                $id = $self->_update_route( \%data );
                push @mess, "Could not update setting item '$data{'label'}'" unless $id;
            }
            else {
                push @mess, "Can't find row for updating";                
            }
        } else {
            push @mess, "Required fields do not exist";
        }
    }
    else {
        push @mess, "Wrong parent";
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}


# удалениe из групп пользователей
#  "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;

    # проверка обязательных полей
    if ( $id ) {
        # проверка на существование удаляемой строки в routes
        if ( $self->_id_check_route( $id ) ) {
            # процесс удаления
            $id = $self->_delete_route( $id );
            push @mess, "Could not deleted" unless $id;
        }
        else {
            $id = 0;
            push @mess, "Can't find row for deleting";
        }
    } 
    else {
        push @mess, "Could not id for deleting" unless $id;
    }

    # вывод результата
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}


# для деактивации роута
#  "id"     => 1 - id изменяемого элемента ( > 0 )
#  элементу присваивается "status" = 0
sub hide {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;

    # проверка id
    if ( $id ) {   
        # проверка на существование строки 
        if ( $self->_id_check_route( $id ) ) {
            # процесс смены статуса
            $id = $self->_hide_route( $id );
            push @mess, "Can't change status" unless $id;
        }
        else {
            $id = 0;
            push @mess, "Can't find row for hiding";
        }
    } 
    else {
        push @mess, "Need id for changing";
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}


# для активации роута
#  "id"     => 1 - id изменяемого элемента ( > 0 )
#  элементу присваивается "status" = 1
sub activate {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;

    # проверка id
    if ( $id ) {    
        # проверка на существование строки 
        if ( $self->_id_check_route( $id ) ) {
            # процесс смены статуса
            $id = $self->_activate_route( $id );
            push @mess, "Can't change status" unless $id;
        }
        else {
            $id = 0;
            push @mess, "Can't find row for activating";
        }
    } 
    else {
        push @mess, "Need id for changing";
    }
    
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}

1;
