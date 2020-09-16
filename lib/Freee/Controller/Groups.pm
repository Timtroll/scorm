package Freee::Controller::Groups;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Freee::Model::Utils;
use Encode;

use common;
    
use Data::Dumper;

# вывод списка групп в виде объекта как в Mock
# {
#     "list":[
#         {
#             "children":[],
#             "component":"Groups",
#             "folder":0,
#             "id":"1",
#             "keywords":"Администратор",
#             "label":"Администратор",
#             "opened":0
#         },
# ...
#         {
#             "children":[],
#             "component":"Groups",
#             "folder":0,
#             "id":"2",
#             "keywords":"Менеджер",
#             "label":"Менеджер",
#             "opened":0
#         }
#     ],
#     "publish":"ok"
# }
sub index {
    my $self = shift;

    my ( $list, $set, $row, $resp, $keywords );

    # читаем группы из базы
    $list = $self->model('Groups')->_all_groups();

    $set = [];
    unless ( @! ) {

        # формируем данные для вывода
        foreach (sort {$a <=> $b} keys %$list) {
            # получение ключевых слов из label
            $keywords = join( ' ', keys %{$self->{app}->_make_keywords( $$list{$_}{'label'} ) } );

            $row = {
                'id'        => $_,
                'label'     => $$list{$_}{'label'},
                'component' => "Groups",
                'opened'    => 0,
                'folder'    => 0,
                'keywords'  => $keywords,
                'children'  => []
            };
            push @{$set}, $row;
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $set unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# добавление группы
# my $id = $self->insert_group();
# "label"  - 'название',      - название для отображения
# "name",  - 'name',          - системное название, латиница
# "publish" - 0 или 1,         - активна ли группа
sub add {
    my $self = shift;

    my ( $id, $data, $resp );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # проверяем, используется ли емэйл другим пользователем
        if ( $self->model('Utils')->_exists_in_table('groups', 'name', $$data{'name'} ) ) {
            push @!, "name '$$data{ name }' already exists"; 
        }

        # проверяем, используется ли телефон другим пользователем
        if ( $self->model('Utils')->_exists_in_table('groups', 'label', $$data{'label'} ) ) {
            push @!, "label '$$data{ label }' already exists"; 
        }
    }

    unless ( @! ) {
        $id = $self->model('Groups')->_insert_group( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получение данных группы
# my $row = $self->edit()
# 'id' - id группы
sub edit {
    my $self = shift;

    my ( $result, $data, $resp );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        $result = $self->model('Groups')->_get_group( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# обновление группы
# my $id = $self->save();
# "id"        => 1            - id обновляемого элемента ( >0 )
# "label"     => 'название'   - обязательно (название для отображения)
# "name",     => 'name'       - обязательно (системное название, латиница)
# "publish"    => 0 или 1      - активна ли группа
sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $resp );

    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    # проверка существования обновляемой строки
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('groups', 'id', $$data{'id'}) ) {
            push @!, "Group with id '$$data{'id'}' does not exist";
        }
        if ( $self->model('Utils')->_exists_in_table('groups', 'name', $$data{'name'}, $$data{'id'} ) ) {
            push @!, "Group with name '$$data{'name'}' already exists";
        }
        if ( $self->model('Utils')->_exists_in_table('groups', 'label', $$data{'label'}, $$data{'id'} ) ) {
            push @!, "Group with label '$$data{'label'}' already exists";
        }
    }

    unless ( @! ) {
        # обновление данных группы
        $id = $self->model('Groups')->_update_group( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалениe группы 
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    my ( $id, $resp, $data );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @! ) {
        # проверка данных
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        $id = $self->model('Groups')->_delete_group( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
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

    # Группа существует?
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table( 'groups', 'id', $$data{'id'} ) ) {
            push @!, "Id '$$data{'id'}' doesn't exist";
        }
    }

    unless ( @! ) {
        $$data{'table'} = 'groups';
        $toggle = $self->model('Utils')->_toggle( $data );
        push @!, "Could not toggle Group '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'publish'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;
