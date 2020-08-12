package Freee::Model::Discipline;

use Mojo::Base 'Freee::Model::Base';

use Data::Dumper;

###################################################################
# Предметы
###################################################################

# Добавлением нового предмета в EAV
# $id = $self->model('Discipline')->_insert_discipline( $data );
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
sub _insert_discipline {
    my ( $self, $data ) = @_;

    my ( $sth, $discipline, $id );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        # делаем запись в EAV
        $discipline = Freee::EAV->new( 'Discipline',
            {
                'parent'       => $$data{'parent'},
                'title'        => $$data{'name'},
                'publish'      => $$data{'status'},
                'Discipline' => {
                    'parent'       => $$data{'parent'},
                    'date_updated' => $$data{'date_updated'},
                    'label'        => $$data{'label'},
                    'description'  => $$data{'description'},
                    'content'      => $$data{'content'},
                    'keywords'     => $$data{'keywords'},
                    'import_source'=> $$data{'avatar'},
                    'url'          => $$data{'url'},
                    'seo'          => $$data{'seo'},
                    'attachment'   => $$data{'attachment'}
                }
            }
        );
        $id = $discipline->id();
        unless ( $id ) {
            push @!, "Could not insert discipline into EAV";
        }
    }

    return $id;
}

sub _delete_discipline {
    my ( $self, $id ) = @_;

    my ( $discipline, $result );

    unless ( $id ) {
        push @!, 'no id for delete';
    }
    else {
        # удаление из EAV
        $discipline = Freee::EAV->new( 'User', { 'id' => $id } );

        return unless $discipline;

        $result = $discipline->_RealDelete();
    }

    return $result;
}

# my $data = {
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
sub _list_discipline {
    my $self = shift;

    my ( $discipline, $result, $list );

    # инициализация EAV
    $discipline = Freee::EAV->new( 'Discipline' );
    unless ( $discipline ) {
        push @!, "Tree has not any branches";
        return;
    }

    #     my $usr = Freee::EAV->new( 'User' );
    #     my $list = $usr->_list( $dbh, { Filter => { 'User.surname' => $value } } );

    # $list = $discipline->_list( { FIELDS => 'id', INJECTION => '"public"."EAV_data_string"' });
    $list = $discipline->_list( { FIELDS => 'url' });
    warn Dumper( 'list:' );
    warn Dumper( $list );

    # $list = $discipline->_getAll();
    # warn Dumper( $list );

    # if ( $result ) {
    #     $list = {
    #        "id"          => $$result{'id'},
    #        "label"       => $$result{'label'},
    #        "description" => $$result{'description'},
    #        "content"     => $$result{'content'},
    #        "keywords"    => $$result{'keywords'},
    #        "url"         => $$result{'url'},
    #        "seo"         => $$result{'seo'},
    #        "route"       => $$result{'route'},
    #        "parent"      => $$result{'parent'},
    #        "attachment"  => $$result{'attachment'},
    #        "status"      => $$result{'publish'}
    #     }
    # } 
    # else {
    #     push @!, 'can\'t get list';
    #     return;
    # }
# warn Dumper( $result );

    return $list;
}

# my $data = {
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

    unless ( $id ) {
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

sub _save_discipline {
    my ( $self, $data ) = @_;

    my ( $discipline, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }
    else {
        # обновление полей в EAV
        $discipline = Freee::EAV->new( 'Discipline',
            {
                'id'      => $$data{'id'}
            }
        );

        return unless $discipline;

        $result = $discipline->_MultiStore( {                 
            'Discipline' => {
                'title'        => $$data{'title'},
                'parent'       => $$data{'parent'}, 
                'title'        => $$data{'name'},
                'label'        => $$data{'label'},
                'description'  => $$data{'description'},
                'content'      => $$data{'content'},
                'keywords'     => $$data{'keywords'},
                'import_source'=> $$data{'avatar'},
                'url'          => $$data{'url'},
                'date_updated' => $$data{'time_update'},
                'publish'      => $$data{'status'},
                'seo'          => $$data{'seo'}
            }
        });
    }

    return $result;
}

sub _toggle_discipline {
    my ( $self, $data ) = @_;

    my ( $discipline, $result );

    unless ( $$data{'id'} && defined $$data{'value'} ) {
        return;
    }
    else {
        # обновление поля в EAV
        $discipline = Freee::EAV->new( 'Discipline',
            {
                'id'      => $$data{'id'},
            }
        );

        return unless $discipline;

        $result = $discipline->_MultiStore( {
            'Discipline' => {
                'publish' => $$data{'value'}, 
            }
        });
    }

    return $result;
}

sub _exists_in_discipline {
    my ( $self, $id ) = @_;

    my ( $discipline, $result );

    unless ( $id ) {
        push @!, 'no id for check';
    }
    else {
        # поиск объекта с таким id
        $discipline = Freee::EAV->new( 'Discipline',
            {
                'id'      => $id
            }
        );
    }

    return $discipline ? 1 : 0;
}

1;