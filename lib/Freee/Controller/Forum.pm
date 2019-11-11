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
        'title'       => 'Форум',
        'list'        => $list
    );
}

# получение списка сообщений из базы в массив хэшей
sub list_messages {
    my $self = shift;

    my ( $list_messages, $theme, $group, @mess);

    my $theme_id = $self->param('theme_id');
    if ( $theme_id ) {
        $theme = $self->_get_theme( $theme_id );
        push @mess, "Could not get theme '".$$theme{'id'}."'" unless $theme;
    }

    $group = $self->_get_group( $$theme{ 'group_id'} );
    $list_messages = $self->_list_messages( $theme_id );

    $self->render(
        'template'      => 'forum/list_messages',
        'title'         => 'Список сообщений',
        'list_messages' => $list_messages,
        't'             => $theme,
        'g'             => $group,
        'theme_id'      => $theme_id
    );
}

# получение списка тем из базы в массив хэшей
sub list_themes {
    my $self = shift;

    my ( $list, @mess, $data, $group );

    my $group_id = $self->param('group_id');
    if ( $group_id ) {
        $group = $self->_get_group( $group_id );
        push @mess, "Could not get group '".$$group{'id'}."'" unless $group;
    }

    $list = $self->_list_themes();
    push @mess, "Could not get list Themes" unless $list;
    
    $self->render(
        'template'    => 'forum/list_themes',
        'title'       => 'list_themes',
        'list_themes' => $list,
        'g'           => $group
    );
}

# получение списка групп из базы в массив хэшей
sub list_groups {
    my $self = shift;

    my ( $list, @mess );

    $list = $self->_list_groups();
    push @mess, "Could not get list Groups" unless $list;

    $self->render(
        'template'    => 'forum/list_groups',
        'title'       => 'list_groups',
        'add'         => undef,
        'edit'        => undef,
        'list_groups' => $list
    );
}

sub theme {
    my $self = shift;

    $self->render(
        'template'    => 'forum/themes/add_theme',
        'title'       => 'add_theme',
        'group_id'    => $self->param( 'parent_id' )
    );
}

sub add_theme {
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

sub save_theme {
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

# вывод  данных о сообщении
# "id" => 1 - id выводимого элемента ( >0 )
sub edit_theme {
    my $self = shift;

    my ($id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_theme( $$data{'id'} );
            push @mess, "Could not get message '".$$data{'id'}."'" unless $data;
        }
    }

    unless  (@mess) {
        $self->render(
            'template'    => 'forum/edit_theme',
            'title'       => 'edit_theme',
            'list'        => $data
        );
    };
}

# удалениe темы 
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

    $self->redirect_to( '/forum/list_themes?group_id='.$$data{'parent_id'} );
}

sub group {
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


sub add_group {
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

sub save_group {
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

# вывод  данных о сообщении
# "id" => 1 - id выводимого элемента ( >0 )
sub edit_group {
    my $self = shift;

    my $edit = $self->param('edit');
    my @mess;

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

# удалениe темы 
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

    $self->redirect_to( '/forum/list_groups' );
}

# новое сообщение форума
# my $id = $self->_insert_message();
# "theme id"
# "user id"
# "anounce"
# "date_created"
# "msg"
# "rate"
# "status"
sub add {
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
        $$data{'status'}       = 1;

        if ($data) {
            $id = $self->_insert_message( $data );
            push @mess, "Could not insert data" unless $id;
        }
    }

    $self->redirect_to( '/forum/list_messages?theme_id='.$$data{'theme_id'} );
}

# сохранение сообщения
# my $id = $self->save();
# "id"        => 1            - id обновляемого элемента ( >0 )
# "label"     => 'название'   - обязательно (название для отображения)
# "name",     => 'name'       - обязательно (системное название, латиница)
# "status"    => 0 или 1      - активно ли сообщение
sub save {
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

# вывод  данных о сообщении
# "id" => 1 - id выводимого элемента ( >0 )
sub edit {
    my $self = shift;

    my ($id, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_message( $$data{'id'} );
            push @mess, "Could not get message '".$$data{'id'}."'" unless $data;
        }
    }

    unless  (@mess) {
        $self->render(
            'template'    => 'forum/edit_message',
            'title'       => 'edit_message',
            'list'        => $data
        );
    };
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

    $self->redirect_to( '/forum/list_messages?theme_id='.$$data{'parent_id'} );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ($toggle, $id, $data, $data_time, $error, @mess, $current_value);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'value'}     = $$data{'value'} ? '0' : '1';
        $$data{'fieldname'} = 'status';

        $toggle = $self->_toggle( $data ) unless @mess;
        push @mess, "Could not toggle field '$$data{'id'}'" unless $toggle;

        $$data_time{'id'}           = $$data{'id'};
        $$data_time{'date_edited'}  = time();

        if ( defined $$data{'table'} ) {
            if ( $$data{'table'} eq 'forum_messages' ) {
                $id = $self->_update_message( $data_time );
                push @mess, "Could not update message" unless $id;
                $self->redirect_to( '/forum/list_messages?theme_id='.$$data{'parent_id'} );
            }
            else {
                if ( $$data{'table'} eq 'forum_themes' ) {
                    $id = $self->_update_theme( $data_time );
                    push @mess, "Could not update theme" unless $id;
                    $self->redirect_to( '/forum/list_themes?group_id='.$$data{'parent_id'} );
                }
                else {
                    if ( $$data{'table'} eq 'forum_groups' ) {
                        $id = $self->_update_group( $data_time );
                        push @mess, "Could not update group" unless $id;
                        $self->redirect_to( '/forum/list_groups' );
                    }
                }
            }
        }
        # # матрица состояний
        # my %hash = (
        #     'forum_messages' => $self->_update_message( $data_time ),
        #     'forum_themes'   => $self->_update_theme( $data_time ),
        #     'forum_groups'   => $self->_update_group( $data_time )
        # );
        # if ( defined $$data{'table'} ) {
        #     $id = $hash{ $$data{'table'} };
        #     push @mess, "Could not update message" unless $id;
        # }
        # $self->redirect_to( '/forum/list_messages?id='.$$data{'theme_id'} );
    } 
    else {
        $self->redirect_to( '/forum/list_messages' );  #????????????????????????????????????????????????????????? 
    }
}

1;