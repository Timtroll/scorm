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
            'route'         => 'list'
        }
    );
}

sub add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'add'
        }
    );
}

sub edit {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'edit'
        }
    );
}

sub save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'save'
        }
    );
}

sub activate {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'activate'
        }
    );
}

sub hide {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'hide'
        }
    );
}

sub delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'article',
            'route'         => 'delete'
        }
    );
}

1;