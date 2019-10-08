package Freee::Helpers::PgRoutes;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Routes

    # получение списка рутов из базы в массив хэшей
    $app->helper( '_routes_values' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT id, label FROM "public"."routes"', 'id');

        return $list;
    });


    # обновление роута
    # my $id = $self->_update_route({
    #      "id"         => 1,           - id обновляемого элемента ( >0 )
    #     "parent"      => 5,           - обязательно id родителя (должно быть натуральным числом)
    #     "label"       => 'название',  - обязательно (название для отображения)
    #     "name",       => 'name'       - обязательно (системное название, латиница)
    #     "readonly"    => 0,           - не обязательно, по умолчанию 0
    #     "value"       => "",          - строка или json
    #     "required"    => 0,           - не обязательно, по умолчанию 0
    #     "status"      => 0            - по умолчанию 1
    # });
    # возвращается true/false
    $app->helper( '_update_route' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $db_result;
        eval {
            $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET '.join( ', ', map { "\"$_\"=".$self->pg_dbh->quote( $$data{$_} ) } keys %$data )." WHERE \"id\"=".$self->pg_dbh->quote( $$data{id} )." RETURNING \"id\"") if $$data{id};
        };

        if ($@) { 
            print $DBI::errstr . "\n";
        }

        return $db_result;
    });


    # синхронизация между роутами в системе и таблицей
    $app->helper( '_sync_routes' => sub {
        my $self = shift;

        my $list = $self->pg_dbh->selectall_hashref('SELECT id, label, name FROM "public"."routes"', 'id');

        my $hashlist;
# print Dumper \%$routs;
# print "\n";
# print ( exists $$routs{ "/exam" } );
# print "\n";
# print ( exists $$routs{ $$list{2}{'name'} } );
# unless ( exists $$routs{ $$list{2}{'name'} }) {
#     print ("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
# }
# print "\n";
# print Dumper $$list{2}{'name'};

# print Dumper $$list{9}{'name'};
# print "\n";
# print Dumper $$list{9};
# print "\n";
# print Dumper $routs;
# my $t = $$list{9};
# if ( exists $$list{9}{ "/lesson" } ) {
#     print"aaaaa";
# }
# if ( exists $$routs{ "/lesson" } ) {
#     print"bbbbb";
# }

        foreach my $id (sort {$a <=> $b} keys %$list) {
            unless ( exists $$routs{ $$list{$id}{'name'} } ) {
                $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ); 
            }
            $$hashlist{ $$list{ $id }{'name'} } = $id;      
        }

        foreach my $name (keys %$routs) {
            if ( exists $$hashlist{ $name } ) {
                if ( $self->pg_dbh->do( 'INSERT INTO "public"."routes" (label,name) VALUES '.$name.','.$$routs{$name} ) ){
                    print "\n";
                    print $name;
                    print "\n";
                    print $$routs{$name};
                    print "\n";
                }
            }
        }
    


# print "\n";
# print ( exists $$list{$id}{ $name } );
# print "\n";
# print ( exists $$routs{ $$list{2}{'name'} } );
# unless ( exists $$routs{ $$list{2}{'name'} }) {
#     print ("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
# }
# print "\n";
# print Dumper $$routs{'key'};
# print $$list{ '9' };
# unless ( exists { %$list{ '9' } }{ '/lesson' } ) {
#     print "aaaaaaa";
# }

#         foreach my $name (keys %$routs) {
#             #print $name;
#             if ( exists $$list{ '9' }{ $name } ){
#                 print "aaaaaa";
#             }
            # foreach my $id (sort {$a <=> $b} keys %$list) {
            #     if ( exists $$list{ $id }{ $name } ) {
            #         print $$list{ $id }{ $name };
            #     }
            # }        
        #}




        




        # foreach my $id (sort {$a <=> $b} keys %$list) {
        #     foreach my $name (keys %$routs) {
        #         if ( exists ${ $$list{ $id } }{ $name } ) {
        #             print"aaaaa";
        #         }
        #     }
        # }
    });


    # добавление роута
    # my $id = $self->_insert_route({
    #     "label"       => 'название',      - название для отображения
    #     "name",       => 'name',          - системное название, латиница
    #     "value"       => '{"/route":1}',  - строка или json для записи или '' - для фолдера
    #     "status"      => 0                - активность элемента, по умолчанию 1
    # });
    # возвращается id роута
    $app->helper( '_insert_route' => sub {
        my ($self, $data) = @_;

        return unless $data;

        my $id;
        eval{
            if ( $self->pg_dbh->do('INSERT INTO "public"."routes" ('.join( ',', map { "\"$_\""} keys %$data ).') VALUES ('.join( ',', map { $self->pg_dbh->quote( $$data{$_} ) } keys %$data ).') RETURNING "id"') ) {
                $id = $self->pg_dbh->last_insert_id( undef, 'public', 'routes', undef, { sequence => 'routes_id_seq' } );
            }
        };

        if ($@) { 
            print $DBI::errstr . "\n";
        }

        return $id;
    });


    # проверка на наличие в бд строки с таким системным названием
    # my $true = $self->_name_check_route ( /cms/item );
    # возвращается true/false
    $app->helper( '_name_check_route' => sub {

        my ($self, $name) = @_;

        return unless $name;

        my $db_result = $self->pg_dbh->selectrow_hashref('SELECT * FROM "public"."routes" WHERE "name"='.$name);

        return $db_result;
    });


    # # удаление роута
    # # my $true = $self->_delete_route( 99 );
    # # возвращается true/false
    # $app->helper( '_delete_route' => sub {
    #     my ($self, $id) = @_;

    #     return unless $id;

    #     my $db_result = 0;
        
    #     if ( ( $db_result = $self->pg_dbh->do( 'DELETE FROM "public"."routes" WHERE "id"='.$id ) ) == "0E0" ) { 
    #         print "Row for deleting doesn't exist \n";
    #         $db_result = 0;
    #     }   

    #     return $db_result;
    # });


    # # изменение параметра status на 0
    # # возвращается true/false
    # $app->helper( '_hide_route' => sub {

    #     my ($self, $id) = @_;

    #     return unless $id;

    #     my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET "status" = 0 WHERE "id"='.$id );

    #     return $db_result;
    # });


    # # изменение параметра status на 1
    # # возвращается true/false
    # $app->helper( '_activate_route' => sub {

    #     my ($self, $id) = @_;

    #     return unless $id;

    #     my $db_result = $self->pg_dbh->do('UPDATE "public"."routes" SET "status" = 1 WHERE "id"='.$id );

    #     return $db_result;
    # });

}

1;
