package Freee::Controller::Events;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

# Расписание уроков
# $self->index();
sub index {
    my $self = shift;

    my ( $data, $list, $resp, $events );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};
        $$data{'limit'} = $settings->{'per_page'} unless $$data{'limit'};
        $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};
        $$data{'order'} = 'ASC' unless $$data{'order'};

        # получаем список событий
        $events = $self->model('Events')->_get_list( $data );
        push @!, "Can not get event list" unless $events;

        unless ( @! ) {
            $list = {
                'settings' => {
                    'editable' => 1,
                    'massEdit' => 0,
                    'page' => {
                        'current_page' => $$data{'page'},
                        'per_page'     => $$data{'limit'}
                    },
                    'removable' => 1,
                    'sort' => {
                        'name' => 'id',
                        'order' => $$data{'order'}
                    }
                }
            };

            $list->{'body'} = $events;
            $list->{'settings'}->{'page'}->{'total'} = scalar(@$events);
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Урок - список участников + учитель
# $self->event_users( $data );
# $data = {
#   'id' => <id>    - id урока
#}
sub lesson_users {
    my $self = shift;

    my ( $data, $resp, $list, $meta, $teacher, $students, $group_id );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $meta = $self->model('Events')->_get_event( $data );
        push @!, "Can not get teacher" unless $$meta{'initial_id'};
    }

    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};
        $$data{'limit'} = $settings->{'per_page'} unless $$data{'limit'};
        $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};
        $$data{'order'} = 'ASC' unless $$data{'order'};

        $students = $self->model('Events')->_get_students_by_event( $data );
    }

    unless ( @! ) {
        $teacher = $self->model('Events')->_get_teacher_by_event( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'students'} = $students unless @!;
    $resp->{'teacher'} = $teacher unless @!;
    $resp->{'meta'} = $meta unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# добавление события
# my $id = $self->insert_event({
#     "comment",     => 'comment',         - комментарий
#     'time_start'   => '01-09-2020',      - дата начала события
#     'initial_id'   => 11,                - id руководителя
#     "status"       => 0 или 1,           - активен ли поток, обязательное поле
# });
# возвращается id записи  
sub add {
    my $self = shift;

    my ( $id, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, существует ли преподаватель
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'initial_id'} ) ) {
            push @!, "user with id '$$data{'initial_id'}' doesn/'t exist"; 
        }
        # проверяем, является ли пользователь учителем
        unless ( $self->model('Utils')->_is_teacher( $$data{'initial_id'} ) ) {
            push @!, "User '$$data{'initial_id'}' is not a teacher";
        }
    }

    unless ( @! ) {
        $$data{'owner_id'} = $tokens->{ $self->req->headers->header('token') }->{'id'} if $$data{'student_ids'};

        $id = $self->model('Events')->_insert_event( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# сохранить эвент
# $self->save( $data );
sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $resp, $owner_id );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования обновляемой строки
    unless ( @! ) {
        # проверяем, существует ли преподаватель
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'initial_id'} ) ) {
            push @!, "user with id '$$data{'initial_id'}' doesn/'t exist"; 
        }
        # проверяем, является ли пользователь учителем
        unless ( $self->model('Utils')->_is_teacher( $$data{'initial_id'} ) ) {
            push @!, "User '$$data{'initial_id'}' is not a teacher";
        }
    }

    unless ( @! ) {
        # смена поля status на publish
        $$data{'publish'} = $$data{'status'};
        delete $$data{'status'};

        $$data{'owner_id'} = $tokens->{ $self->req->headers->header('token') }->{'id'};

        # обновление данных группы
        $id = $self->model('Events')->_update_event( $data, $owner_id );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# удалениe события
# "id" => 1 - id удаляемого элемента ( >0 )
sub delete {
    my $self = shift;

    my ( $id, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $id = $self->model('Events')->_delete_event( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

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

    # Событие существует?
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table( 'events', 'id', $$data{'id'} ) ) {
            push @!, "Id '$$data{'id'}' doesn't exist";
        }
    }

    unless ( @! ) {
        $$data{'fieldname'} = 'publish';
        $$data{'table'} = 'events';
        $toggle = $self->model('Utils')->_toggle( $data );
        push @!, "Could not toggle Event '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получить данные для редактирования эвента
# $self->edit( $data );
# $data = {
#   id => <id> - id предмета
# }
sub edit {
    my $self = shift;

    my ( $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $result = $self->model('Events')->_get_event( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получение всех эвентов с таким учителем
# my $list = $self->_list_teacher_lessons();
#   'id'    => <id> - id учителя
sub teacher_lessons {
    my $self = shift;

    my ( $data, $resp, $events );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        unless ( $self->model('Utils')->_is_teacher( $$data{'id'} ) ) {
            push @!, "user with id '$$data{'id'}' is not a teacher"; 
        }
    }

    unless ( @! ) {
        $events = $self->model('Events')->_list_teacher_lessons( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'events'} = $events unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получение всех эвентов с таким учеником
# my $list = $self->_list_student_teacher();
#   'id'    => <id> - id ученика
sub student_lessons {
    my $self = shift;

    my ( $data, $resp, $events );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $events = $self->model('Events')->_list_student_teacher( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'events'} = $events unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;