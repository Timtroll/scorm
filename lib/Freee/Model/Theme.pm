package Freee::Model::Theme;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Предметы
###################################################################

# Добавлением нового предмета в EAV
# $id = $self->model('theme')->_insert_theme( $data );
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
sub _insert_theme {
    my ( $self, $data ) = @_;

    my ( $sth, $theme, $id );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        # делаем запись в EAV
        $theme = Freee::EAV->new( 'theme',
            {
                'parent'       => $$data{'parent'},
                'title'        => $$data{'name'},
                'publish'      => $$data{'status'},
                'theme' => {
                    'parent'       => $$data{'parent'},
                    'label'        => $$data{'label'},
                    'description'  => $$data{'description'},
                    'content'      => $$data{'content'},
                    'keywords'     => $$data{'keywords'},
                    'import_source'=> '',
                    'url'          => $$data{'url'},
                    'seo'          => $$data{'seo'},
                    'attachment'   => $$data{'attachment'}
                }
            }
        );
        $id = $theme->id();
        unless ( $id ) {
            push @!, "Could not insert theme into EAV";
        }
    }

    return $id;
}

# удалить предмет
# $result = $self->model('theme')->_delete_theme( $$data{'id'} );
# 'id'    - id предмета 
sub _delete_theme {
    my ( $self, $id ) = @_;

    my ( $theme, $result );

    unless ( $id ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $theme = Freee::EAV->new( 'User', { 'id' => $id } );

        return unless $theme;

        $result = $theme->_RealDelete();
    }

    return $result;
}

# my $list = $self->model('theme')->_list_theme();
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
    $theme = Freee::EAV->new( 'theme' );
    unless ( $theme ) {
        push @!, "Tree has not any branches";
        return;
    }

    $list = $theme->_list( { Parents => 0, ShowHidden => 1, FIELDS => "has_childs, publish, parent, id", Order => [ { 'items.id' => 'ASC' } ] } );

    foreach my $row ( @$list ) {
        my $EAV_theme = Freee::EAV->new( 'theme', { id => $row->{id} } );
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
        delete $$row{'publish'};
    }

    return $list;
}

#  получить данные для редактирования предмета
#  $result = $self->model('theme')->_get_theme( $$data{'id'} );
# my $data = {
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

    unless ( $id ) {
        push @!, "no data for get";
        return;
    }
    else {
        # взять весь объект из EAV
        $theme = Freee::EAV->new( 'theme', { 'id' => $id } );

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

# сохранить предмет
# $result = $self->model('theme')->_save_theme( $data );
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
        $theme = Freee::EAV->new( 'theme',
            {
                'id'      => $$data{'id'}
            }
        );

        return unless $theme;

        $result = $theme->_MultiStore( {                 
            'theme' => {
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

# изменить статус предмета (вкл/выкл)
# $result = $self->model('theme')->_toggle_theme( $data );
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub _toggle_theme {
    my ( $self, $data ) = @_;

    my ( $theme, $result );

    unless ( $$data{'id'} && defined $$data{'value'} ) {
        return;
    }
    else {
        # обновление поля в EAV
        $theme = Freee::EAV->new( 'theme',
            {
                'id'      => $$data{'id'},
            }
        );

        return unless $theme;

        $result = $theme->_MultiStore( {
            'theme' => {
                'publish' => $$data{'value'}, 
            }
        });
    }

    return $result;
}

# проверка существования предмета с таким id
# my $true = $self->model('theme')->_exists_in_theme( $$data{'parent'}
# 'id'    - id предмета
sub _exists_in_theme {
    my ( $self, $id ) = @_;

    my ( $theme, $result );

    unless ( $id ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $theme = Freee::EAV->new( 'theme',
            {
                'id'      => $id
            }
        );
    }

    return $theme ? 1 : 0;
}

1;