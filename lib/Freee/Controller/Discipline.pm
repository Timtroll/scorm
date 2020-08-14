package Freee::Controller::Discipline;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use Freee::EAV;
use common;
use Data::Dumper;
use Mojo::JSON qw( from_json );

sub index {
    my $self = shift;

    my ( $list, $result, $resp );

    $list = $self->model('Discipline')->_list_discipline();

    unless ( @! ) {
        $result = {
            "label" =>  "Предметы",
            "add"   => 1,              # разрешает добавлять предметы
            "child" =>  {
                "add"    => 1,         # разрешает добавлять детей
                "edit"   => 1,         # разрешает редактировать детей
                "remove" => 1,         # разрешает удалять детей
                "route"  => "/theme",  # роут для получения детей
            },
            "list" => $list
        };
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    $self->render( 'json' => $resp );
}

sub get {
    my $self = shift;

    my ( $data, $resp, $result, $list );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # получение объекта EAV
        $result = $self->model('Discipline')->_get_discipline( $$data{'id'} );
    }

    unless ( @! ) {
        $list = {
            'id'     => $$result{'id'},
            'parent' => $$result{'parent'},
            'folder' => $$result{'parent'} ? 0 : 1,
            'tabs'   => [
                {
                    'label'  => 'основные',
                    'fields' => [
                        { 'label'       => $$result{'label'} },
                        { 'description' => $$result{'description'} },
                        { 'keywords'    => $$result{'keywords'} },
                        { 'url'         => $$result{'url'} },
                        { 'seo'         => $$result{'seo'} },
                        { 'route'       => $$result{'route'} },
                        { 'status'      => $$result{'status'} }
                    ]
                },
                {
                    'label'  => 'Контент',
                    'fields' => [
                        { 'content'    => $$result{'content'} },
                        { 'attachment' => $$result{'attachment'} }
                    ]
                }
            ]
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub add {
    my $self = shift;

    my ( $data, $attachment, $resp, $id );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # проверка существования вложенных файлов
        $attachment = from_json( $$data{'attachment'} );
        foreach ( @$attachment ) {
            unless( $self->model('Utils')->_exists_in_table('media', 'id', $_ ) ) {
                push @!, "file with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! || !$$data{'parent'} ) {
        # проверка существования родителя
        unless( $self->model('Discipline')->_exists_in_discipline( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in discipline";
        }
    }

    unless ( @! ) {
        # добавляем предмет в EAV
        $$data{'status'} = 1 unless defined $$data{'status'};
        $$data{'date_updated'} = $self->model('Utils')->_get_time();

        $id = $self->model('Discipline')->_insert_discipline( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub save {
    my $self = shift;

    my ( $data, $attachment, $resp, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # проверка существования вложенных файлов
        $attachment = from_json( $$data{'attachment'} );
        foreach ( @$attachment ) {
            unless( $self->model('Utils')->_exists_in_table('media', 'id', $_ ) ) {
                push @!, "file with id '$_' doesn't exist";
                last;
            }
        }
    }

    unless ( @! || !$$data{'parent'} ) {
        # проверка существования родителя
        unless( $self->model('Discipline')->_exists_in_discipline( $$data{'parent'} ) ) {
            push @!, "parent with id '$$data{'parent'}' doesn't exist in discipline";
        }
    }

    unless ( @! ) {
        $$data{'status'} = 1 unless defined $$data{'status'};
        $$data{'title'} = join(' ', ( $$data{'name'}, $$data{'label'} ) );
        $$data{'time_update'} = $self->model('Utils')->_get_time();

        # добавляем предмет в EAV
        $result = $self->model('Discipline')->_save_discipline( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub toggle {
    my $self = shift;

    my ( $data, $resp, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # добавляем предмет в EAV
        $result = $self->model('Discipline')->_toggle_discipline( $data );
        push @!, "can't update EAV" unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my ( $data, $resp, $result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # добавляем предмет в EAV
        $result = $self->model('Discipline')->_delete_discipline( $$data{'id'} );
        push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;