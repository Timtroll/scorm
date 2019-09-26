package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;

sub index {
    my $self = shift;

    # читаем настройки из базы
    my $list = $self->all_groups();
    my $set = {};
    foreach my $id (sort {$a <=> $b} keys %$list) {
        # формируем данные для таблицы
        $$list{$id}{'table'} = $self->_table_obj({
            'groups'  => {},
            'header'    => [
                { "key" => "id", "label" => "id" },
                { "key" => "label", "label" => "Название" },
                # { "key" => "type", "label" => "Тип поля" },
                { "key" => "value", "label" => "Значение" },
            ],
            'body'      => $$list{$id}{'table'}
        });
        print "3 \n";
        push @{$$set{'groups'}}, $$list{$id};
    }

    $$set{'status'} = 'ok';
print Dumper($set);

    # показываем все настройки
    $self->render( json => $set );
}


# добавление группы пользователей
# my $id = $self->insert_group({
#     "label"       => 'название',      - название для отображения
#     "name",       => 'name',          - системное название, латиница
#     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
#     "required"    => 0,               - не обязательно, по умолчанию 0
#     "editable"    => 0,               - не обязательно, по умолчанию 0
#     "readOnly"    => 0,               - не обязательно, по умолчанию 0
#     "removable"   => 0,               - не обязательно, по умолчанию 0
# });
sub add {
    my ($self, $data) = @_;

    # read params
    my %data = (
        'label'     => $self->param('label'),
        'name'      => $self->param('name'),
        'value'     => $self->param('value') || '',
        'required'  => $self->param('required') || 0,
        'editable'  => $self->param('editable') || 0,
        'readOnly'  => $self->param('readOnly') || 0,
        'removable' => $self->param('removable') || 0,
    );

    my ($id, @mess, $resp);

    
    #проверка остальных полей
    if (  $data{'label'} && $data{'name'} ) {
        #добавление
        $id = $self->insert_group( \%data );
        push @mess, "Could not new group item '$data{'label'}'" unless $id;
    }
    else {
        push @mess, "Required fields do not exist";
    }
 
    $resp->{'message'} = join("\n", @mess) unless $id;
    $resp->{'status'} = $id ? 'ok' : 'fail';
    $resp->{'id'} = $id if $id;
    $self->render( 'json' => $resp );
}


# для создания группы пользователей
# my $id = $self->insert_group({
#       "id"        => 1            - id обновляемого элемента ( >0 )
#     "label"       => 'название'   - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "value"       => "",          - строка или json
#     "required"    => 0,           - не обязательно, по умолчанию 0
#     "editable"    => 0,           - не обязательно, по умолчанию 0
#     "readOnly"    => 0,           - не обязательно, по умолчанию 0
#     "removable"   => 0,           - не обязательно, по умолчанию 0
# });
# обновление групп
sub update {
    my ($self) = shift;

    my (%data, $data, $id, $parent, @mess);
    $data{'id'} = $self->param('id');
    $data{'label'} = $self->param('label');
    $data{'name'} = $self->param('name');
    $data{'value'} = $self->param('value') || "";
    $data{'required'} = $self->param('required') || 0;
    $data{'editable'} = $self->param('editable') || 0;
    $data{'readOnly'} = $self->param('readOnly') || 0;
    $data{'removable'} = $self->param('removable') || 0;

    # проверка обязательных полей
    if ( $data{'label'} && $data{'name'} && $data{'id'} ) {
        # проверка существования обновляемой строки
        if ( $self->id_check( $data{'id'} ) ) {
            #обновление
            $id = $self->update_group( \%data );
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

    $self->render( 'json' => $resp );
}

1;
