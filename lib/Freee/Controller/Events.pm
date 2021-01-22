package Freee::Controller::Events;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

# Расписание уроков
# $self->index();
sub index {
    my $self = shift;

    my ( $data, $resp, $result );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # $result = $self->model('Lesson')->_delete_lesson( $$data{'id'} );
        # push @!, 'can\'t delete EAV object' unless $result;
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

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

    my ( $data, $resp, $list, $meta );

    # проверка данных
    $data = $self->_check_fields();

    # получаем список учителей
    my $group_id = $self->model('Groups')->_get_group_id( 'teacher' );
    my $teacher = $self->model('User')->_get_list({
        group_id => $$group_id{'id'},
        limit    => 1,
        offset   => 0,
        publish  => 1,      #?????????? почему-то при добавлении учителя publush- false
        mode     => 'full'
    });
    $teacher = shift @$teacher;

    # получаем список учеников
    $group_id = $self->model('Groups')->_get_group_id( 'students' );
    my $students = $self->model('User')->_get_list({
        group_id => $$group_id{'id'},
        limit    => 1,
        offset   => 0,
        publish  => 1,
        mode     => 'full'
    });

    unless ( @! ) {
        # $list = [ @$teachers, @$students ];

        $meta = {
            "desciption"    => "описание урока",
            "discipline"    => "История",
            "theme"         => "Азия и Африка в XVIII в.",
            "lesson"        => "Итоговый урок по теме «Азия и Африка в XVIII в.»",
            "lessonNumber"  => 28,
            "grade"         => 8
        };
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'students'} = $students unless @!;
    $resp->{'teacher'} = $teacher unless @!;
    $resp->{'meta'} = $meta unless @!;
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub add {
    my $self = shift;

    my ( $id, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, существует ли руководитель
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'initial_id'} ) ) {
            push @!, "user with id '$$data{'initial_id'}' doesn/'t exist"; 
        }
        # проверяем, является ли пользователь учителем
        unless ( $self->model('Utils')->_is_teacher( $$data{'initial_id'} ) ) {
            push @!, "User '$$data{'initial_id'}' is not a teacher";
        }
    }

    unless ( @! ) {
        $$data{'owner_id'} = $tokens->{ $self->req->headers->header('token') }->{'id'} if $$data{'master_id'};

        $id = $self->model('Events')->_insert_event( $data );
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

1;