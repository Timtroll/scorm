package Freee::Helpers::PgGroups;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;
use experimental 'smartmatch';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Groups


    # получение списка настроек из базы в виде объекта как в Mock/Settings.pm
    $app->helper( 'all_groups' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT * FROM "public"."groups"', 'id');
print "list: \n";
print Dumper($list);
#         my $out = {};
#         foreach my $id (sort {$a <=> $b} keys %$list) {  
#             $$out{$id} = {
#                 "id"        => $$list{$id}{'id'},           
#                 "label"     => $$list{$id}{'label'},
#                 "name"      => $$list{$id}{'name'},
#                 "value"     => $$list{$id}{'value'},
#                 "required"  => $$list{$id}{'required'},
#                 "readOnly"  => $$list{$id}{'readOnly'},
#                 "editable"  => $$list{$id}{'editable'},
#                 "removable" => $$list{$id}{'removable'}
#             };
#         }
# print "out: \n";
# print Dumper($out);
        return $list;
    });


    # добавление группы пользователей
    # my $id = $self->insert_group({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
    #     "required"    => 0,               - не обязательно, по умолчанию 0
    #     "editable"    => 0,               - не обязательно, по умолчанию 0
    #     "readOnly"    => 0,               - не обязательно, по умолчанию 0
    #     "removable"   => 0,               - не обязательно, по умолчанию 0
    # возвращается id записи    
    $app->helper( 'insert_group' => sub {
        my ($self, $data) = @_;
        return unless $data;
        my $id;

        if ( $self->pg_dbh->do('INSERT INTO "public"."groups" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
            $id = $self->pg_dbh->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
        }
 
        return $id;
    });


    # изменение группы пользователей
    # my $id = $self->insert_group({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
    #     "required"    => 0,               - не обязательно, по умолчанию 0
    #     "editable"    => 0,               - не обязательно, по умолчанию 0
    #     "readOnly"    => 0,               - не обязательно, по умолчанию 0
    #     "removable"   => 0,               - не обязательно, по умолчанию 0
    # возвращается true/false
    $app->helper( 'update_group' => sub {
        my ($self, $data) = @_;
        return unless $data;

        my $db_result = $self->pg_dbh->do('UPDATE "public"."groups" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};

        return $db_result;
    });


    # для удаления группы пользователей
    # my $true = $self->delete_group( 99 );
    # возвращается true/false
    $app->helper( 'delete_group' => sub {
        my ($self, $id) = @_;
        return unless $id;
        my $db_result = 0;
        
        if ( ($db_result = $self->pg_dbh->do('DELETE FROM "public"."groups" WHERE "id"='.$id ) ) == "0E0") { 
            print "Row for deleting doesn't exist \n";
            $db_result = 0;
        }   
     

        return $db_result;
    });

    # для проверки существования строки с данным id
    # my $true = $self->id_check( 99 );
    # возвращается true/false
    $app->helper( 'id_check' => sub {
        my ($self, $id) = @_;
        return unless $id;

        my $db_result = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$id);

        return $db_result;
    });
}

1;
