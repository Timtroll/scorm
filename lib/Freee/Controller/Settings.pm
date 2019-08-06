package Freee::Controller::Settings;

use utf8;
use Encode;

# use open qw(:utf8);
# binmode(STDIN,':utf8');
# binmode(STDOUT,':utf8');
# binmode(STDIN, ':encoding(UTF-8)');
# binmode(STDOUT, ':encoding(UTF-8)');

use Mojo::Base 'Mojolicious::Controller';
use Mojo::File;


use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    my $path = Mojo::File->new('/home/troll/workspace/scorm/docs/pref_tabs_fields.txt');
    my $settings = $path->slurp;
    utf8::decode($settings);

    # показываем все настройки
    $self->render(
        json    => $settings
    );
}

sub set_tab_list {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_tab_list'
        }
    );
}

sub set_addtab {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_addtab'
        }
    );
}

sub set_savetab {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_savetab'
        }
    );
}

sub set_deletetab {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_deletetab'
        }
    );
}

sub set_add {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_add'
        }
    );
}

sub set_save {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_save'
        }
    );
}

sub set_delete {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Settings',
            'route'         => 'set_delete'
        }
    );
}

1;