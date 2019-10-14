package Freee::Controller::Forum;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'template'    => 'forum',
        'title'       => 'Форум'
    );
}

sub listthemes {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'listthemes',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
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

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'forum',
            'route'         => 'add',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
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