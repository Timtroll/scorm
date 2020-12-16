package Freee::Model::Theme;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Темы
###################################################################

# Добавление новой темы в EAV
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
# $result = $self->model('Theme')->_delete_theme( <id> );
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
# my $list = {
#     "folder"      => 1,                               # EAV_items
#     "id"          => $self->param('id'),              # EAV_items
#     "label"       => "Тема 1",                     # EAV_data_string
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
    my ( $self, $data ) = @_;

    my ( $theme, $result, $list );

    # инициализация EAV
    $theme = Freee::EAV->new( 'Theme' );
    unless ( $theme ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $theme->_list({
        Parents     => [ $theme->root() ],
        ShowHidden  => 1,
        FIELDS      => "*", 
        Order => [
            { 'items.title' => $$data{'order'} }
        ]
    });

    my @themes = ();
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
        push @themes, $item;
    } ( @$list );

    return \@themes;
}

#  получить данные для редактирования темы
#  my $result = $self->model('Theme')->_get_theme( $$data{'id'} );
#  $result = {
#     "folder"      => 1,
#     "id"          => $self->param('id'),
#     "label"       => "Тема 1",
#     "description" => "Краткое описание",
#     "content"     => "Полное описание",
#     "keywords"    => "ключевые слова",
#     "url"         => "как должен выглядеть url",
#     "seo"         => "дополнительное поле для seo",
#     "route"       => "/theme/",
#     "parent"      => $self->param('parent'),
#     "attachment"  => [345,577,643]
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
#    'label'       => 'Тема 1',                      # кладется в EAV
#    'description' => 'Краткое описание',               # кладется в EAV
#    'content'     => 'Полное описание',                # кладется в EAV
#    'attachment'  => '[345,577,643],                   # кладется в EAV
#    'keywords'    => 'ключевые слова',                 # кладется в EAV
#    'url'         => 'как должен выглядеть url',       # кладется в EAV
#    'seo'         => 'дополнительное поле для seo',    # кладется в EAV
#    'publish'      => 1                                 # кладется в EAV
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
                'url'          => $$data{'url'},
                'date_updated' => $$data{'time_update'},
                'seo'          => $$data{'seo'}
            },
            'Default' => {
                'title'        => $$data{'name'},
                'label'        => $$data{'label'},
                'description'  => $$data{'description'},
                'content'      => $$data{'content'},
                'keywords'     => $$data{'keywords'},
                'import_source'=> '',
                'url'          => $$data{'url'},
                'date_updated' => $$data{'time_update'},
                'seo'          => $$data{'seo'}
            }
        });
    }

    return $result;
}

# изменить статус темы (вкл/выкл)
# $result = $self->model('Theme')->_toggle_theme( $data );
# $data = {
#    'id'    => <id>, - id записи 
#    'publish'=> 1     - новый статус 1/0
# }
sub _toggle_theme {
    my ( $self, $data ) = @_;

    my ( $theme, $result );

    unless ( $$data{'id'} || $$data{'publish'} ) {
        return;
    }
    else {
        # обновление поля в EAV
        $theme = Freee::EAV->new( 'Theme', { 'id' => $$data{'id'} } );

        return unless $theme;

        $result = $theme->_store( 'publish', $$data{'publish'} ? 'true' : 'false' );
    }

    return $result;
}

# проверка существования темы
# my $true = $self->model('Theme')->_exists_in_theme( <id> );
# 'id'    - id темы
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