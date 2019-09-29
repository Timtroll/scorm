package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;
use common;
    

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

    # показываем все группы
    $self->render( json => $set );
}

# вывод списка роутов групп
#    "value"       => "value"
sub routes {
    my $self = shift;
    my ( $list, $set );

    # читаем группы из базы
    unless ( $list = $self->_groups_values() ) {
        return "Can't find list of routes";
    }

    # формируем данные для вывода
    foreach my $id (sort {$a <=> $b} keys %$list) {
        my $row = {
            'value'     => $$list{$id}{'value'}
        };
        push @{$set}, $row;
    }

    $self->render( json => $set );
}

# добавление группы пользователей
# my $id = $self->insert_group({
#     "parent"      => '1',             - id родителя, если нет, то - 0, корневой
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
#     "required"    => 0,               - не обязательно, по умолчанию 0
#     "readonly"    => 0,               - не обязательно, по умолчанию 0
#     "removable"   => 0,               - не обязательно, по умолчанию 0
# });
sub add {
    my ($self, $data) = @_;

    # read params
    my %data = (
        'parent'    => $self->param('parent') || 0,
        'label'     => $self->param('label'),
        'name'      => $self->param('name'),
        'value'     => $self->param('value') || '',
        'required'  => $self->param('required') || 0,
        'readonly'  => $self->param('readonly') || 0,
        'removable' => $self->param('removable') || 0,
    );

    my ($id, @mess, $resp);
    
    # проверка остальных полей
    if ( $data{'label'} && $data{'name'} ) {
        #добавление
        $id = $self->_insert_group( \%data );
        push @mess, "Could not new group item '$data{'label'}' group/route" unless $id;
    }
    else {
        push @mess, "Required fields do not exist group/route";
    }
 
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;
    $self->render( 'json' => $resp );
}

# Создание группы пользователей
# my $id = $self->update({
#     "id"          => 1            - id обновляемого элемента ( >0 )
#     "parent"      => 0            - id родителя элемента ( 0 или больше )
#     "label"       => 'название'   - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "value"       => "",          - строка или json
#     "required"    => 0,           - не обязательно, по умолчанию 0
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
# });
# обновление групп
sub update {
    my ($self) = shift;

    my (%data, $data, $id, $parent, @mess);
    $data{'id'} = $self->param('id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');
    $data{'readonly'} = $self->param('readonly') || 0;
    $data{'value'} = $self->param('value') || "";
    $data{'required'} = $self->param('required') || 0;
    $data{'removable'} = $self->param('removable') || 0;

    # запись дополнительных значений, если это не folder
    if ( $self->param('parent') ) {
       $data{'required'} = $self->param('required') || 0;
       $data{'value'} = $self->param('value') || "";
    }

    # проверка поля parent
    if ( $self->_parent_check( $data{'parent'} ) ) {
        # проверка остальных обязательных полей
        if ( $data{'label'} && $data{'name'} && $data{'id'} ) {
            # проверка существования обновляемой строки
            if ( $self->_id_check( $data{'id'} ) ) {
                # обновление
                $id = $self->_update_group( \%data );
                push @mess, "Could not update setting item '$data{'label'}' group/route" unless $id;
            }
            else {
                push @mess, "Can't find row for updating '$data{'id'}' for group/route";                
            }
        }
        else {
            push @mess, "Required fields do not exist for group/route";
        }
    }
    else {
        push @mess, "Required fields do not exist for group/route";
    }
    
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}


# удалениe из групп пользователей
# my $id = $self->delete("id");
# "id" => 1 - id удаляемого элемента ( > 0 )
sub delete {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;
   
    # проверка обязательных полей
    if ( $id ) {
        # проверка на существование удаляемой строки в groups
        if ( $self->_id_check( $id ) ) {
            # процесс удаления
            $id = $self->_delete_group( $id );
            push @mess, "Could not deleted '$id' group/route" unless $id;
        }
        else {
            $id = 0;
            push @mess, "Can't find row '$id' for deleting group/route";
        }
    } 
    else {
        push @mess, "Could not id for deleting group/route" unless $id;
    }

    #вывод результата
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}

# отключение группы или роута
# my $id = $self->hide("id");
# "id" => 1 - id отключаемой группы или роута ( > 0 )
sub hide {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;
   
    # проверка обязательных полей
    if ( $id ) {
        # процесс отключения
        my $res = $self->_hide_group( $id );
        push @mess, "Could not hide '$id' group/route" unless $res;
    } 
    else {
        push @mess, "Could not 'id' for hiding group/route" unless $id;
    }

    #вывод результата
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}

# активация группы или роута
# my $id = $self->activate("id");
# "id" => 1 - id отключаемой группы или роута ( > 0 )
sub activate {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;
   
    # проверка обязательных полей
    if ( $id ) {
        # процесс отключения
        my $res = $self->_activate_group( $id );
        push @mess, "Could not activate '$id' group/route" unless $res;
    } 
    else {
        push @mess, "Could not 'id' for activating group/route" unless $id;
    }

    #вывод результата
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}

1;
