package Freee::Helpers;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Websocket

    #################################
    # Helper for RabbitMQ


    #################################
    # Helper for Postgress
    $app->helper(
        list_fields => sub  {
            my $self = shift;
            my $items = $self->pg_main->selectrow_hashref('SELECT id, title, alias, type FROM "public"."EAV_fields" WHERE 1 = 1'); #, {Slice=>{}}, undef);
            return $items;
        }
    );
#   $app->helper(
#       catnav => sub {
#           my ($self,$cat_id) = @_;
#           my $cat = $self->db_film->selectrow_hashref("SELECT c.url,c.category_id,c.category_name,x.category_parent_id,c.category_publish FROM  `jos_vm_category_xref` x JOIN  `jos_vm_category` c ON x.category_child_id = c.category_id WHERE c.category_id=?",{Slice=>{}},$cat_id);
#           my @path;
#           push @path,$cat;
#           if ($cat->{category_parent_id}) {
#               unshift @path,$self->catnav($cat->{category_parent_id});
#           }
#           return @path;
#       }
#   );

#   $app->helper(
#       mcat => sub {
#           my $self = shift;
#           my $cat = $self->db_film->selectall_arrayref("SELECT c.* FROM  `jos_vm_category_xref` x JOIN  `jos_vm_category` c ON x.category_child_id = c.category_id WHERE x.`category_parent_id` =0 AND c.`category_publish` =  'Y' order by c.list_order",{Slice=>{}});
#           return $cat;
#       }
#   );

#   $app->helper(
#       brands => sub {
#           my $self = shift;
#           my $brands  = $self->db_film->selectall_arrayref('SELECT * FROM jos_vm_manufacturer WHERE mf_mainpage=1 ORDER BY mf_name',{Slice=>{}});
#           return $brands;
#       }
#   );

#   $app->helper(
#       subnumber => sub {
#           my $self = shift;
#           if ( defined $self->param('from') && ( $self->param('from') == 35 or $self->param('from') == 10995 )) {
#               $self->session->{subnumber} = '+7 (861) 205-05-32';
#           }
#           return $self->session->{subnumber};
#       }
#   );

#   $app->helper(
#       seo => sub {
#           my $self = shift;
#           my $param = shift;
#           my $value = shift;
#           if ($value) {
#               $self->stash($param,$value);
#           } else {
#               return $self->stash($param);
#           }
#       }
#   );

#   $app->helper(
#       brand => sub {
#           my $self = shift;
#           return $self->db_film->selectrow_array("SELECT mf_name FROM  `jos_vm_manufacturer` WHERE manufacturer_id=? ",{Slice=>{}},shift);
#       }
#   );

#   $app->helper(
#       listtype => sub {
#           my $self = shift;
#           my $type = shift;
#           if ($type) {
#               $self->session->{listtype} = $type;
#               return $type;
#           } else {
#               return $self->session->{listtype} ? $self->session->{listtype} : 'list';
#           }
#       }
#   );

#   $app->helper(
#       news => sub {
#           my $self = shift;
#           my $catid = shift;
#           my $news = $self->db_film->selectall_arrayref("SELECT introtext,id,title,date_format(created,'%d-%m-%Y') as created FROM  `jos_content` WHERE  `sectionid` =1 AND  `catid` = ? ORDER BY  `jos_content`.`id` DESC LIMIT 5",{Slice=>{}},$catid);
#           if ($catid == 2) {
#               for(@$news) {
#                   if ($_->{introtext} =~ m{embed\/(.*?)\"}gi) {
#                       $_->{youtube} = $1;

#                   }
#               }
#           }
#           return $news;
#       }
#   );

#   $app->helper(
#       time_of_day => sub {
    #     my $self = shift;
    #     my @date = localtime();
    #     if ($date[2] >= 9 and $date[2] <= 20) {
    #         return $self->phone();
    #     }
    #     return "";
            
    # }
#   )
}

1;
