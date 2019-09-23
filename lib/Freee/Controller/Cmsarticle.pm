package Freee::Controller::Cmsarticle;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

# use Freee::Helpers::TableObj;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

print "2\n";
    my $test = $self->_table_obj({
        "settings"  => {
            "readOnly"    => 0,
            # "totalCount"  => scalar(@{$table->{'body'}}),
            "editable"    => 1,
            "removable"   => 1,
            "massEdit"    => 0
        },
        "header"    => [
            { "key" => "name",          "label" => "Расшифровка" },
            { "key" => "label",         "label" => "Расшифровка" },
            { "key" => "value",         "label" => "Расшифровка" },
            { "key" => "type",          "label" => "Расшифровка" },
            { "key" => "placeholder",   "label" => "Расшифровка" },
            { "key" => "mask",          "label" => "Расшифровка" },
            { "key" => "selected",      "label" => "Расшифровка" },
            { "key" => "editable",      "label" => "Расшифровка" }
        ],
        "body"      => []
    });

    $self->render(
        'json'    => {
            'controller'    => 'Cmsarticle',
            'route'         => 'index',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash,
            'test'          => $test
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