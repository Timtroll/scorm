package Freee::Controller::Course;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

# получить список курсов
# $self->index( $data );
sub index {
    my $self = shift;

    my ( $list, $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем список курсов
        $list = $self->model('Course')->_list_course($data);

        $result = {};
        unless ( @! ) {
            $result = {
                "label" =>  "курсы",
                "current" =>  {
                    "route"  => '/course',
                    "add"    => '/course/add',      # разрешает добавлять курс
                    "edit"   => '/course/edit',     # разрешает редактировать курс
                    "delete" => '/course/delete'    # разрешает удалять курс
                },
                "child" =>  {
                    "add"    => '/course/add'       # разрешает добавлять курс
                },
                "list" => $list ? $list : []
            };
        }
        else {
            push @!, "Could not get list of course";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

# получить данные для редактирования курса
# $self->edit( $data );
# $data = {
#   id => <id> - id курса
# }
sub edit {
    my $self = shift;

    my ( $data, $resp, $result, $list );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получение объекта EAV
        $result = $self->model('Course')->_get_course( $$data{'id'} );

        unless ( @! ) {
            $list = {
                'id'     => $$result{'id'},
                'parent' => $$result{'parent'},
                'folder' => $$result{'parent'} ? 0 : 1,
                'tabs'   => [
                    {
                        'label'  => 'основные',
                        'fields' => [
                            { 'label'       => $$result{'label'} },
                            { 'description' => $$result{'description'} },
                            { 'keywords'    => $$result{'keywords'} },
                            { 'url'         => $$result{'url'} },
                            { 'seo'         => $$result{'seo'} },
                            { 'route'       => $$result{'route'} },
                            { 'status'      => $$result{'status'} }
                        ]
                    },
                    {
                        'label'  => 'Контент',
                        'fields' => [
                            { 'content'    => $$result{'content'} },
                            { 'attachment' => $$result{'attachment'} }
                        ]
                    }
                ]
            };
        }
        else {
            push @!, "Could not get course";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавление нового курса в EAV
# $self->add();
sub add {
    my $self = shift;

    my ( $resp, $id );

    # создание пустого объекта курса
    $id = $self->model('Course')->_empty_course();

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить курс
# $self->save( $data );
# $data = {
#    'id'          => 3,
#    'parent'      => 0,
#    'name'        => 'Название',
#    'label'       => 'курс 1',
#    'description' => 'Краткое описание',
#    'content'     => 'Полное описание',
#    'attachment'  => '[345,577,643],
#    'keywords'    => 'ключевые слова',
#    'url'         => 'как должен выглядеть url',
#    'seo'         => 'дополнительное поле для seo',
#    'status'      => 1
# }
sub save {
    my $self = shift;

    my ( $data, $attachment, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверка существования вложенных файлов
        $attachment = from_json( $$data{'attachment'} );
        foreach ( @$attachment ) {
            unless( $self->model('Utils')->_exists_in_table('media', 'id', $_ ) ) {
                push @!, "file with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! || !$$data{'parent'} ) {
        # проверка существования родителя
        unless( $self->model('Course')->_exists_in_course( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in course";
        }
    }

    unless ( @! ) {
        $$data{'status'} = 1 unless defined $$data{'status'};
        $$data{'title'} = join(' ', ( $$data{'name'}, $$data{'label'} ) );
        $$data{'time_update'} = 'now';

        # добавляем курс в EAV
        $result = $self->model('Course')->_save_course( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменить статус курса (вкл/выкл)
# $self->toggle( $data );
# $data = {
#    'id'    => - <id>m записи
#    'field' => - имя поля в таблице
#    'val'   => - 1/0
#}
sub toggle {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем курс в EAV
        $result = $self->model('Course')->_toggle_course( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалить курс
# $self->delete( $data );
# $data = {
#   'id' => <id> - id курса
#}
sub delete {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем курс в EAV
        $result = $self->model('Course')->_delete_course( $$data{'id'} );
        push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
