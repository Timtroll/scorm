package Freee::Model::Lesson;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Уроки
###################################################################

# Добавлением нового урока в EAV
# $id = $self->model('Lesson')->_empty_lesson();
sub _empty_lesson {
    my ( $self ) = @_;

    my ( $lesson, $eav, $id, $parent );

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # получаем id перента для уроков
    $lesson = Freee::EAV->new( 'Lesson' );
    $parent = $lesson->root();

    if ( $parent ) {
        # делаем запись в EAV
        $eav = {
            'parent'    => $parent,
            'title'     => 'New lesson',
            'publish'   => \0,
            'Lesson' => {
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
        $lesson = Freee::EAV->new( 'Lesson', $eav );
        $id = $lesson->id();
        unless ( scalar( $id ) ) {
            push @!, "Could not insert lesson into EAV";
        }
    }
    else {
        push @!, "Empty parent for lesson EAV";
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $id;
}

# удалить урок
# $result = $self->model('Lesson')->_delete_lesson( <id> );
# $data = {
#     'id'    - id урока
# }
sub _delete_lesson {
    my ( $self, $id ) = @_;

    my ( $lesson, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $lesson = Freee::EAV->new( 'Lesson', { 'id' => $id } );

        return unless $lesson;

        $result = $lesson->_RealDelete();
    }

    return $result;
}

# получить список уроков
# my $list = $self->model('Lesson')->_list_lesson();
# my $list = {
#     "folder"      => 1,                               # EAV_items
#     "id"          => $self->param('id'),              # EAV_items
#     "label"       => "Урок 1",                     # EAV_data_string
#     "description" => "Краткое описание",              # EAV_data_string
#     "content"     => "Полное описание",               # EAV_data_string
#     "keywords"    => "ключевые слова",                # EAV_data_string
#     "url"         => "как должен выглядеть url",      # EAV_data_string
#     "seo"         => "дополнительное поле для seo",   # EAV_data_string
#     "route"       => "/lesson/",
#     "parent"      => $self->param('parent'),          # EAV_items
#     "attachment"  => [345,577,643]                    # EAV_data_string
# };
sub _list_lesson {
    my ( $self, $data ) = @_;

    my ( $lesson, $result, $list );

    # инициализация EAV
    $lesson = Freee::EAV->new( 'Lesson' );
    unless ( $lesson ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $lesson->_list({
        Parents     => [ $lesson->root() ],
        ShowHidden  => 1,
        FIELDS      => "*", 
        Order => [
            { 'items.title' => $$data{'order'} }
        ]
    });

    if ( ref($list) eq 'ARRAY' ) {
        foreach ( @$list ) {
            # взять весь объект из EAV
            $lesson = Freee::EAV->new( 'Lesson', { 'id' => $_->{'id'} } );

            $result = $lesson->_getAll();
            if ( $result ) {
                $_->{'id'}          = $$result{'id'},
                $_->{'label'}       = $$result{'label'},
                $_->{'description'} = $$result{'description'},
                $_->{'content'}     = $$result{'content'},
                $_->{'keywords'}    = $$result{'keywords'},
                $_->{'attachment'}  = $$result{'attachment'},
                $_->{'status'}      = $$result{'publish'},
                $_->{'seo'}         = $$result{'seo'},
                $_->{'url'}         = $$result{'url'},
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
#  my $result = $self->model('Lesson')->_get_lesson( $$data{'id'} );
#  $result = {
#     "folder"      => 1,
#     "id"          => $self->param('id'),
#     "label"       => "Урок 1",
#     "description" => "Краткое описание",
#     "content"     => "Полное описание",
#     "keywords"    => "ключевые слова",
#     "url"         => "как должен выглядеть url",
#     "seo"         => "дополнительное поле для seo",
#     "route"       => "/lesson/",
#     "parent"      => $self->param('parent'),
#     "attachment"  => [345,577,643]
# };
sub _get_lesson {
    my ( $self, $id ) = @_;

    my ( $lesson, $result, $list );

    unless ( scalar( $id ) ) {
        push @!, "no data for get";
        return;
    }
    else {
        # взять весь объект из EAV
        $lesson = Freee::EAV->new( 'Lesson', { 'id' => $id } );

        unless ( $lesson ) {
            push @!, "lesson with id '$id' doesn't exist";
            return;
        }

        $result = $lesson->_getAll();
        if ( $result ) {
            $list = {
               "id"          => $$result{'id'},
               "label"       => $$result{'label'},
               "description" => $$result{'description'},
               "content"     => $$result{'content'},
               "keywords"    => $$result{'keywords'},
               "url"         => $$result{'url'},
               "seo"         => $$result{'seo'},
               "route"       => '/lesson',
               "parent"      => $$result{'parent'},
               "attachment"  => $$result{'attachment'},
               "publish"      => $$result{'publish'}
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
# $result = $self->model('Lesson')->_save_lesson( $data );
# $data = {
#    'id'          => 3,                                # кладется в EAV
#    'parent'      => 0,                                # кладется в EAV
#    'name'        => 'Название',                       # кладется в EAV
#    'label'       => 'Урок 1',                         # кладется в EAV
#    'description' => 'Краткое описание',               # кладется в EAV
#    'content'     => 'Полное описание',                # кладется в EAV
#    'attachment'  => '[345,577,643],                   # кладется в EAV
#    'keywords'    => 'ключевые слова',                 # кладется в EAV
#    'url'         => 'как должен выглядеть url',       # кладется в EAV
#    'seo'         => 'дополнительное поле для seo',    # кладется в EAV
#    'publish'      => 1                                 # кладется в EAV
# }
sub _save_lesson {
    my ( $self, $data ) = @_;

    my ( $lesson, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    else {
        # обновление полей в EAV
        $lesson = Freee::EAV->new( 'Lesson', { 'id' => $$data{'id'} } );

        return unless $lesson;

        $result = $lesson->_MultiStore( {                 
            'Lesson' => {
                'title'        => $$data{'name'},
                'label'        => $$data{'label'},
                'description'  => $$data{'description'},
                'content'      => $$data{'content'},
                'keywords'     => $$data{'keywords'},
                'import_source'=> '',
                'url'          => $$data{'url'},
                'date_updated' => $$data{'time_update'},
                'seo'          => $$data{'seo'},
# ???
                'title'        => $$data{'title'},
                'parent'       => $$data{'parent'}, 
                'publish'      => $$data{'status'}
            }
        });
    }

    return $result;
}

# проверка существования урока
# my $true = $self->model('Lesson')->_exists_in_lesson( <id> );
# 'id'    - id урока
sub _exists_in_lesson {
    my ( $self, $id ) = @_;

    my ( $lesson, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $lesson = Freee::EAV->new( 'Lesson', { 'id' => $id } );
    }

    return $lesson ? 1 : 0;
}

1;