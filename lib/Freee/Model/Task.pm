package Freee::Model::Task;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Уроки
###################################################################

# Добавлением нового урока в EAV
# $id = $self->model('Task')->_empty_task();
sub _empty_task {
    my ( $self ) = @_;

    my ( $task, $eav, $id, $parent );

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # получаем id перента для уроков
    $task = Freee::EAV->new( 'Task' );
    $parent = $task->root();

    if ( $parent ) {
        # делаем запись в EAV
        $eav = {
            'parent'    => $parent,
            'title'     => 'New task',
            'publish'   => \0,
            'Task' => {
                'label'        => '',
                'description'  => '',
                'content'      => '',
                'keywords'     => '',
                'import_source'=> '',
                'attachment'   => '[]'
            }
        };
        $task = Freee::EAV->new( 'Task', $eav );
        $id = $task->id();
        unless ( scalar( $id ) ) {
            push @!, "Could not insert task into EAV";
        }
    }
    else {
        push @!, "Empty parent for task EAV";
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $id;
}

# удалить урок
# $result = $self->model('Task')->_delete_task( <id> );
# $data = {
#     'id'    - id урока
# }
sub _delete_task {
    my ( $self, $id ) = @_;

    my ( $task, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $task = Freee::EAV->new( 'Task', { 'id' => $id } );

        return unless $task;

        $result = $task->_RealDelete();
    }

    return $result;
}

# получить список уроков
# my $list = $self->model('Task')->_list_task();
# my $list = {
#     "folder"      => 1,                               # EAV_items
#     "id"          => $self->param('id'),              # EAV_items
#     "label"       => "Урок 1",                     # EAV_data_string
#     "description" => "Краткое описание",              # EAV_data_string
#     "content"     => "Полное описание",               # EAV_data_string
#     "keywords"    => "ключевые слова",                # EAV_data_string
#     "url"         => "как должен выглядеть url",      # EAV_data_string
#     "seo"         => "дополнительное поле для seo",   # EAV_data_string
#     "route"       => "/task/",
#     "parent"      => $self->param('parent'),          # EAV_items
#     "attachment"  => [345,577,643]                    # EAV_data_string
# };
sub _list_task {
    my ( $self, $data ) = @_;

    my ( $task, $result, $list );

    # инициализация EAV
    $task = Freee::EAV->new( 'Task' );
    unless ( $task ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $task->_list({
        Parents     => [ $task->root() ],
        ShowHidden  => 1,
        FIELDS      => "*", 
        Order => [
            { 'items.title' => $$data{'order'} }
        ]
    });

#     my @tasks = ();
#     map {
#         my $item = {
#             'id'          => $_->{'id'},
#             'folder'      => $_->{'has_childs'},
#             'label'       => $_->{'title'},
#             'description' => $_->{'description'},
#             'content'     => $_->{'content'},
#             'keywords'    => $_->{'keywords'},
#             'route'       => $_->{'route'},
#             'parent'      => $_->{'parent'},
#             'status'      => $_->{'publish'},
#             'attachment'  => $_->{'attachment'} ? $_->{'attachment'} : []
#         };
#         push @tasks, $item;
#     } ( @$list );
# warn Dumper( @tasks );
#     return \@tasks;
    if ( ref($list) eq 'ARRAY' ) {
        foreach ( @$list ) {
            # взять весь объект из EAV
            $task = Freee::EAV->new( 'Task', { 'id' => $_->{'id'} } );

            $result = $task->_getAll();
            if ( $result ) {
                $_->{'id'}          = $$result{'id'},
                $_->{'label'}       = $$result{'label'},
                $_->{'description'} = $$result{'description'},
                $_->{'content'}     = $$result{'content'},
                $_->{'keywords'}    = $$result{'keywords'},
                $_->{'attachment'}  = $$result{'attachment'},
                $_->{'status'}      = $$result{'publish'},
                $_->{'folder'}      = $_->{'has_childs'},
                $_->{'parent'}      = $$result{'parent'},
                delete $_->{'title'},
                delete $_->{'distance'},
                delete $_->{'has_childs'},
                delete $_->{'import_source'},
                delete $_->{'publish'},
                delete $_->{'import_id'},
                delete $_->{'date_created'},
                delete $_->{'date_updated'},
                delete $_->{'type'}
            } 
            else {
                push @!, 'can\'t get list';
                return;
            }
        }
    }

    return $list;
}

#  получить данные для редактирования урока
#  my $result = $self->model('Task')->_get_task( $$data{'id'} );
#  $result = {
#     "folder"      => 1,
#     "id"          => $self->param('id'),
#     "label"       => "Урок 1",
#     "description" => "Краткое описание",
#     "content"     => "Полное описание",
#     "keywords"    => "ключевые слова",
#     "route"       => "/task/",
#     "parent"      => $self->param('parent'),
#     "attachment"  => [345,577,643]
# };
sub _get_task {
    my ( $self, $id ) = @_;

    my ( $task, $result, $list );

    unless ( scalar( $id ) ) {
        push @!, "no data for get";
        return;
    }
    else {
        # взять весь объект из EAV
        $task = Freee::EAV->new( 'Task', { 'id' => $id } );

        unless ( $task ) {
            push @!, "task with id '$id' doesn't exist";
            return;
        }

        $result = $task->_getAll();
        if ( $result ) {
            $list = {
               "id"          => $$result{'id'},
               "label"       => $$result{'label'},
               "description" => $$result{'description'},
               "content"     => $$result{'content'},
               "keywords"    => $$result{'keywords'},
               "route"       => '/task',
               "parent"      => $$result{'parent'},
               "attachment"  => $$result{'attachment'},
               "status"      => $$result{'publish'}
            }
        } 
        else {
            push @!, 'can\'t get list';
            return;
        }
    }

    return $list;
}

# сохранить урок
# $result = $self->model('Task')->_save_task( $data );
# $data = {
#    'id'          => 3,
#    'parent'      => 0,
#    'name'        => 'Название',
#    'label'       => 'Урок 1',
#    'description' => 'Краткое описание',
#    'content'     => 'Полное описание',
#    'attachment'  => '[345,577,643],
#    'keywords'    => 'ключевые слова',
#    'url'         => 'как должен выглядеть url',
#    'seo'         => 'дополнительное поле для seo',
#    'publish'      => 1
# }
sub _save_task {
    my ( $self, $data ) = @_;

    my ( $task, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    else {
        # обновление полей в EAV
        $task = Freee::EAV->new( 'Task', { 'id' => $$data{'id'} } );

        return unless $task;

        $result = $task->_MultiStore( {
            'title'   => $$data{'title'},
            'Theme' => {
                'publish'      => $$data{'publish'},
                'parent'       => $$data{'parent'},
                'title'        => $$data{'name'},
                'label'        => $$data{'label'},
                'description'  => $$data{'description'},
                'content'      => $$data{'content'},
                'keywords'     => $$data{'keywords'},
                'import_source'=> '',
                'date_updated' => $$data{'time_update'}
            },
            'Default' => {
                'title'        => $$data{'name'},
                'label'        => $$data{'label'},
                'description'  => $$data{'description'},
                'content'      => $$data{'content'},
                'keywords'     => $$data{'keywords'},
                'import_source'=> '',
                'date_updated' => $$data{'time_update'}
            }
        });
    }

    return $result;
}

# проверка существования урока
# my $true = $self->model('Task')->_exists_in_task( <id> );
#   'id' - id урока
sub _exists_in_task {
    my ( $self, $id ) = @_;

    my ( $task, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $task = Freee::EAV->new( 'Task', { 'id' => $id } );
    }

    return $task ? 1 : 0;
}

1;