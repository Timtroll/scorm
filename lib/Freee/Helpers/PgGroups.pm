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

    # для создания возможностей групп пользователей
    # my $id = $self->_insert_group({
    #       "folder"      => 0,           - это возможности пользователя
    #     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    #     "value"       => "",            - строка или json
    #     "required"    => 0            - не обязательно, по умолчанию 0
    # });
    # для создания группы пользователей
    # my $id = $self->_insert_group({
    #     "folder"      => 1,           - это группа пользователей
    #     "parent"      => 0,           - обязательно 0 (должно быть натуральным числом) 
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    # });
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


    # для создания возможностей групп пользователей
    # my $id = $self->_update_group({
    #     "folder"      => 0,           - это возможности пользователя
    #     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    #     "value"       => "",            - строка или json
    #     "required"    => 0            - не обязательно, по умолчанию 0
    # });
    # для создания группы пользователей
    # my $id = $self->_update_group({
    #     "folder"      => 1,           - это группа пользователей
    #     "parent"      => 0,           - обязательно 0 (должно быть натуральным числом) 
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "removable"   => 0,           - не обязательно, по умолчанию 0
    # });
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


    # для изменения параметра status
    # возвращается true/false
    $app->helper( '_status_group' => sub {
        my ($self, $data) = @_;
        return unless $data;

        my $db_result = $self->pg_dbh->do('UPDATE "public"."groups" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};

        return $db_result;
    });


    # для проверки корректности наследования
    # my $true = $self->_parent_check( 99 );
    # возвращается true/false
    $app->helper( '_parent_check' => sub {
        my ($self, $parent) = @_;

        # это не фолдер?
        if ( $parent ) {
            # есть родитель?
            if ( $self->id_check( $parent ) ) {
                # родитель фолдер?
                if ( $self->pg_dbh->selectrow_array( 'SELECT parent FROM "public"."groups" WHERE "id"='.$parent ) ) {
                    return 0;
                }
            } 
            else {
                return 0;
            }
        }

        return 1;
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
