package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;

sub index {
    my ($self) = shift;

    my $resp = {id => '22', status => 'ok'};
    $self->render( 'json' => $resp );
}

# группы пользователей
# my $id = $self->add({
#     "parent"      => 5,               - id родителя (должно быть натуральным числом), 0 - фолдер
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
#     "required"    => 0,               - не обязательно, по умолчанию 0
#     "readonly"    => 0,               - не обязательно, по умолчанию 0
#     "removable"   => 0,               - не обязательно, по умолчанию 0
#     "status"      => 0                - по умолчанию 0
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
        'status'    => $self->param('status') || 0
    );

    my ($id, @mess, $resp);

    # проверка parent
    # if ( $self->parent_check( $data{'parent'} ) ){ 
        #проверка остальных полей
        if (  $data{'label'} && $data{'name'} ) {
            #добавление
            $id = $self->_insert_group( \%data );
            push @mess, "Could not new group item '$data{'label'}'" unless $id;
        }
        else {
            push @mess, "Required fields do not exist";
        }
    # }
    # else {
    #     push @mess, "Wrong parent";
    # }

    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;
    $self->render( 'json' => $resp );
}

# для обновления возможностей групп пользователей
# my $id = $self->update({
#      "id"        => 1            - id обновляемого элемента ( >0 )
#     "folder"      => 0,           - это возможности пользователя
#     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "readonly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",            - строка или json
#     "required"    => 0            - не обязательно, по умолчанию 0
# });
# для создания группы пользователей
# my $id = $self->update({
#       "id"        => 1            - id обновляемого элемента ( >0 )
#     "folder"      => 1,           - это группа пользователей
#     "parent"      => 0,           - обязательно 0 (должно быть натуральным числом) 
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
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
    $data{'parent'} = $self->param('parent') || 0;
    $data{'readonly'} = $self->param('readonly') || 0;
    $data{'removable'} = $self->param('removable') || 0;
    $data{'status'} = $self->param('status') || 0;

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
                #обновление
                $id = $self->_update_group( \%data );
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
    #$resp->{'id'} = $id if $id;

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
        # проверка на существование удаляемой строки в groups
        if ( $self->_id_check( $id ) ) {
            # процесс удаления
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

    #вывод результата
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';

    $self->render( 'json' => $resp );
}

# для смены статуса
#  "id"     => 1 - id изменяемого элемента ( > 0 )
#  "status" => 0 или 1 - новый статус элемента
sub status {
    my $self = shift;

    # read params
    my (%data, $id);
    $data{'id'} = $self->param('id');
    $data{'status'} = $self->param('status');

    my @mess;

     # проверка id
    if ( $data{'id'} ) {
        # проверка статуса
        if ( ( $data{'status'} == 0 ) || ( $data{'status'} == 1 ) ) {
            # проверка на существование строки 
            if ( $self->_id_check( $data{'id'} ) ) {
                #процесс смены статуса
                $id = $self->_status_group( \%data, [] );
                push @mess, "Can't change status" unless $id;
            }
            else {
                push @mess, "Can't find row for updating";
            }
        }
        else {
            push @mess, "New status is wrong";
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
