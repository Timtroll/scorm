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
        'template'      => 'forum',
        'title'         => 'Форум',
        'list_messages' => $list,
        'list_themes'   => []
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

    $list = $self->_list_themes();
    # push @mess, "Could not get list Themes" unless $list;
    
    $self->render(
        'template'      => 'list_themes',
        'list_themes'   => $list
    );

    # $resp->{'message'} = join("\n", @mess) if @mess;
    # $resp->{'status'} = @mess ? 'fail' : 'ok';
    # $resp->{'list'} = $list unless @mess;

    # $self->render( 'json' => $resp );
}

# сохранение данных из формы после добавления новой темы
sub save_add_theme {
    my $self = shift;

    my ($id, $data, $error, $resp, @mess);
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# сохранение данных из формы, после редактирования существующей темы
sub save_edit_theme {
    my ($self) = shift;

    my ( $id, $resp, $data, $error, @mess );
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# выводит форму с данными существующей темы
# "id" => 1 - id выводимого элемента ( >0 )
sub edit_theme {
    my $self = shift;

    my ($data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_theme( $$data{'id'} );
            push @mess, "Could not get theme '".$$data{'id'}."'" unless $data;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'theme'} = $data if $data;

    $self->render( 'json' => $resp );
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

# сохранение данных из формы после добавления новой группы
sub save_add_group {
    my $self = shift;

    my ($id, $data, $error, $resp, @mess);
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# сохранение данных из формы, после редактирования существующей группы
sub save_edit_group {
    my ($self) = shift;

    my ( $id, $resp, $data, $error, @mess );
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# выводит форму с данными о существующей группе
# "id" => 1 - id выводимого элемента ( >0 )
sub edit_group {
    my $self = shift;

    my ($data, $edit, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $edit = $self->_get_group( $$data{'id'} );
        push @mess, "Could not get group '$$data{'id'}'" unless $edit;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'group'} = $edit if $edit;

    $self->render( 'json' => $resp );
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

sub list_messages {
    my $self = shift;

    my ( $list_messages, $list_themes );

    $list_messages = $self->_list_messages();
    $list_themes  = $self->_list_themes();

    $self->render(
        'template'      => 'list_messages',
        'list_messages' => $list_messages
    );
    # $self->render(
    #     'template'      => 'forum',
    #     'title'         => 'Список сообщений',
    #     'list_messages' => $list_messages,
    #     'list_themes'   => $list_themes
    # );
}

# сохранение данных из формы после добавления нового сообщения
sub save_add {
    my $self = shift;

    my ($id, $data, $error, $resp, @mess);
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->redirect_to( '/forum/list_messages' ) unless @mess;
}

# сохранение данных из формы, после редактирования существующего сообщения
sub save_edit {
    my ($self) = shift;

    my ( $id, $resp, $data, $error, @mess );
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

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->redirect_to( '/forum/list_messages' );
}

# выводит форму с данными о существующем сообщении
# "id" => 1 - id выводимого элемента ( >0 )
sub edit {
    my $self = shift;

    my ($data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    $data = {};
    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_message( $$data{'id'} );
            push @mess, "Could not get message '".$$data{'id'}."'" unless $data;
        }
    }

    $self->render( 'json' => $data );
#     unless  (@mess) {
#         $self->render(
#             'template'    => 'edit',
#             'title'       => 'edit',
#             'list'        => $data
#         );
#     };
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

    $self->redirect_to( '/forum/list_messages' );
}


# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ($toggle, $resp, $data, $error, @mess, $current_value);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;


        $current_value = $self->_status_check( $$data{'id'} ) unless @mess;
        if ( $current_value ) {
            $$data{'value'} = 0;
        }
        else { 
            $$data{'value'} = 1;
        }
        # $$data{'table'} = 'forum_themes' ? $self->param('themes'): 'forum_messages';
        $$data{'table'} = 'forum_messages';
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

    $self->redirect_to( '/forum/list_messages' ) unless @mess;
}

1;