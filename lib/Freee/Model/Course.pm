package Freee::Model::Course;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Курсы
###################################################################

# Добавлением нового курса в EAV
# $id = $self->model('Course')->_empty_course();
sub _empty_course {
    my ( $self ) = @_;

    my ( $course, $eav, $id, $parent );

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # получаем id перента для курсов
    $course = Freee::EAV->new( 'Course' );
    $parent = $course->root();

    if ( $parent ) {
        # делаем запись в EAV
        $eav = {
            'parent'    => $parent,
            'title'     => 'New course',
            'publish'   => \0,
            'Course' => {
                'label'        => '',
                'description'  => '',
                'content'      => '',
                'keywords'     => '',
                'import_source'=> '',
                'url'          => '',
                'seo'          => '',
                'attachment'   => '[]'
            }
        };
        $course = Freee::EAV->new( 'Course', $eav );
        $id = $course->id();
        unless ( scalar( $id ) ) {
            push @!, "Could not insert course into EAV";
        }
    }
    else {
        push @!, "Empty parent for course EAV";
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $id;
}

# удалить курс
# $result = $self->model('Course')->_delete_course( <id> );
# $data = {
#     'id'    - id курса
# }
sub _delete_course {
    my ( $self, $id ) = @_;

    my ( $course, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $course = Freee::EAV->new( 'Course', { 'id' => $id } );

        return unless $course;

        $result = $course->_RealDelete();
    }

    return $result;
}

# получить список курсов
# my $list = $self->model('Course')->_list_course();
# my $list = {
#     "folder"      => 1,                               # EAV_items
#     "id"          => $self->param('id'),              # EAV_items
#     "label"       => "Курс 1",                     # EAV_data_string
#     "description" => "Краткое описание",              # EAV_data_string
#     "content"     => "Полное описание",               # EAV_data_string
#     "keywords"    => "ключевые слова",                # EAV_data_string
#     "url"         => "как должен выглядеть url",      # EAV_data_string
#     "seo"         => "дополнительное поле для seo",   # EAV_data_string
#     "route"       => "/course/",
#     "parent"      => $self->param('parent'),          # EAV_items
#     "attachment"  => [345,577,643]                    # EAV_data_string
# };
sub _list_course {
    my ( $self, $data ) = @_;

    my ( $course, $result, $list );

    # инициализация EAV
    $course = Freee::EAV->new( 'Course' );
    unless ( $course ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $course->_list({
        Parents     => [ $course->root() ],
        ShowHidden  => 1,
        FIELDS      => "*", 
        Order => [
            { 'items.title' => $$data{'order'} }
        ]
    });

    my @courses = ();
    map {
        my $item = {
            'id'          => $_->{'id'},
            'folder'      => $_->{'has_childs'},
            'label'       => $_->{'title'},
            'description' => $_->{'description'},
            'content'     => $_->{'content'},
            'keywords'    => $_->{'keywords'},
            'url'         => $_->{'url'},
            'seo'         => $_->{'seo'},
            'route'       => $_->{'route'},
            'parent'      => $_->{'parent'},
            'status'      => $_->{'publish'},
            'attachment'  => $_->{'attachment'} ? $_->{'attachment'} : []
        };
        push @courses, $item;
    } ( @$list );

    return \@courses;
}

#  получить данные для редактирования курса
#  my $result = $self->model('Course')->_get_course( $$data{'id'} );
#  $result = {
#     "folder" => 1,
#     "id" => $self->param('id'),
#     "label" => "Курс 1",
#     "description" => "Краткое описание",
#     "content" => "Полное описание",
#     "keywords" => "ключевые слова",
#     "url" => "как должен выглядеть url",
#     "seo" => "дополнительное поле для seo",
#     "route" => "/course/",
#     "parent" => $self->param('parent'),
#     "attachment" => [345,577,643]
# };
sub _get_course {
    my ( $self, $id ) = @_;

    my ( $course, $result, $list );

    unless ( scalar( $id ) ) {
        push @!, "no data for get";
        return;
    }
    else {
        # взять весь объект из EAV
        $course = Freee::EAV->new( 'Course', { 'id' => $id } );

        unless ( $course ) {
            push @!, "course with id '$id' doesn't exist";
            return;
        }

        $result = $course->_getAll();
        if ( $result ) {
            $list = {
               "id"          => $$result{'id'},
               "label"       => $$result{'label'},
               "description" => $$result{'description'},
               "content"     => $$result{'content'},
               "keywords"    => $$result{'keywords'},
               "url"         => $$result{'url'},
               "seo"         => $$result{'seo'},
               "route"       => '/course',
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

# сохранить курс
# $result = $self->model('Course')->_save_course( $data );
# $data = {
#    'id'          => 3,                                # кладется в EAV
#    'parent'      => 0,                                # кладется в EAV
#    'name'        => 'Название',                       # кладется в EAV
#    'label'       => 'Курс 1',                      # кладется в EAV
#    'description' => 'Краткое описание',               # кладется в EAV
#    'content'     => 'Полное описание',                # кладется в EAV
#    'attachment'  => '[345,577,643],                   # кладется в EAV
#    'keywords'    => 'ключевые слова',                 # кладется в EAV
#    'url'         => 'как должен выглядеть url',       # кладется в EAV
#    'seo'         => 'дополнительное поле для seo',    # кладется в EAV
#    'publish'      => 1                                 # кладется в EAV
# }
sub _save_course {
    my ( $self, $data ) = @_;

    my ( $course, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    else {
        # обновление полей в EAV
        $course = Freee::EAV->new( 'Course', { 'id' => $$data{'id'} } );

        return unless $course;

        $course->title( $$data{'title'} );
        $course->label( $$data{'label'} );
        $course->description( $$data{'description'} );
        $course->content( $$data{'content'} );
        $course->keywords( $$data{'keywords'} );
        $course->url( $$data{'url'} );
        $course->seo( $$data{'seo'} );
        $course->url( $$data{'url'} );

        $course->parent( $$data{'parent'} );
        $course->publish( $$data{'url'} );

#         $result = $course->_MultiStore( {                 
#             'Course' => {
#                 'title'        => $$data{'name'},
#                 'label'        => $$data{'label'},
#                 'description'  => $$data{'description'},
#                 'content'      => $$data{'content'},
#                 'keywords'     => $$data{'keywords'},
#                 'import_source'=> '',
#                 'url'          => $$data{'url'},
#                 'date_updated' => $$data{'time_update'},
#                 'seo'          => $$data{'seo'},
# # ???
#                 'title'        => $$data{'title'},
#                 'parent'       => $$data{'parent'}, 
#                 'publish'      => $$data{'publish'}
#             }
#         });
    }

    return $result;
}

# изменить статус курса (вкл/выкл)
# $result = $self->model('Course')->_toggle_course( $data );
# $data = {
#    'id'    => <id>, - id записи 
#    'publish'=> 1     - новый статус 1/0
# }
sub _toggle_course {
    my ( $self, $data ) = @_;

    my ( $course, $result );

    unless ( $$data{'id'} || $$data{'publish'} ) {
        return;
    }
    else {
        # обновление поля в EAV
        $course = Freee::EAV->new( 'Course', { 'id' => $$data{'id'} } );

        return unless $course;

        $result = $course->_store( 'publish', $$data{'publish'} ? 'true' : 'false' );
    }

    return $result;
}

# проверка существования курса
# my $true = $self->model('Course')->_exists_in_course( <id> );
# 'id'    - id курса
sub _exists_in_course {
    my ( $self, $id ) = @_;

    my ( $course, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $course = Freee::EAV->new( 'Course', { 'id' => $id } );
    }

    return $course ? 1 : 0;
}

1;
