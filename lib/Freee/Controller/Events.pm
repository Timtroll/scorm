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
sub event_users {
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

1;