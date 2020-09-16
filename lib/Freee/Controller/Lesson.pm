package Freee::Controller::Lesson;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

# получить список уроков
# $self->index( $data );
sub index {
    my $self = shift;

    my ( $list, $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем список уроков
        $list = $self->model('Lesson')->_list_lesson($data);

        $result = {};
        unless ( @! ) {
            $result = {
                "label" =>  "уроки",
                "current" =>  {
                    "route"  => '/lesson',
                    "add"    => '/lesson/add',      # разрешает добавлять урок
                    "edit"   => '/lesson/edit',     # разрешает редактировать урок
                    "delete" => '/lesson/delete'    # разрешает удалять урок
                },
                "child" =>  {
                    "add"    => '/lesson/add'       # разрешает добавлять урок
                },
                "list" => $list ? $list : []
            };
        }
        else {
            push @!, "Could not get list of lesson";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

# получить данные для редактирования урока
# $self->edit( $data );
# $data = {
#   id => <id> - id урока
# }
sub edit {
    my $self = shift;

    my ( $data, $resp, $result, $list );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получение объекта EAV
        $result = $self->model('Lesson')->_get_lesson( $$data{'id'} );

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
            push @!, "Could not get lesson";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавление нового урока в EAV
# $self->add();
sub add {
    my $self = shift;

    my ( $resp, $id );

    # создание пустого объекта урока
    $id = $self->model('Lesson')->_empty_lesson();

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить урок
# $self->save( $data );
# $data = {
#    'id'          => 3,
#    'parent'      => 0,
#    'name'        => 'Название',
#    'label'       => 'урок 1',
#    'description' => 'Краткое описание',
#    'content'     => 'Полное описание',
#    'attachment'  => '[345,577,643],
#    'keywords'    => 'ключевые слова',
#    'url'         => 'как должен выглядеть url',
#    'seo'         => 'дополнительное поле для seo',
#    'publish'      => 1
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
        unless( $self->model('Lesson')->_exists_in_lesson( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in lesson";
        }
    }

    unless ( @! ) {
        $$data{'publish'} = 1 unless defined $$data{'publish'};
        $$data{'title'} = join(' ', ( $$data{'name'}, $$data{'label'} ) );
        $$data{'time_update'} = 'now';

        # добавляем урок в EAV
        $result = $self->model('Lesson')->_save_lesson( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменить статус урока (вкл/выкл)
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
        # добавляем урок в EAV
        $result = $self->model('Lesson')->_toggle_lesson( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалить урок
# $self->delete( $data );
# $data = {
#   'id' => <id>    - id урока
#}
sub delete {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем урок в EAV
        $result = $self->model('Lesson')->_delete_lesson( $$data{'id'} );
        push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
