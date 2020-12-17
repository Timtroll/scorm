package Freee::Controller::Theme;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( decode_json );

# получить список тем
# $self->index( $data );
sub index {
    my $self = shift;

    my ( $list, $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем список тем
        $list = $self->model('Theme')->_list_theme($data);

        $result = {};
        unless ( @! ) {
            $result = {
                "label" =>  "темы",
                "current" =>  {
                    "route"  => '/theme',
                    "add"    => '/theme/add',      # разрешает добавлять тему
                    "edit"   => '/theme/edit',     # разрешает редактировать тему
                    "delete" => '/theme/delete'    # разрешает удалять тему
                },
                "child" =>  {
                    "add"    => '/theme/add'       # разрешает добавлять тему
                },
                "list" => $list ? $list : []
            };
        }
        else {
            push @!, "Could not get list of theme";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

# получить данные для редактирования темы
# $self->edit( $data );
# $data = {
#   id - id темы
# }
sub edit {
    my $self = shift;

    my ( $data, $resp, $result, $list );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получение объекта EAV
        $result = $self->model('Theme')->_get_theme( $$data{'id'} );

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
            push @!, "Could not get theme";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Добавление новой темы в EAV
# $self->add();
sub add {
    my $self = shift;

    my ( $resp, $id );

    # создание пустого объекта темы
    $id = $self->model('Theme')->_empty_theme();

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить тему
# $self->save( $data );
# $data = {
#    'id'          => 3,                                # кладется в EAV
#    'name'        => 'Название',                       # кладется в EAV
#    'label'       => 'Тема 1',                         # кладется в EAV
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
        unless( $self->model('Theme')->_exists_in_theme( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in theme";
        }
    }

    unless ( @! ) {
        # смена поля status на publish
        $$data{'publish'} = defined $$data{'status'} ? $$data{'status'} : 1;
        delete $$data{'status'};

        $$data{'title'} = join(' ', ( $$data{'name'}, $$data{'label'} ) );
        $$data{'time_update'} = 'now';

        # добавляем тему в EAV
        $result = $self->model('Theme')->_save_theme( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменить статус темы (вкл/выкл)
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
        # добавляем тему в EAV
        $result = $self->model('Theme')->_toggle_theme( $data );
        push @!, "can't update EAV" unless $result;
    }
    # unless ( @! ) {
    #     $$data{'table'} = 'EAV_items';

    #     # смена status на publish
    #     $$data{'fieldname'} = 'publish' if $$data{'fieldname'} eq 'status';

    #     $$data{'value'} = $$data{'value'} ? "'t'" : "'f'";

    #     unless ( $self->model('Utils')->_exists_in_table( "\"EAV_items\"", 'id', $$data{'id'} ) ) {
    #         push @!, "Theme with '$$data{'id'}' doesn't exist";
    #     }
    #     unless ( @! ) {
    #         $result = $self->model('Utils')->_toggle( $data );
    #         push @!, "Could not toggle Theme '$$data{'id'}'" unless $result;
    #     }
    # }
    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалить тему
# $self->delete( $data );
# $data = {
# 'id'    - id темы
#}
sub delete {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # добавляем тему в EAV
        $result = $self->model('Theme')->_delete_theme( $$data{'id'} );
        push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
