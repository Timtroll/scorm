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

    # $self->redirect_to( '/forum/list_messages' );
    $self->render(
        'template'  => 'manage_eav',
        'title'     => 'Работа с EAV'
    );
}

sub root {
    my $self = shift;

        $theme = Freee::EAV->new( 'Theme', { 'parent' => 0 } );
print Dumper($theme);
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
        #        "status"      => $$result{'publish'}
        #     }
        # } 
        # else {
        #     push @!, 'can\'t get list';
        #     return;
        # }

    my $root = {
        "name" => "root",
        "parent" => 11,
        "children" => [
            {
                "name" => "set",
                "parent" => 111,
                "children" => [
                    {
                        "name" => "cluster",
                        "children" => [
                            {
                                "name" => "AgglomerativeCluster",
                                "size" => 1
                            }, {
                                "name" => "CommunityStructure",
                                "size" => 1
                            }, {
                                "name" => "HierarchicalCluster",
                                "size" => 1
                            }, {
                                "name" => "MergeEdge",
                                "size" => 1
                            }
                        ]
                    },
                    {
                        "name" => "graph",
                        "children" => [
                            {
                                "name" => "BetweennessCentrality",
                                "size" => 1
                            }, {
                                "name" => "LinkDistance",
                                "size" => 1
                            }, {
                                "name" => "MaxFlowMinCut",
                                "size" => 1
                            }, {
                                "name" => "ShortestPaths",
                                "size" => 1
                            }, {
                                "name" => "SpanningTree",
                                "size" => 1
                            }
                        ]
                    },
                    {
                        "name" => "optimization",
                        "children" => [
                            {
                                "name" => "AspectRatioBanker",
                                "size" => 1
                            }
                        ]
                    }
                ]
            }
        ]
    };

    $self->render( 'json' => $root );
}

1;