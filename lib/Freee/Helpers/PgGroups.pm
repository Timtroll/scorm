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

    # получение списка групп из базы в виде объекта как в Mock/Groups.pm
    # my $list = $self->_all_groups();
    # возвращает массив хэшей
    $app->helper( '_all_groups' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT id,label FROM "public"."groups"', 'id');

        return $list;
    });

    # получение списка роутов
    $app->helper( '_all_routes' => sub {
        my $self = shift;
        my $list = shift;

        unless ( $list ) {
            $list = $routs;
        }

        return $list;
    });

    # добавление группы пользователей
    # my $id = $self->_insert_group({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
    #     "required"    => 0,               - не обязательно, по умолчанию 0
    #     "readonly"    => 0,               - не обязательно, по умолчанию 0
    #     "removable"   => 0,               - не обязательно, по умолчанию 0
    # возвращается id записи    
    $app->helper( '_insert_group' => sub {
        my ($self, $data) = @_;
        return unless $data;
        my $id;

        if ( $self->pg_dbh->do('INSERT INTO "public"."groups" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
            $id = $self->pg_dbh->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
        }
 
        return $id;
    });

    # изменение группы пользователей
    # my $id = $self->_update_group({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
    #     "required"    => 0,               - не обязательно, по умолчанию 0
    #     "readonly"    => 0,               - не обязательно, по умолчанию 0
    #     "removable"   => 0,               - не обязательно, по умолчанию 0
    # возвращается true/false
    $app->helper( '_update_group' => sub {
        my ($self, $data) = @_;
        return unless $data;

        my $db_result = $self->pg_dbh->do('UPDATE "public"."groups" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};

        return $db_result;
    });


    # для удаления группы пользователей
    # my $true = $self->_delete_group( 99 );
    # возвращается true/false
    $app->helper( '_delete_group' => sub {
        my ($self, $id) = @_;
        return unless $id;
        my $db_result = 0;
        
        if ( ($db_result = $self->pg_dbh->do('DELETE FROM "public"."groups" WHERE "id"='.$id ) ) == "0E0") { 
            print "Row for deleting doesn't exist \n";
            $db_result = 0;
        }   
     
        eval { 
            $self->pg_dbh->begin_work();
            if ( $self->pg_dbh->do('DELETE FROM "public"."groups" WHERE "parent"='.$id) ) {
                if ( $db_result = $self->pg_dbh->do('DELETE FROM "public"."groups" WHERE "id"='.$id ) ) {
                    if ( $db_result == "0E0") { 
                        print "Row for deleting doesn't exist \n";
                        $db_result = 0;
                        $self->pg_dbh->rollback();
                    }   
                }
                else {
                    print "Folder delete doesn't work \n";
                    $self->pg_dbh->rollback();
                }
            } 
            else {
                print "Children delete doesn't work \n";
                $self->pg_dbh->rollback();
            }
            $self->pg_dbh->commit();
        };

        if ($@) { 
                $self->pg_dbh->rollback();
                print "Delete doesn't work \n";
        } 
        print "$db_result \n";

        return $db_result;
    });

    # для проверки существования строки с данным id
    # my $true = $self->_id_check( 99 );
    # возвращается true/false
    $app->helper( '_id_check' => sub {
        my ($self, $id) = @_;
        return unless $id;

        my $db_result = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."groups" WHERE "id"='.$id);

        return $db_result;
    });
}

1;
