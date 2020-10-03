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

    unless ( @! ) {
        $list = [
            # УЧИТЕЛЬ
            {
                "id"        => 10,
                "surname"   => "Шестаков",
                "name"      => "Сергей",
                "patronymic"=> "Петрович",
                "place"     => "Москва",
                "timezone"  => 3,
                "status"    => 1,
                "avatar"    => 1556,
                "email"     => 'teacher@teacher.ru',
                "phone"     => 79338765643,
                "groups"    => [3], 
                "role"      => "teacher"
            },
            # УЧЕНИКИ
            {
                "id"        => 35,
                "surname"   => "Шестаков",
                "name"      => "Сергей",
                "patronymic"=> "Петрович",
                "place"     => "Москва",
                "timezone"  => 3,
                "status"    => 1,
                "avatar"    => 1556,
                "email"     => 'student@student.ru',
                "phone"     => 79338765643,
                "groups"    => [4], 
                "role"      => "student"
            },
            {
                "id"        => 36,
                "surname"   => "Шестаков",
                "name"      => "Сергей",
                "patronymic"=> "Петрович",
                "place"     => "Москва",
                "timezone"  => 3,
                "status"    => 1,
                "avatar"    => 1556,
                "email"     => 'student@student.ru',
                "phone"     => 79338765643,
                "groups"    => [4], 
                "role"      => "student"
            }
        ];
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
    $resp->{'list'} = $list unless @!;
    $resp->{'meta'} = $meta unless @!;
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;