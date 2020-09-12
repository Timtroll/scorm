package Freee::Model::Discipline;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Предметы
###################################################################

# Добавлением нового предмета в EAV
# $id = $self->model('Discipline')->_empty_discipline();
sub _empty_discipline {
    my ( $self ) = @_;

    my ( $discipline, $eav, $id, $parent );

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # получаем id перента для предметов
    $discipline = Freee::EAV->new( 'Discipline' );
    $parent = $discipline->root();

    if ( $parent ) {
        # делаем запись в EAV
        $eav = {
            'parent'    => $parent,
            'title'     => 'New discipline',
            'publish'   => \0,
            'Discipline' => {
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
        $discipline = Freee::EAV->new( 'Discipline', $eav );
        $id = $discipline->id();
        unless ( scalar( $id ) ) {
            push @!, "Could not insert discipline into EAV";
        }
    }
    else {
        push @!, "Empty parent for discipline EAV";
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $id;
}

# удалить предмет
# $result = $self->model('Discipline')->_delete_discipline( <id> );
# $data = {
#     'id'    - id предмета
# }
sub _delete_discipline {
    my ( $self, $id ) = @_;

    my ( $discipline, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $discipline = Freee::EAV->new( 'Discipline', { 'id' => $id } );

        return unless $discipline;

        $result = $discipline->_RealDelete();
    }

    return $result;
}

# получить список предметов
# my $list = $self->model('Discipline')->_list_discipline();
# my $list = {
#     "folder"      => 1,                               # EAV_items
#     "id"          => $self->param('id'),              # EAV_items
#     "label"       => "Предмет 1",                     # EAV_data_string
#     "description" => "Краткое описание",              # EAV_data_string
#     "content"     => "Полное описание",               # EAV_data_string
#     "keywords"    => "ключевые слова",                # EAV_data_string
#     "url"         => "как должен выглядеть url",      # EAV_data_string
#     "seo"         => "дополнительное поле для seo",   # EAV_data_string
#     "route"       => "/discipline/",
#     "parent"      => $self->param('parent'),          # EAV_items
#     "attachment"  => [345,577,643]                    # EAV_data_string
# };
sub _list_discipline {
    my ( $self, $data ) = @_;

    my ( $discipline, $result, $list );

    # инициализация EAV
    $discipline = Freee::EAV->new( 'Discipline' );
    unless ( $discipline ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $discipline->_list({
        Parents     => [ $discipline->root() ],
        ShowHidden  => 1,
        FIELDS      => "*", 
        Order => [
            { 'items.title' => $$data{'order'} }
        ]
    });

    my @disciplines = ();
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
            'status'      => $_->{'status'},
            'attachment'  => $_->{'attachment'} ? $_->{'attachment'} : []
        };
        push @disciplines, $item;
    } ( @$list );

    return \@disciplines;
}

#  получить данные для редактирования предмета
#  my $result = $self->model('Discipline')->_get_discipline( $$data{'id'} );
#  $result = {
#     "folder" => 1,
#     "id" => $self->param('id'),
#     "label" => "Предмет 1",
#     "description" => "Краткое описание",
#     "content" => "Полное описание",
#     "keywords" => "ключевые слова",
#     "url" => "как должен выглядеть url",
#     "seo" => "дополнительное поле для seo",
#     "route" => "/discipline/",
#     "parent" => $self->param('parent'),
#     "attachment" => [345,577,643]
# };
sub _get_discipline {
    my ( $self, $id ) = @_;

    my ( $discipline, $result, $list );

    unless ( scalar( $id ) ) {
        push @!, "no data for get";
        return;
    }
    else {
        # взять весь объект из EAV
        $discipline = Freee::EAV->new( 'Discipline', { 'id' => $id } );

        unless ( $discipline ) {
            push @!, "discipline with id '$id' doesn't exist";
            return;
        }

        $result = $discipline->_getAll();
        if ( $result ) {
            $list = {
               "id"          => $$result{'id'},
               "label"       => $$result{'label'},
               "description" => $$result{'description'},
               "content"     => $$result{'content'},
               "keywords"    => $$result{'keywords'},
               "url"         => $$result{'url'},
               "seo"         => $$result{'seo'},
               "route"       => '/discipline',
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

# сохранить предмет
# $result = $self->model('Discipline')->_save_discipline( $data );
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
sub _save_discipline {
    my ( $self, $data ) = @_;

    my ( $discipline, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    else {
        # обновление полей в EAV
        $discipline = Freee::EAV->new( 'Discipline', { 'id' => $$data{'id'} } );

        return unless $discipline;

        $result = $discipline->_MultiStore( {                 
            'Discipline' => {
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

# изменить статус предмета (вкл/выкл)
# $result = $self->model('Discipline')->_toggle_discipline( $data );
# $data = {
#    'id'    => <id>, - id записи 
#    'status'=> 1     - новый статус 1/0
# }
sub _toggle_discipline {
    my ( $self, $data ) = @_;

    my ( $discipline, $result );

    unless ( $$data{'id'} || $$data{'status'} ) {
        return;
    }
    else {
        # обновление поля в EAV
        $discipline = Freee::EAV->new( 'Discipline', { 'id' => $$data{'id'} } );

        return unless $discipline;

        $result = $discipline->_store( 'publish', $$data{'status'} ? 'true' : 'false' );
    }

    return $result;
}

# проверка существования предмета
# my $true = $self->model('Discipline')->_exists_in_discipline( <id> );
# 'id'    - id предмета
sub _exists_in_discipline {
    my ( $self, $id ) = @_;

    my ( $discipline, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $discipline = Freee::EAV->new( 'Discipline', { 'id' => $id } );
    }

    return $discipline ? 1 : 0;
}

1;