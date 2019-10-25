package Freee::Controller::Forum;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use common;


sub index {
    my ($self);
    $self = shift;
my $list = $self->_list_themes();

print Dumper $list;
    foreach my $t( @$list ) {
print"\n";
print"$$t{'title'}";
print"\n";
    }

    $self->render(
        'template'    => 'forum',
        'title'       => 'Форум',
        list => $list
    );
}

sub listthemes {
    my $self = shift;

    my ( $list, $resp, @mess );

    $list = $self->_list_themes();
    push @mess, "Could not get list Themes" unless $list;
    
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

sub listgroups {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'listgroups',
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

    my ($id, $data, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    # устанавляваем поля по умолчанию
    # $self->param('theme_id') = 1;
    # $self->param('user_id') = 1;
    # $self->param('anounce') = '';
    # $self->param('date_created') = localtime;
    # $self->param('rate') = 0;
    # $self->param('status') = 1;    $$data{'theme id'} = 1;

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct message item" unless $data;

        $$data{'user_id'} = 1;
        $$data{'theme_id'} = 1;
        $$data{'anounce'} = '';
        $$data{'date_created'} = 25102019;
        # $$data{'date_created'} = localtime;
        $$data{'rate'} = 0;
        $$data{'status'} = 1;

        if ($data) {
            $id = $self->_insert_message( $data );
            push @mess, "Could not insert data" unless $id;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->redirect_to( '/forum/' );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'edit',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'delete',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ($toggle, $resp, $data, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Group '$$data{'id'}'" unless $data;

        $$data{'table'} = 'forum_themes' ? $self->param('themes'): 'forum_messages';
        $toggle = $self->_toggle( $data ) unless @mess;
        push @mess, "Could not toggle Group '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}


1;