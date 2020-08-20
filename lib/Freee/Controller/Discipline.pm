package Freee::Controller::Discipline;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

# получить список предметов
# $self->index( $data );
sub index {
    my $self = shift;

    my ( $list, $result, $resp );

    $list = $self->model('Discipline')->_list_discipline();

    unless ( @! ) {
        $result = {
            "label" =>  "Предметы",
            "add"   => 1,              # разрешает добавлять предметы
            "child" =>  {
                "add"    => 1,         # разрешает добавлять детей
                "edit"   => 1,         # разрешает редактировать детей
                "remove" => 1,         # разрешает удалять детей
                "route"  => "/theme"   # роут для получения детей
            },
            "list" => $list
        };
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

# получить данные для редактирования предмета
# $self->edit( $data );
# $data = {
# id - id предмета
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
            }
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавление нового предмета в EAV
# $self->add( $data );
# $data = {
#    'parent'      => 0,                                # кладется в EAV
#    'name'        => 'Название',                       # кладется в EAV
#    'label'       => 'Предмет 1',                      # кладется в EAV
#    'description' => 'Краткое описание',               # кладется в EAV
#    'content'     => 'Полное описание',                # кладется в EAV
#    'attachment'  => '[345,577,643],                   # кладется в EAV
#    'keywords'    => 'ключевые слова',                 # кладется в EAV
#    'url'         => 'как должен выглядеть url',       # кладется в EAV
#    'seo'         => 'дополнительное поле для seo',    # кладется в EAV
#    'status'      => 1                                 # кладется в EAV
# }
sub add {
    my $self = shift;

    my ( $data, $attachment, $resp, $id );

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
        unless( $self->model('Discipline')->_exists_in_discipline( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in discipline";
        }
    }

    unless ( @! ) {
        # добавляем предмет в EAV
        $$data{'status'} = 1 unless defined $$data{'status'};

        $id = $self->model('Discipline')->_insert_discipline( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить предмет
# $self->save( $data );
# $data = {
#    'id'          => 3,                                # кладется в EAV
#    'parent'      => 0,                                # кладется в EAV
#    'name'        => 'Название',                       # кладется в EAV
#    'label'       => 'Предмет 1',                      # кладется в EAV
#    'description' => 'Краткое описание',               # кладется в EAV
#    'content'     => 'Полное описание',                # кладется в EAV
#    'attachment'  => '[345,577,643],                   # кладется в EAV
#    'keywords'    => 'ключевые слова',                 # кладется в EAV
#    'url'         => 'как должен выглядеть url',       # кладется в EAV
#    'seo'         => 'дополнительное поле для seo',    # кладется в EAV
#    'status'      => 1                                 # кладется в EAV
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
        unless( $self->model('Discipline')->_exists_in_discipline( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in discipline";
        }
    }

    unless ( @! ) {
        $$data{'status'} = 1 unless defined $$data{'status'};
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
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
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
# 'id'    - id предмета
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