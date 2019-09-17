package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;


# для создания возможностей пользователя
# my $id = $self->insert_group({
#     "folder"      => 0,           - это возможности пользователя
#     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "editable"    => 0,           - не обязательно, по умолчанию 0
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
#     "value"       => "",            - строка или json
#     "required"    => 0              - обязательное поле
# });
# для создания группы пользователей
# my $id = $self->insert_group({
#     "folder"      => 1,           - это пользователь
#     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
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
    $data{'editable'} = $self->param('editable') || 0;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 0;
    $data{'status'} = $self->param('status') || 0;
    $data{'lib_id'} = 0 unless $data{'lib_id'} =~ /\d+/;

    # запись дополнительных значений, если это не folder
    if ( $self->param('lib_id') ) {
        my @fields = ("value", "required");
        foreach (@fields) {
            $data{$_} = $self->param($_) || 0;
        }
    }

    # сериализуем поле value 
    if ( defined $self->param('value') ) { 
        $$data{'value'} = '' if ($$data{'value'} eq 'null');
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
    }

    # проверка обязательных полей
    my ($id, $lib_id, @mess);
    unless ( ( $data{'lib_id'} ) && ( ( ! ( $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$data{'lib_id'} ) ) || ( $self->pg_dbh->selectrow_array('SELECT lib_id FROM "public"."groups" WHERE "id"='.$data{'lib_id'} ) ) ) ) ){ 
        if (  $data{'label'} && $data{'name'} ) {

            #добавление
            $id = $self->insert_group( \%data, [] );
            push @mess, "Could not new group item '$data{'label'}'" unless $id;

        } 
        else {
            push @mess, "Required fields do not exist";
        }
    } 
    else {
        push @mess, "Wrong lib_id";
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;   
    $self->render( 'json' => $resp );

  
}

# обновление групп
sub update {
    my ($self) = shift;

    my (%data, $data, $id, $lib_id, @mess);
    $data{'id'} = $self->param('id');
    $data{'lib_id'} = $self->param('lib_id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');
    $data{'editable'} = $self->param('editable') || 0;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 0;
    $data{'status'} = $self->param('status') || 0;
    $data{'lib_id'} = 0 unless $data{'lib_id'} =~ /\d+/;



    # запись дополнительных значений, если это не folder
    if ( $self->param('lib_id') ) {
        my @fields = ("value", "required");
        foreach (@fields) {
            $data{$_} = $self->param($_) || 0;
        }
    }

    #сериализуем поле value 
     if(  defined $self->param('value') ) { 
        $$data{'value'} = '' if ($$data{'value'} eq 'null');
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
     }


    # проверка поля lib_id
    unless ( ( $data{'lib_id'} ) && ( ( ! ( $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$data{'lib_id'} ) ) || ( $self->pg_dbh->selectrow_array('SELECT lib_id FROM "public"."groups" WHERE "id"='.$data{'lib_id'} ) ) ) ) ){ 

        # проверка остальных обязательных полей
        if ( $data{'label'} && $data{'name'} && $data{'id'} ) {

            # проверка существования обновляемой строки
            if ( $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$data{'id'} ) ) {

                #обновление
                print Dumper(\%data);
                $id = $self->update_group( \%data, [] );
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
sub delete {
    my $self = shift;

    # read params
    my $id = $self->param('id');

    # проверка обязательных полей
    my @mess;
    $id = 0 unless $id =~ /\d+/;
    push @mess, "Could not id for deleting" unless $id;

    if ( $id ) {
        # проверка на существование удаляемой строки в groups
        if ( $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$id ) ) {

            # процесс удаления
            $id = $self->delete_group( $id );
            push @mess, "Could not deleted '$id'" unless $id;

        }
        else {
            $id = 0;
            push @mess, "Can't find row for deleting";
        }
    }

    #вывод результата
    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    #$resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# для смены статуса
sub status {
    my $self = shift;

    # read params
    my (%data, $id);
    $data{'id'} = $self->param('id');
    $data{'status'} = $self->param('status');

    # проверка обязательных полей
    my @mess;
    $data{'id'} = 0 unless $data{'id'} =~ /\d+/;
    push @mess, "Need id for changing" unless  $data{'id'};

    $data{'id'} = 0 unless ( ( $data{'status'} == 0 ) || ( $data{'status'} == 1 ) );
    push @mess, "New status is wrong" unless  $data{'id'};

    
    if ( $data{'id'} ) {
        # проверка на существование строки 
        if ( $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$data{'id'} ) ) {

            #процесс смены статуса
            $id = $self->status_group( \%data, [] );
            push @mess, "Can't change status" unless $id;

        }
        else {
            $id = 0;
            push @mess, "Can't find row for updating";
        }
    }

    my $resp;
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    #$resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );

    }


1;
