package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

# use Freee::Mock::Groups;
use common;
    
use Data::Dumper;

# вывод списка групп в виде объекта как в Mock
#    "label"       => "scorm",
#    "id"          => 1,
#    "component"   => "Groups",
#    "opened"      => 0,
#    "folder"      => 1,
#    "keywords"    => "",
#    "children"    => [],
#    "table"       => {}
sub index {
    my $self = shift;
    my ( $list, $set );

    # читаем группы из базы
    unless ( $list = $self->_all_groups() ) {
        return "Can't connect to the database";
    }

    # формируем данные для вывода
    foreach my $id (sort {$a <=> $b} keys %$list) {
        my $row = {
            'id'        => $id,
            'label'     => $$list{$id}{'label'},
            'component' => "Groups",
            'opened'    => 0,
            'folder'    => 1,
            'keywords'  => "",
            'children'  => [],
            'table'     => {}
        };
        push @{$set}, $row;
    }

    $self->render( json => $set );
}

# добавление группы
# my $id = $self->insert_group({
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "status"      => 0 или 1,         - активна ли группа
# });
sub add {
    my ($self, $data) = @_;

    # read params
    my %data = (
        'label'     => $self->param('label'),
        'name'      => $self->param('name'),
        'status'    => $self->param('status') || 1
    );

    my ($id, @mess, $resp);
    
    # проверка обязательных полей
    if ( $data{'label'} && $data{'name'} ) {
        # добавление группы
        $id = $self->_insert_group( \%data );
        push @mess, "Could not add new group item '$data{'label'}'" unless $id;
    }
    else {
        push @mess, "Required fields do not exist";
    }
 
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# обновление группы
# my $id = $self->save({
#     "id"        => 1            - id обновляемого элемента ( >0 )
#     "label"     => 'название'   - обязательно (название для отображения)
#     "name",     => 'name'       - обязательно (системное название, латиница)
#     "status"    => 0 или 1      - активна ли группа
# });
sub save {
    my ($self) = shift;
    my ( $id, $parent, @mess );

    # чтение параметров
    my %data = (
        'id'        => $self->param('id'),
        'label'     => $self->param('label'),
        'name'      => $self->param('name'),
        'status'    => $self->param('status') || 0
    );
    
    # проверка обязательных полей
    if ( $data{'label'} && $data{'name'} && $data{'id'} ) {
        # проверка существования обновляемой строки
        if ( $self->_group_id_check( $data{'id'} ) ) {
            # обновление группы
            $id = $self->_update_group( \%data );
            push @mess, "Could not update setting item '$data{'label'}'" unless $id;
        }
        else {
            push @mess, "Can't find row for updating";                
        }
    } else {
        push @mess, "Required fields do not exist";
    }
    
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}


# удалениe группы 
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;
   
    # проверка обязательных полей
    if ( $id ) {
        # проверка на существование удаляемой строки в groups
        if ( $self->_group_id_check( $id ) ) {
            # удаление группы
            $id = $self->_delete_group( $id );
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

1;
