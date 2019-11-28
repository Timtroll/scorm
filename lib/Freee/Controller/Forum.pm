package Freee::Controller::Forum;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my $list = $self->_list_messages();

    # $self->redirect_to( '/forum/list_messages' );
    $self->render(
        'template'    => 'forum/forum',
        'title'       => 'Форум'
    );
}

#########################################################################
# получение списка тем из базы в массив хэшей
sub list_themes {
    my $self = shift;

    my ( $group_id, $list_themes, $resp, @mess);

    $group_id = $self->param( 'group_id' );

    $list_themes = $self->_list_themes( $group_id );
    push @mess, "Could not get list Themes" unless $list_themes;

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $list_themes unless @mess;

    $self->render( 'json' => $resp );
}

# вывод формы для добавления темы
sub add_theme {
    my $self = shift;

    my ($id, $group_id, $data, $list_themes, $list_groups, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $list_themes = $self->_list_themes();
        push @mess, "Could not get list_themes" unless $list_themes;

        $list_groups = $self->_list_groups();
        push @mess, "Could not get list Groups" unless $list_groups;

        $group_id = $$data{'group_id'};
    }

    unless  (@mess) {
        $self->render(
            'template'    => 'forum/list_themes',
            'title'       => 'add_theme',
            'add'         => 1,
            'edit'        => undef,
            'list_themes' => $list_themes,
            'list_groups' => $list_groups,
            'group_id'    => $group_id
        );
    };
}

# сохранение данных из формы после добавления новой темы
sub save_add_theme {
    my $self = shift;

    my ($id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'user_id'}      = 1;
        $$data{'date_created'} = time();
        $$data{'date_edited'}  = time();
        $$data{'rate'}         = 0;

        if ($data) {
            $id = $self->_insert_theme( $data );
            push @mess, "Could not insert data" unless $id;
        }
    }

    $self->redirect_to( '/forum/list_themes?group_id='.$$data{'group_id'} );
}

# сохранение данных из формы, после редактирования существующей темы
sub save_edit_theme {
    my ($self) = shift;

    my ( $id, $parent, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->_exists_in_table('forum_themes', 'id', $$data{'id'}) ) {

                $$data{'user_id'}      = 1;
                $$data{'date_edited'}  = time();
                $$data{'rate'}         = 0;

                # обновление данных
                $id = $self->_update_theme( $data );
                push @mess, "Could not update message" unless $id;
            }
            else {
                push @mess, "Message is not exists";
            }
        }
    }

    $self->redirect_to( '/forum/list_themes?group_id='.$$data{'group_id'} );
}

# выводит форму с данными существующей темы
# "id" => 1 - id выводимого элемента ( >0 )
sub edit_theme {
    my $self = shift;

    my ($id, $group_id, $data, $list_themes, $list_groups, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $data = $self->_get_theme( $$data{'id'} );
        push @mess, "Could not get message '".$$data{'id'}."'" unless $data;

        $list_themes = $self->_list_themes();
        push @mess, "Could not get list_themes" unless $list_themes;

        $list_groups = $self->_list_groups();
        push @mess, "Could not get list Groups" unless $list_groups;

        $group_id = $$data{'group_id'};
    }

    unless  (@mess) {
        $self->render(
            'template'    => 'forum/list_themes',
            'title'       => 'edit_theme',
            'add'         => undef,
            'edit'        => $data,
            'list_themes' => $list_themes,
            'list_groups' => $list_groups,
            'group_id'    => $group_id
        );
    };
}

# удаляет тему по id 
# "id" => 1 - id удаляемого элемента ( >0 )
sub del_theme {
    my $self = shift;

    my ($del, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $del = $self->_delete_theme( $$data{'id'} ) unless @mess;
        push @mess, "Could not delete theme '$$data{'id'}'" unless $del;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $del;

    $self->render( 'json' => $resp );
}

################################################################################
# получение списка групп из базы в массив хэшей
sub list_groups {
    my $self = shift;

    my ( $list_groups, $resp, @mess );

    $list_groups = $self->_list_groups();
    push @mess, "Could not get list Groups" unless $list_groups;

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $list_groups unless @mess;

    $self->render( 'json' => $resp );
}

# вывод формы для добавления группы
sub add_group {
    my $self = shift;

    my ( $list, @mess );

    $list = $self->_list_groups();
    push @mess, "Could not get list Groups" unless $list;

    $self->render(
        'template'    => 'forum/list_groups',
        'title'       => 'list_groups',
        'add'         => 1,
        'edit'        => undef,
        'list_groups' => $list
    );
}

# сохранение данных из формы после добавления новой группы
sub save_add_group {
    my $self = shift;

    my ($id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'date_created'} = time();
        $$data{'date_edited'}  = time();

        if ($data) {
            $id = $self->_insert_group( $data );
            push @mess, "Could not insert data" unless $id;
        }
    }

    $self->redirect_to( '/forum/list_groups' );
}

# сохранение данных из формы, после редактирования существующей группы
sub save_edit_group {
    my ($self) = shift;

    my ( $id, $parent, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->_exists_in_table('forum_groups', 'id', $$data{'id'}) ) {

                $$data{'date_edited'}  = time();

                # обновление данных
                $id = $self->_update_group( $data );
                push @mess, "Could not update group" unless $id;
            }
            else {
                push @mess, "Group does not exist";
            }
        }
    }

    $self->redirect_to( '/forum/list_groups' );
}

# выводит форму с данными о существующей группе
# "id" => 1 - id выводимого элемента ( >0 )
sub edit_group {
    my $self = shift;

    my @mess;

    my $edit = $self->_get_group( $self->param('id') );

    my $list = $self->_list_groups();
    push @mess, "Could not get list Groups" unless $list;

    $self->render(
        'template'    => 'forum/list_groups',
        'title'       => 'list_groups',
        'add'         => undef,
        'edit'        => $edit,
        'list_groups' => $list
    );
}

# удаляет группу по id 
# "id" => 1 - id удаляемого элемента ( >0 )
sub del_group {
    my $self = shift;

    my ($del, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $del = $self->_delete_group( $$data{'id'} ) unless @mess;
        push @mess, "Could not delete group '$$data{'id'}'" unless $del;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $del;

    $self->render( 'json' => $resp );
}

#########################################################################################
# получение списка сообщений из базы в массив хэшей
# sub list_messages {
#     my $self = shift;

#     my ( $theme_id, $group_id, $theme, $list_messages, $list_themes, $list_groups, $group, @mess);

#     $theme_id = $self->param('theme_id');

#     if ( $theme_id ) {
#         $theme = $self->_get_theme( $theme_id );
#         push @mess, "Could not get theme '".$$theme{'id'}."'" unless $theme;
#         $group_id = $$theme{ 'group_id' };
#     }

#     $list_messages = $self->_list_messages( $theme_id );
#     $list_themes = $self->_list_themes();
#     $list_groups = $self->_list_groups();

#     $self->render(
#         'template'      => 'forum/list_messages',
#         'title'         => 'Список сообщений',
#         'list_messages' => $list_messages,
#         'list_themes'   => $list_themes,
#         'list_groups'   => $list_groups,
#         'theme_id'      => $theme_id,
#         'group_id'      => $group_id,
#         'add'           => undef,
#         'edit'          => undef
#     );
# }
sub list_messages {
    my $self = shift;

    my ( $theme_id, $resp, $list_messages, @mess, @messages );

    $theme_id = $self->param('theme_id');

    $list_messages = $self->_list_messages( $theme_id );

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $list_messages unless @mess;

    $self->render( 'json' => $resp );
}

# вывод формы для добавления сообщения
sub add {
    my $self = shift;

    my ($id, $list_messages, $list_themes, $list_groups, $theme, $group_id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;
print $$data{'theme_id'};
        if ( $$data{'theme_id'} ) {
            $theme = $self->_get_theme( $$data{'theme_id'} );
            push @mess, "Could not get theme '".$$theme{'id'}."'" unless $theme;
            $group_id = $$theme{ 'group_id' };
        }
        $list_messages = $self->_list_messages( $$data{'theme_id'} );
        $list_themes = $self->_list_themes();
        $list_groups = $self->_list_groups();
    }

    $self->render(
        'template'      => 'forum/list_messages',
        'title'         => 'Список сообщений',
        'list_messages' => $list_messages,
        'list_themes'   => $list_themes,
        'list_groups'   => $list_groups,
        'theme_id'      => $$data{'theme_id'},
        'group_id'      => $group_id,
        'add'           => 1,
        'edit'          => undef
    );
}

# сохранение данных из формы после добавления нового сообщения
sub save_add {
    my $self = shift;

    my ($id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'user_id'}      = 1;
        $$data{'anounce'}      = substr( $$data{'msg'}, 0, 64);
        $$data{'date_created'} = time();
        $$data{'date_edited'}  = time();
        $$data{'rate'}         = 0;

        if ($data) {
            $id = $self->_insert_message( $data );
            push @mess, "Could not insert data" unless $id;
        }
    }

    $self->redirect_to( '/forum/list_messages?theme_id='.$$data{'theme_id'} );
}

# сохранение данных из формы, после редактирования существующего сообщения
sub save_edit {
    my ($self) = shift;

    my ( $id, $parent, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->_exists_in_table('forum_messages', 'id', $$data{'id'}) ) {

                $$data{'user_id'}      = 1;
                $$data{'anounce'}      = substr( $$data{'msg'}, 0, 64);
                $$data{'date_edited'}  = time();
                $$data{'rate'}         = 0;

                # обновление данных
                $id = $self->_update_message( $data );
                push @mess, "Could not update message" unless $id;
            }
            else {
                push @mess, "Message is not exists";
            }
        }
    }

    $self->redirect_to( '/forum/list_messages?theme_id='.$$data{'theme_id'} );
}

# выводит форму с данными о существующем сообщении
# "id" => 1 - id выводимого элемента ( >0 )
sub edit {
    my $self = shift;

    my ($id, $list_messages, $list_themes, $list_groups, $theme, $group_id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_message( $$data{'id'} );
            push @mess, "Could not get message '".$$data{'id'}."'" unless $data;
        }

        if ( $$data{'theme_id'} ) {
            $theme = $self->_get_theme( $$data{'theme_id'} );
            push @mess, "Could not get theme '".$$theme{'id'}."'" unless $theme;
            $group_id = $$theme{ 'group_id' };
        }
        $list_messages = $self->_list_messages( $$data{'theme_id'} );
        $list_themes = $self->_list_themes();
        $list_groups = $self->_list_groups();
    }

    $self->render(
        'template'      => 'forum/list_messages',
        'title'         => 'Список сообщений',
        'list_messages' => $list_messages,
        'list_themes'   => $list_themes,
        'list_groups'   => $list_groups,
        'theme_id'      => $$data{'theme_id'},
        'group_id'      => $group_id,
        'add'           => undef,
        'edit'          => $data
    );
}

# удалениe сообщения 
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    my ($del, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $del = $self->_delete_message( $$data{'id'} ) unless @mess;
        push @mess, "Could not delete message '$$data{'id'}'" unless $del;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $del;

    $self->render( 'json' => $resp );
}


# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ($toggle, $id, $data, $data_time, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'fieldname'} = 'status';

        $toggle = $self->_toggle( $data ) unless @mess;
        push @mess, "Could not toggle field '$$data{'id'}'" unless $toggle;

        $$data_time{'id'}           = $$data{'id'};
        $$data_time{'date_edited'}  = time();

        # if ( defined $$data{'table'} ) {
        #     if ( $$data{'table'} eq 'forum_messages' ) {
        #         $id = $self->_update_message( $data_time );
        #         push @mess, "Could not update message" unless $id;
        #     }
        #     else {
        #         if ( $$data{'table'} eq 'forum_themes' ) {
        #             $id = $self->_update_theme( $data_time );
        #             push @mess, "Could not update theme" unless $id;
        #         }
        #         else {
        #             if ( $$data{'table'} eq 'forum_groups' ) {
        #                 $id = $self->_update_group( $data_time );
        #                 push @mess, "Could not update group" unless $id;
        #             }
        #         }
        #     }
        # }

        # матрица состояний
        my %hash = (
            'forum_messages' => $self->_update_message( $data_time ),
            'forum_themes'   => $self->_update_theme( $data_time ),
            'forum_groups'   => $self->_update_group( $data_time )
        );
        if ( defined $$data{'table'} ) {
            $id = $hash{ $$data{'table'} };
            push @mess, "Could not update" unless $id;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

1;