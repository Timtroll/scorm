package Freee::Controller::Stream;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    $self->render(
        'json'    => {
            'controller'    => 'Library',
            'route'         => 'index',
            'status'        => 'ok',
            'params'        => $self->req->params->to_hash,
            'test'          => 'test'
        }
    );
}

sub add {
    my $self = shift;

    my ( $id, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, используется ли имя другим потоком
        if ( $self->model('Utils')->_exists_in_table('streams', 'name', $$data{'name'} ) ) {
            push @!, "name '$$data{ name }' already exists"; 
        }

        if ( $$data{'master_id'} ) {
            # проверяем, существует ли руководитель
            unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'master_id'} ) ) {
                push @!, "user with id '$$data{'master_id'}' doesn/'t exist"; 
            }
            # проверяем, является ли пользователь учителем
            unless ( $self->model('Utils')->_is_teacher( $$data{'master_id'} ) ) {
                push @!, "User '$$data{'master_id'}' is not a teacher";
            }
        }
    }

    unless ( @! ) {
        $$data{'owner_id'} = $tokens->{ $self->req->headers->header('token') }->{'id'} if $$data{'master_id'};

        $id = $self->model('Stream')->_insert_stream( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub edit {
    my $self = shift;

    my ( $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $result = $self->model('Stream')->_get_stream( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# обновление потока
# my $id = $self->save();
# "id"        => 1             - id обновляемого элемента ( >0 )
# "name",     => 'name'        - обязательно (системное название, латиница)
# 'age'       => 1,            - год обучения, обязательное поле
# 'date'      => '01-09-2020', - дата начала обучения, обязательное поле
# 'master_id' => 11,           - id руководителя
# "status"    => 0 или 1       - активен ли поток
sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $resp, $owner_id );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования обновляемой строки
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('streams', 'id', $$data{'id'}) ) {
            push @!, "Stream with id '$$data{'id'}' does not exist";
        }
        if ( $self->model('Utils')->_exists_in_table('streams', 'name', $$data{'name'}, $$data{'id'} ) ) {
            push @!, "Stream with name '$$data{'name'}' already exists";
        }

        if ( $$data{'master_id'} ) {
            # проверяем, является ли пользователь учителем
            unless ( $self->model('Utils')->_is_teacher( $$data{'master_id'} ) ) {
                push @!, "User '$$data{'master_id'}' is not a teacher";
            }
        }
    }

    unless ( @! ) {
        # смена поля status на publish
        $$data{'publish'} = $$data{'status'};
        delete $$data{'status'};

        $owner_id = $tokens->{ $self->req->headers->header('token') }->{'id'};

        # обновление данных группы
        $id = $self->model('Stream')->_update_stream( $data, $owner_id );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# изменение поля на 1/0
# my $true = $self->toggle();
#   'id'    => <id> - id записи
#   'field' => имя поля в таблице
#   'val'   => 1/0
sub toggle {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # Поток существует?
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table( 'streams', 'id', $$data{'id'} ) ) {
            push @!, "Id '$$data{'id'}' doesn't exist";
        }
    }

    unless ( @! ) {
        $$data{'fieldname'} = 'publish';
        $$data{'table'} = 'streams';
        $toggle = $self->model('Utils')->_toggle( $data );
        push @!, "Could not toggle Stream '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалениe потока
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    my ( $id, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $id = $self->model('Stream')->_delete_stream( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub user_add {
    my $self = shift;

    my ( $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, существует ли поток
        unless ( $self->model('Utils')->_exists_in_table('streams', 'id', $$data{'stream_id'} ) ) {
            push @!, "Stream '$$data{'stream_id'}' does not exist"; 
        }

        # проверяем, существует ли пользователь
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'user_id'} ) ) {
            push @!, "User '$$data{'user_id'}' does not exist"; 
        }

        # проверяем, входит ли пользователь в поток
        if ( $self->model('Stream')->_check_user_stream( $data ) ) {
            push @!, "User '$$data{'user_id'}' already in stream"; 
        }
    }

    unless ( @! ) {
        $$data{'owner_id'} = $tokens->{ $self->req->headers->header('token') }->{'id'};

        $result = $self->model('Stream')->_insert_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'stream_id'} = $$data{'stream_id'} unless @!;
    $resp->{'user_id'} = $$data{'user_id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub user_delete {
    my $self = shift;

    my ( $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, существует ли поток
        unless ( $self->model('Utils')->_exists_in_table('streams', 'id', $$data{'stream_id'} ) ) {
            push @!, "Stream '$$data{'stream_id'}' does not exist"; 
        }

        # проверяем, существует ли пользователь
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'user_id'} ) ) {
            push @!, "User '$$data{'user_id'}' does not exist"; 
        }

        # проверяем, входит ли пользователь в поток
        unless ( $self->model('Stream')->_check_user_stream( $data ) ) {
            push @!, "User '$$data{'user_id'}' not in stream"; 
        }
    }

    unless ( @! ) {
        $result = $self->model('Stream')->_delete_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'stream_id'} = $$data{'stream_id'} unless @!;
    $resp->{'user_id'} = $$data{'user_id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub master_add {
    my $self = shift;

    my ( $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, существует ли поток
        unless ( $self->model('Utils')->_exists_in_table('streams', 'id', $$data{'stream_id'} ) ) {
            push @!, "Stream '$$data{'stream_id'}' does not exist"; 
        }

        # проверяем, существует ли пользователь
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'master_id'} ) ) {
            push @!, "User '$$data{'master_id'}' does not exist"; 
        }

        # проверяем, является ли пользователь учителем
        unless ( $self->model('Utils')->_is_teacher( $$data{'master_id'} ) ) {
            push @!, "User '$$data{'master_id'}' is not a teacher";
        }
    }

    unless ( @! ) {
        $$data{'owner_id'} = $tokens->{ $self->req->headers->header('token') }->{'id'};

        $result = $self->model('Stream')->_add_master( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'stream_id'} = $$data{'stream_id'} unless @!;
    $resp->{'master_id'} = $$data{'master_id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub index {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получаем список пользователей группы
        $result = $self->model('Stream')->_get_list( $data );
    }

    unless ( @! ) {
        foreach ( @$result ) {
            $_->{'member_count'} = $self->model('Stream')->_member_count( $_->{'id'} );
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;