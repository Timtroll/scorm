package Freee::Controller::Task;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

# получить список заданий
# $self->index( $data );
sub index {
    my $self = shift;

    my ( $list, $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем список заданий
        $list = $self->model('Task')->_list_task($data);

        $result = {};
        unless ( @! ) {
            $result = {
                "label" =>  "Задания",
                "current" =>  {
                    "route"  => '/task',
                    "add"    => '/task/add',      # разрешает добавлять задание
                    "edit"   => '/task/edit',     # разрешает редактировать задание
                    "delete" => '/task/delete'    # разрешает удалять задание
                },
                "child" =>  {
                    "add"    => '/task/add'       # разрешает добавлять задание
                },
                "list" => $list ? $list : []
            };
        }
        else {
            push @!, "Could not get list of task";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'staus'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

# получить данные для редактирования задания
# $self->edit( $data );
# $data = {
#   id => <id> - id задания
# }
sub edit {
    my $self = shift;

    my ( $data, $resp, $result, $list );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получение объекта EAV
        $result = $self->model('Task')->_get_task( $$data{'id'} );

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
                            { 'publish'      => $$result{'publish'} }
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
            push @!, "Could not get task";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'staus'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавление нового задания в EAV
# $self->add();
sub add {
    my $self = shift;

    my ( $resp, $id );

    # создание пустого объекта задания
    $id = $self->model('Task')->_empty_task();

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'staus'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить задание
# $self->save( $data );
# $data = {
#    'id'          => 3,
#    'parent'      => 0,
#    'name'        => 'Название',
#    'label'       => 'задание 1',
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
        unless( $self->model('Task')->_exists_in_task( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in task";
        }
    }

    unless ( @! ) {
        $$data{'publish'} = 1 unless defined $$data{'publish'};
        $$data{'title'} = join(' ', ( $$data{'name'}, $$data{'label'} ) );
        $$data{'time_update'} = 'now';

        # добавляем задание в EAV
        $result = $self->model('Task')->_save_task( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'staus'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменить статус задания (вкл/выкл)
# $self->toggle( $data );
# $data = {
#   'id'    => <id> - id записи
#   'field' => имя поля в таблице
#   'val'   => 1/0
#}
sub toggle {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем задание в EAV
        $result = $self->model('Task')->_toggle_task( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'staus'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалить задание
# $self->delete( $data );
# $data = {
#   'id' => <id>    - id задания
#}
sub delete {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем задание в EAV
        $result = $self->model('Task')->_delete_task( $$data{'id'} );
        push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'staus'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
