package Freee::Controller::Article;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

# use Freee::Helpers::TableObj;

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

print "2\n";
    my $test = $self->table_obj({
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
            'controller'    => 'article',
            'route'         => 'index',
            'params'        => $self->req->params->to_hash,
            'test'          => $test
        }
    );
}

sub list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'list',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'add',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'edit',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'save',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'activate',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'hide',
            'params'        => $self->req->params->to_hash
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'delete',
            'params'        => $self->req->params->to_hash
        }
    );
}

1;