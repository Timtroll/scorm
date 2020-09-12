package Freee::Model::Theme;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Темы
###################################################################

# Добавлением новой темы в EAV
# $id = $self->model('Theme')->_empty_theme();
sub _empty_theme {
    my ( $self ) = @_;

    my ( $theme, $eav, $id, $parent );

    # открываем транзакцию
    $self->{'app'}->pg_dbh->begin_work;

    # получаем id перента для тем
    $theme = Freee::EAV->new( 'Theme' );
    $parent = $theme->root();

    if ( $parent ) {
        # делаем запись в EAV
        $eav = {
            'parent'    => $parent,
            'title'     => 'New theme',
            'publish'   => \0,
            'Theme' => {
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
        $theme = Freee::EAV->new( 'Theme', $eav );
        $id = $theme->id();
        unless ( scalar( $id ) ) {
            push @!, "Could not insert theme into EAV";
        }
    }
    else {
        push @!, "Empty parent for theme EAV";
    }

    # закрытие транзакции
    $self->{'app'}->pg_dbh->commit;

    return $id;
}

# удалить тему
# $result = $self->model('theme')->_delete_theme( <id> );
# $data = {
#     'id'    - id темы
# }
sub _delete_theme {
    my ( $self, $id ) = @_;

    my ( $theme, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $theme = Freee::EAV->new( 'Theme', { 'id' => $id } );

        return unless $theme;

        $result = $theme->_RealDelete();
    }

    return $result;
}

# получить список тем
# my $list = $self->model('Theme')->_list_theme();
# возвращается:
# my $list = {
#     "folder"      => 1,                               # EAV_items
#     "id"          => $self->param('id'),              # EAV_items
#     "label"       => "Предмет 1",                     # EAV_data_string
#     "description" => "Краткое описание",              # EAV_data_string
#     "content"     => "Полное описание",               # EAV_data_string
#     "keywords"    => "ключевые слова",                # EAV_data_string
#     "url"         => "как должен выглядеть url",      # EAV_data_string
#     "seo"         => "дополнительное поле для seo",   # EAV_data_string
#     "route"       => "/theme/",
#     "parent"      => $self->param('parent'),          # EAV_items
#     "attachment"  => [345,577,643]                    # EAV_data_string
# };
sub _list_theme {
    my $self = shift;

    my ( $theme, $result, $list );

    # инициализация EAV
    $theme = Freee::EAV->new( 'Theme' );
    unless ( $theme ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $theme->_list( {
        Parents     => 0,
        ShowHidden  => 1,
        FIELDS      => "'has_childs', 'publish', 'parent', 'id'",
        Order => [
            { 'items.id' => 'ASC' }
        ]
    });

    my %themes = ();
    foreach my $row ( @$list ) {
        my $EAV_theme = Freee::EAV->new( 'Theme', { id => $row->{id} } );
        $row->{'folder'}      = $row->{'has_childs'};
        $row->{'label'}       = $EAV_theme->label();
        $row->{'description'} = $EAV_theme->description();
        $row->{'content'}     = $EAV_theme->content();
        $row->{'keywords'}    = $EAV_theme->keywords();
        $row->{'url'}         = $EAV_theme->url();
        $row->{'seo'}         = $EAV_theme->seo();
        $row->{'route'}       = '/theme/';
        $row->{'parent'}      = $row->{'parent'};
        $row->{'status'}      = $row->{'publish'};
        $row->{'attachment'}  = $EAV_theme->attachment();
        delete $$row{'has_childs'};
        delete $$row{'publish'}; # отдаем 'status' вместо 'publish'
    }

    return $list;
}

# получить данные для редактирования темы
# $list = $self->model('Theme')->_get_theme( <id> );
# возвращается:
# my $list = {
#     "folder" => 1,
#     "id" => $self->param('id'),
#     "label" => "Предмет 1",
#     "description" => "Краткое описание",
#     "content" => "Полное описание",
#     "keywords" => "ключевые слова",
#     "url" => "как должен выглядеть url",
#     "seo" => "дополнительное поле для seo",
#     "route" => "/theme/",
#     "parent" => $self->param('parent'),
#     "attachment" => [345,577,643]
# };
sub _get_theme {
    my ( $self, $id ) = @_;

    my ( $theme, $result, $list );

    unless ( scalar( $id ) ) {
        push @!, "no data for get";
        return;
    }
    else {
        # взять весь объект из EAV
        $theme = Freee::EAV->new( 'Theme', { 'id' => $id } );

        unless ( $theme ) {
            push @!, "theme with id '$id' doesn't exist";
            return;
        }

        $result = $theme->_getAll();
        if ( $result ) {
            $list = {
               "id"          => $$result{'id'},
               "label"       => $$result{'label'},
               "description" => $$result{'description'},
               "content"     => $$result{'content'},
               "keywords"    => $$result{'keywords'},
               "url"         => $$result{'url'},
               "seo"         => $$result{'seo'},
               "route"       => '/theme',
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

# сохранить тему
# $result = $self->model('Theme')->_save_theme( $data );
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
sub _save_theme {
    my ( $self, $data ) = @_;

    my ( $theme, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    else {
        # обновление полей в EAV
        $theme = Freee::EAV->new( 'Theme', { 'id' => $$data{'id'} } );

        return unless $theme;

        $result = $theme->_MultiStore( {                 
            'Theme' => {
                'title'        => $$data{'title'},
                'parent'       => $$data{'parent'}, 
                'title'        => $$data{'name'},
                'label'        => $$data{'label'},
                'description'  => $$data{'description'},
                'content'      => $$data{'content'},
                'keywords'     => $$data{'keywords'},
                'import_source'=> '',
                'url'          => $$data{'url'},
                'date_updated' => $$data{'time_update'},
                'publish'      => $$data{'status'},
                'seo'          => $$data{'seo'}
            }
        });
    }

    return $result;
}

# изменить статус темы (вкл/выкл)
# $result = $self->model('theme')->_toggle_theme( $data );
# $data = {
# $result = $self->model('Theme')->_toggle_theme( $data );
# 'id'    - id записи 
#    'id'    => <id>, - id записи 
#    'status'=> 1     - новый статус 1/0
# }
sub _toggle_theme {
    my ( $self, $data ) = @_;

    my ( $theme, $result );

    unless ( $$data{'id'} && $$data{'status'} ) {
        return;
    }
    else {
        # обновление поля в EAV
        $theme = Freee::EAV->new( 'Theme', { 'id' => $$data{'id'} } );

        return unless $theme;

        $result = $theme->_store( 'publish', $$data{'status'} ? 'true' : 'false' );
    }

    return $result;
}

# проверка существования темы
# my $true = $self->model('theme')->_exists_in_theme( <td> );
# 'id' - id темы
sub _exists_in_theme {
    my ( $self, $id ) = @_;

    my ( $theme, $result );

    unless ( scalar( $id ) ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $theme = Freee::EAV->new( 'Theme', { 'id' => $id } );
    }

    return $theme ? 1 : 0;
}

1;