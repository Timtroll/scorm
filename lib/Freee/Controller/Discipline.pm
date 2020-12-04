package Freee::Controller::Discipline;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( decode_json );

# получить список предметов
# $self->index( $data );
sub index {
    my $self = shift;

    my ( $list, $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем список предметов
        $list = $self->model('Discipline')->_list_discipline($data);

        $result = {};
        unless ( @! ) {
            $result = {
                "label" =>  "Предметы",
                "current" =>  {
                    "route"  => '/discipline',
                    "add"    => '/discipline/add',      # разрешает добавлять предмет
                    "edit"   => '/discipline/edit',     # разрешает редактировать предмет
                    "delete" => '/discipline/delete'    # разрешает удалять предмет
                },
                "child" =>  {
                    "add"    => '/theme/add'       # разрешает добавлять предмет
                },
                "list" => $list ? $list : []
            };
        }
        else {
            push @!, "Could not get list of discipline";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

# получить данные для редактирования предмета
# $self->edit( $data );
# $data = {
#   id => <id> - id предмета
# }
sub edit {
    my $self = shift;

    my ( $data, $resp, $result, $list );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получение объекта EAV
        $result = $self->model('Discipline')->_get_discipline( $$data{'id'} );

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
                            { 'status'      => $$result{'publish'} }
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
            push @!, "Could not get discipline";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавление нового предмета в EAV
# $self->add();
sub add {
    my $self = shift;

    my ( $resp, $id );

    # создание пустого объекта предмета
    $id = $self->model('Discipline')->_empty_discipline();

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить предмет
# $self->save( $data );
# $data = {
#    'id'          => 3,
#    'parent'      => 0,
#    'name'        => 'Название',
#    'label'       => 'Предмет 1',
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

    if ( ! @! && $$data{'attachment'} ) {
        # проверка существования вложенных файлов
        $attachment = decode_json( $$data{'attachment'} );
        foreach ( @$attachment ) {
            unless( $self->model('Utils')->_exists_in_table('media', 'id', $_ ) ) {
                push @!, "file with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! || !$$data{'parent'} ) {
        # проверка существования родителя
        unless( $self->model('Discipline')->_exists_in_discipline( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in discipline";
        }
    }

    unless ( @! ) {
        # смена поля status на publish
        $$data{'publish'} = defined $$data{'status'} ? $$data{'status'} : 1;
        delete $$data{'status'};

        $$data{'title'} = join(' ', ( $$data{'name'}, $$data{'label'} ) );
        $$data{'time_update'} = 'now';

        # добавляем предмет в EAV
        $result = $self->model('Discipline')->_save_discipline( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменить статус предмета (вкл/выкл)
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
        # добавляем предмет в EAV
        $result = $self->model('Discipline')->_toggle_discipline( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалить предмет
# $self->delete( $data );
# $data = {
#   'id' => <id>   - id предмета
#}
sub delete {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем предмет в EAV
        $result = $self->model('Discipline')->_delete_discipline( $$data{'id'} );
        push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
