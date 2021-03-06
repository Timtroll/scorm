package Freee::Controller::Manage;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Freee::Model::Utils;

use Freee::EAV;
use common;
use Data::Dumper;


sub index {
    my $self = shift;

    $self->res->headers->append( 'token' => $self->req->headers->header('token') );
    $self->render(
        'template'  => 'manage_eav',
        'title'     => 'Работа с EAV',
        'token'     => $self->req->headers->header('token')
    );
}

sub root {
    my $self = shift;

        my $theme = Freee::EAV->new( 'User' );
warn Dumper($theme->_sets);
my $root = {
    "name"      => "Sets",
    "parent"    => 0,
    "children"  => []
};
foreach ( keys %{$theme->_sets}) {
    my $item = {
        "name"  => $_,
        "size"  => 1
    };
    push @{$root->{"children"}}, $item;
}
warn Dumper($root);

        # unless ( $theme ) {
        #     push @!, "theme with id '$id' doesn't exist";
        #     return;
        # }

        # $result = $theme->_getAll();
        # if ( $result ) {
        #     $list = {
        #        "id"          => $$result{'id'},
        #        "label"       => $$result{'label'},
        #        "description" => $$result{'description'},
        #        "content"     => $$result{'content'},
        #        "keywords"    => $$result{'keywords'},
        #        "url"         => $$result{'url'},
        #        "seo"         => $$result{'seo'},
        #        "route"       => '/theme',
        #        "parent"      => $$result{'parent'},
        #        "attachment"  => $$result{'attachment'},
        #        "publish"      => $$result{'publish'}
        #     }
        # } 
        # else {
        #     push @!, 'can\'t get list';
        #     return;
        # }


    $self->render( 'json' => $root );
}

1;