package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Encode;

# use Freee::Mock::Groups;
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
print "========\n";
    # читаем группы из базы
    unless ( $list = $self->_all_groups() ) {
        push @mess, "Can not get list of group";
    }

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
    $resp->{'list'} = $set if $set;

    $self->render( 'json' => $resp );
}

# добавление группы
# my $id = $self->insert_group();
# "label"  - 'название',      - название для отображения
# "name",  - 'name',          - системное название, латиница
# "status" - 0 или 1,         - активна ли группа
sub add {
    my $self = shift;

    my ($id, $data, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct setting item data '$$data{'name'}'" unless $data;

        if ($data) {
            $id = $self->_insert_group( $data );
            push @mess, "Could insert data" unless $id;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# получение данных группы
# my $row = $self->edit()
# 'id' - id группы
sub edit {
    my $self = shift;

    my ($id, $data, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Group data '$$data{'id'}'" unless $data;

        if ($data) {
            $data = $self->_get_group( $$data{'id'} );
            push @mess, "Could not get Group '".$$data{'id'}."'" unless $data;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

# обновление группы
# my $id = $self->save();
# "id"        => 1            - id обновляемого элемента ( >0 )
# "label"     => 'название'   - обязательно (название для отображения)
# "name",     => 'name'       - обязательно (системное название, латиница)
# "status"    => 0 или 1      - активна ли группа
sub save {
    my ($self) = shift;

    my ( $id, $parent, $data, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Group data '$$data{'name'}'" unless $data;

        # проверка существования обновляемой строки
        unless (@mess) {
            if ( $self->_exists_in_table('groups', 'id', $$data{'id'}) ) {
                # обновление данных группы
                $id = $self->_update_group( $data );
                push @mess, "Could not update Group named '$$data{'name'}'" unless $id;
            }
            else {
                push @mess, "Group named '$$data{'name'}' is not exists";
            }
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# удалениe группы 
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    my ($del, $resp, $data, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Group '$$data{'id'}'" unless $data;

        $del = $self->_delete_group( $$data{'id'} ) unless @mess;
        push @mess, "Could not delete Group '$$data{'id'}'" unless $del;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $del;

    $self->render( 'json' => $resp );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ($toggle, $resp, $data, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        $data = $self->_check_fields();
        push @mess, "Not correct Group '$$data{'id'}'" unless $data;

        $toggle = $self->_toggle_group( $data ) unless @mess;
        push @mess, "Could not toggle Group '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}


1;
