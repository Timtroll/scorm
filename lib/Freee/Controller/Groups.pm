package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Freee::Model::Utils;
use Encode;

use common;
    
use Data::Dumper;

# вывод списка групп в виде объекта как в Mock
#    "label"       => "scorm",
#    "id"          => 1,
#    "component"   => "Groups",
#    "opened"      => 0,
#    "folder"      => 1,
#    "keywords"    => "",
#    "children"    => [],
#    "table"       => {}
sub index {
    my $self = shift;

    my ($list, $set, $resp, @mess);

    # читаем группы из базы
    unless ( $list = $self->_all_groups() ) {
        push @mess, "Can not get list of group";
    }

    $set = [];
    unless (@mess) {
        # формируем данные для вывода
        foreach (sort {$a <=> $b} keys %$list) {
            my $row = {
                'id'        => $_,
                'label'     => $$list{$_}{'label'},
                'component' => "Groups",
                'opened'    => 0,
                'folder'    => 1,
                'keywords'  => "",
                'children'  => [],
                'table'     => {}
            };
            push @{$set}, $row;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $set unless @mess;

    $self->render( 'json' => $resp );
}

# добавление группы
# my $id = $self->insert_group();
# "label"  - 'название',      - название для отображения
# "name",  - 'name',          - системное название, латиница
# "status" - 0 или 1,         - активна ли группа
sub add {
    my $self = shift;

    my ( $id, $data, $error, @mess, $resp );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('groups', 'name', $$data{'name'} ) ) {
            push @mess, "name '$$data{ name }' already exists"; 
        }

        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('groups', 'label', $$data{'label'} ) ) {
            push @mess, "label '$$data{ label }' already exists"; 
        }
    }

    unless ( @mess ) {
        ( $id, $error ) = $self->model('Groups')->_insert_group( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @mess;

    $self->render( 'json' => $resp );
}

# получение данных группы
# my $row = $self->edit()
# 'id' - id группы
sub edit {
    my $self = shift;

    my ( $result, $data, $error, @mess, $resp );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless (@mess) {
        ( $result, $error ) = $self->model('Groups')->_get_group( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @mess;

    $self->render( 'json' => $resp );
}

# обновление группы
# my $id = $self->save();
# "id"        => 1            - id обновляемого элемента ( >0 )
# "label"     => 'название'   - обязательно (название для отображения)
# "name",     => 'name'       - обязательно (системное название, латиница)
# "status"    => 0 или 1      - активна ли группа
sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $error, $resp, @mess );

    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # проверка существования обновляемой строки
    unless ( @mess ) {
        unless ( $self->model('Utils')->_exists_in_table('groups', 'id', $$data{'id'}) ) {
            push @mess, "Group with id '$$data{'id'}' does not exist";
        }
        if ( $self->model('Utils')->_exists_in_table('groups', 'name', $$data{'name'}, $$data{'id'} ) ) {
            push @mess, "Group with name '$$data{'name'}' already exists";
        }
        if ( $self->model('Utils')->_exists_in_table('groups', 'label', $$data{'label'}, $$data{'id'} ) ) {
            push @mess, "Group with label '$$data{'label'}' already exists";
        }
    }

    unless ( @mess ) {
        # обновление данных группы
        ( $id, $error ) = $self->model('Groups')->_update_group( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @mess;

    $self->render( 'json' => $resp );
}

# удалениe группы 
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    my ( $id, $resp, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        ( $id, $error ) = $self->model('Groups')->_delete_group( $data );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @mess;

    $self->render( 'json' => $resp );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ( $toggle, $resp, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # проверка существования элемента для изменения
    unless (@mess) {
        unless ( $self->model('Utils')->_exists_in_table( 'groups', 'id', $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' doesn't exist";
        }
    }

    unless (@mess) {
        $$data{'table'} = 'groups';
        $toggle = $self->model('Utils')->_toggle( $data );
        push @mess, "Could not toggle Group '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @mess;

    $self->render( 'json' => $resp );
}

1;
