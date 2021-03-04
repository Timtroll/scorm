package Freee::Controller::Cmsarticle;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    my $list = { 'body' => [] };
    my $table = {
        "settings" => {
            "massEdit"  => 1,        # групповое редактировани
            "editable"  => 1,        # разрешение редактирования
            "removable" => 1,        # разрешение удаления
            "sort" => {              # сотрировка по
                "name"    => "id",
                "order"   => "asc"
            },
            "page" => {
              "current_page"    => 1,
              "per_page"        => 100,
              "total"           => scalar(@{$list->{'body'}})
            },
        },
        "body" => $list
    };

    $self->render(
        'json'    => {
            'controller'    => 'Cmsarticle',
            'route'         => 'index',
            'status'        => 'ok',
            # 'params'        => $self->req->params->to_hash,
            'table'          => $table
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Cmsitems',
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
            'controller'    => 'Cmsitems',
            'route'         => 'edit',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Cmsitems',
            'route'         => 'save',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Cmsitems',
            'route'         => 'activate',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Cmsitems',
            'route'         => 'hide',
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
            'controller'    => 'Cmsitems',
            'route'         => 'delete',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;