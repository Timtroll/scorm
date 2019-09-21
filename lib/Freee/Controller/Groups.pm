package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;


# для создания возможностей групп пользователей
# my $id = $self->insert_group({
#     "folder"      => 0,           - это возможности пользователя
#     "lib_id"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 0,           - не обязательно, по умолчанию 0
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",            - строка или json
#     "required"    => 0            - не обязательно, по умолчанию 0
# });
# для создания группы пользователей
# my $id = $self->insert_group({
#     "folder"      => 1,           - это группа пользователей
#     "lib_id"      => 0,           - обязательно 0 (должно быть натуральным числом) 
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 0,           - не обязательно, по умолчанию 0
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
# });
sub add {
    my ($self, $data) = @_;

    # read params
    my %data;
    $data{'lib_id'} = $self->param('lib_id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');
    $data{'lib_id'} = $self->param('lib_id') || 0;
    $data{'editable'} = $self->param('editable') || 0;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 0;
    $data{'status'} = $self->param('status') || 0;

    # запись дополнительных значений, если это не folder
    if ( $self->param('lib_id') ) {
       $data{'required'} = $self->param('required') || 0;
       $data{'value'} = $self->param('value') || "";
    }

    my ($id, @mess, $resp);

    #проверка lib_id
    if ( $self->lib_id_check( $data{'lib_id'} ) ){ 

        #проверка остальных полей
        if (  $data{'label'} && $data{'name'} ) {

            #добавление
            $id = $self->insert_group( \%data );
            push @mess, "Could not new group item '$data{'label'}'" unless $id;
        }

        else {
            push @mess, "Required fields do not exist";
        }
    }

    else {
        push @mess, "Wrong lib_id";
    }

    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;   
    $self->render( 'json' => $resp );

  
}


# для обновления возможностей групп пользователей
# my $id = $self->insert_group({
#       "id"        => 1            - id обновляемого элемента ( >0 )
#     "folder"      => 0,           - это возможности пользователя
#     "lib_id"      => 5,           - обязательно id родителя (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 0,           - не обязательно, по умолчанию 0
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",            - строка или json
#     "required"    => 0            - не обязательно, по умолчанию 0
# });
# для создания группы пользователей
# my $id = $self->insert_group({
#       "id"        => 1            - id обновляемого элемента ( >0 )
#     "folder"      => 1,           - это группа пользователей
#     "lib_id"      => 0,           - обязательно 0 (должно быть натуральным числом) 
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 0,           - не обязательно, по умолчанию 0
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
# });
# обновление групп
sub update {
    my ($self) = shift;

    my (%data, $data, $id, $lib_id, @mess);
    $data{'id'} = $self->param('id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');
    $data{'lib_id'} = $self->param('lib_id') || 0;
    $data{'editable'} = $self->param('editable') || 0;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 0;
    $data{'status'} = $self->param('status') || 0;

    # запись дополнительных значений, если это не folder
    if ( $self->param('lib_id') ) {
       $data{'required'} = $self->param('required') || 0;
       $data{'value'} = $self->param('value') || "";
    }

    # проверка поля lib_id
    if ( $self->lib_id_check( $data{'lib_id'} ) ) {

        # проверка остальных обязательных полей
        if ( $data{'label'} && $data{'name'} && $data{'id'} ) {

            # проверка существования обновляемой строки
            if ( $self->id_check( $data{'id'} ) ) {

                #обновление
                #print Dumper(\%data);
                $id = $self->update_group( \%data );
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
        push @mess, "Wrong lib_id";
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    #$resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}


# для удаления из групп пользователей
#  "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    # read params
    my $id = $self->param('id');
    my @mess;
   
    # проверка обязательных полей
    if ( $id ) {

        # проверка на существование удаляемой строки в groups
        if ( $self->id_check( $id ) ) {

            # процесс удаления
            $id = $self->delete_group( $id );
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
    #$resp->{'id'} = $id if $id;

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
            if ( $self->id_check( $data{'id'} ) ) {

                #процесс смены статуса
                $id = $self->status_group( \%data, [] );
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
    #$resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );

}


1;
