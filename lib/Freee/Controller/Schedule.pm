package Freee::Controller::Schedule;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

# добавление события
# my $id = $self->_insert_schedule({
#     "duration",    => 10000,             - продолжительность
#     "course_id",   => 12,                - id курса
#     'time_start'   => '01-09-2020',      - дата начала события
#     'teacher_id'   => 11,                - id руководителя
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
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'teacher_id'} ) ) {
            push @!, "user with id '$$data{'teacher_id'}' doesn/'t exist"; 
        }
        # проверяем, является ли пользователь учителем
        unless ( $self->model('Utils')->_is_teacher( $$data{'teacher_id'} ) ) {
            push @!, "User '$$data{'teacher_id'}' is not a teacher";
        }
    }

    unless ( @! ) {
        # проверяем, существует ли курс
        unless ( $self->model('Utils')->_exists_in_table('EAV_items', 'id', $$data{'course_id'} ) ) {
            push @!, "Course with id '$$data{'course_id'}' doesn/'t exist"; 
        }
    }

    unless ( @! ) {
        $$data{'time_start_sec'} = $self->model('Utils')->_date2sec( $$data{'time_start'} );
        
        $id = $self->model('Schedule')->_insert_schedule( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# обновить расписание
# $self->save( $data );
sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $resp, $owner_id );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования обновляемой строки
    unless ( @! ) {
        # проверяем, существует ли преподаватель
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'teacher_id'} ) ) {
            push @!, "user with id '$$data{'teacher_id'}' doesn/'t exist"; 
        }
        # проверяем, является ли пользователь учителем
        unless ( $self->model('Utils')->_is_teacher( $$data{'teacher_id'} ) ) {
            push @!, "User '$$data{'teacher_id'}' is not a teacher";
        }
    }

    unless ( @! ) {
        # проверяем, существует ли курс
        unless ( $self->model('Utils')->_exists_in_table('EAV_items', 'id', $$data{'course_id'} ) ) {
            push @!, "Course with id '$$data{'course_id'}' doesn/'t exist"; 
        }
    }

    unless ( @! ) {
        # смена поля status на publish
        $$data{'publish'} = $$data{'status'};
        delete $$data{'status'};

        $$data{'time_start_sec'} = $self->model('Utils')->_date2sec( $$data{'time_start'} );

        # обновление данных группы
        $id = $self->model('Schedule')->_update_schedule( $data, $owner_id );
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
        $id = $self->model('Schedule')->_delete_schedule( $data );
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
        unless ( $self->model('Utils')->_exists_in_table( 'schedule', 'id', $$data{'id'} ) ) {
            push @!, "Id '$$data{'id'}' doesn't exist";
        }
    }

    unless ( @! ) {
        $$data{'fieldname'} = 'publish';
        $$data{'table'} = 'schedule';
        $toggle = $self->model('Utils')->_toggle( $data );
        push @!, "Could not toggle Schedule '$$data{'id'}'" unless $toggle;
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получить данные для редактирования расписания
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
        $result = $self->model('Schedule')->_get_schedule( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# получить расписание на неделю
sub on_week {
    my $self = shift;

    my ( $list, $resp, $data, $time, $week, $time_start );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'time_start_sec'} = $self->model('Utils')->_date2sec( $$data{'time_start'} );
        $$data{'time'} = 604800;

        $list = $self->model('Schedule')->_get_list_on_time( $data );
        warn Dumper($list);
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub on_month {
    my $self = shift;

    my ( $list, $resp, $data, $time, $week, $time_start );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'time_start_sec'} = $self->model('Utils')->_date2sec( $$data{'time_start'} );
        $$data{'time'} = 2678400;

        $list = $self->model('Schedule')->_get_list_on_time( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

# Расписание
# $self->index();
sub index {
    my $self = shift;

    my ( $data, $list, $resp, $schedule );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};
        $$data{'limit'} = $settings->{'per_page'} unless $$data{'limit'};
        $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};
        $$data{'order'} = 'ASC' unless $$data{'order'};

        # получаем список событий
        $schedule = $self->model('Schedule')->_get_list( $data );
        push @!, "Can not get event list" unless $schedule;

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

            $list->{'body'} = $schedule;
            $list->{'settings'}->{'page'}->{'total'} = scalar(@$schedule);
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;