package Freee::Controller::Forum;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use common;


sub index {
    my $self = shift;

    my $list = $self->_list_messages();

    $self->render(
        'template'    => 'forum',
        'title'       => 'Форум',
        'list'        => $list
    );
}

# получение списка тем из базы в массив хэшей
sub list_themes {
    my $self = shift;

    my ( $list, $resp, @mess );

    $list = $self->_list_themes();
    push @mess, "Could not get list Themes" unless $list;
    
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @mess;

    $self->render( 'json' => $resp );
}

# получение списка групп из базы в массив хэшей
sub list_groups {
    my $self = shift;

    my ( $list, $resp, @mess );

    $list = $self->_list_groups();
    push @mess, "Could not get list Groups" unless $list;
    
    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @mess;

    $self->render( 'json' => $resp );
}

sub theme {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'theme',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub add_theme {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'add_theme',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit_theme {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'edit_theme',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub del_theme {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'del_theme',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub group {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'group',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub add_group {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'add_group',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit_group {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'edit_group',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub del_group {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'del_group',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

# получение списка сообщений из базы в массив хэшей
sub list_messages {
    my $self = shift;

    my ( $list_messages, $list_themes );

    $list_messages = $self->_list_messages();
    $list_themes  = $self->_list_themes();

    $self->render(
        'template'      => 'forum',
        'title'         => 'Список сообщений',
        'list_messages' => $list_messages,
        'list_themes'   => $list_themes
    );
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

    my ($id, $data, $error, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $$data{'user_id'}      = 1;
        $$data{'theme_id'}     = 1;
        $$data{'anounce'}      = substr( $$data{'msg'}, 0, 64);
        $$data{'date_created'} = time;
        $$data{'rate'}         = 0;
        $$data{'status'}       = 1;

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

# сохранение сообщения
# my $id = $self->save();
# "id"        => 1            - id обновляемого элемента ( >0 )
# "label"     => 'название'   - обязательно (название для отображения)
# "name",     => 'name'       - обязательно (системное название, латиница)
# "status"    => 0 или 1      - активно ли сообщение
sub save {
    my ($self) = shift;

    my ( $id, $parent, $data, $error, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->_exists_in_table('forum_messages', 'id', $$data{'id'}) ) {

                $$data{'user_id'}      = 1;
                $$data{'theme_id'}     = 1;
                $$data{'anounce'}      = substr( $$data{'msg'}, 0, 64);
                $$data{'date_created'} = time;
                $$data{'rate'}         = 0;

                # обновление данных группы
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
            'template'    => 'edit',
            'title'       => 'edit',
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
    }

    $self->redirect_to( '/forum/list_messages' ) unless @mess;
}

1;