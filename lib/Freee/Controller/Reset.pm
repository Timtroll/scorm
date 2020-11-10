package Freee::Controller::Reset;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Digest::SHA qw( sha256_hex );
use common;

sub index {
    my $self = shift;

    my ( $data, $code, $expires, $paramess, $result, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # проверяем, используется ли email
        unless ( $$data{'email'} && $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
            push @!, "email '$$data{ email }' doesn't exist"; 
        }
    }
    unless ( @! ) {
        # генерация случайного кода
        $code = $self->_random_string( 30 ) . '@' . $$data{'email'};

        # время истечения кода
        $expires = time() + $$config{'expires'};

        # сохранение кода и времени жизни
        $$codes{$code} = $expires;

        # генерация темплейта
        $$paramess{'email_body'} = $self->render_to_string(
            'template'   => 'mail/reset_password_notification',
            'email_text' => $self->{'app'}->{'defaults'}->{'config'}->{'url'} . '/reset/confirmation?code=' . $code
        );
        push @!, "can't render template" unless $$paramess{'email_body'};
    }

    unless ( @! ) {

        if ( $self->{'app'}->{'defaults'}->{'config'}->{'test'} ) {
            $result = $code;
        }
        else {
            # отправка письма
            $$paramess{'to'}       = $$data{'email'};
            $$paramess{'subject'}  = '[Scorm] Please reset your password';

            # отправка письма
            $result = $self->model('Mail')->_send_mail( $paramess );
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'result'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub confirmation {
    my $self = shift;

    my ( $data, $code, $result, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        if ( exists $$codes{$$data{'code'}} ) {

            # проврека времени жизни
            foreach ( keys %$codes ) { # для всех
                if  ( $$codes{$_} < time() ) {
                    delete $$codes{$_};
                }
            }

            # проверка наличия такого кода
            if ( exists $$codes{$$data{'code'}} ) {

                $result = $$data{'code'};
# переделать на json
                # отправка поля с заменой пароля
                # $self->render(
                #     'template'   => 'mail/reset_password',
                #     'email_text' => $$data{'code'}
                # );

                # удаление кода
                delete $$codes{$$data{'code'}};
            }
            else {
                push @!, "code's lifespawn expired";
            }
        }
        else {
            push @!, "code doesn't exist";
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'result'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub reset {
    my $self = shift;

    my ( $data, $email, $salt, $result, $resp );

    # проверка данных
    $data = $self->_check_fields();

    # если пароль и подтверждение различны
    unless ( @! || $$data{'password'} eq $$data{'con_password'} ) {

        push @!, "password and con_password aren't the same";

        # # отправка поля с заменой пароля
        # $self->render(
        #     'template'   => 'mail/reset_password',
        #     'email_text' => $self->param( 'code' )
        # );

        # return;
    }

    unless ( @! ) {
        $$data{'code'} =~ /^(\w+)@(.*)$/;
        $$data{'email'} = $2;

        # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

        # шифрование пароля
        $$data{'newpassword'} = sha256_hex( $$data{'password'}, $salt );

        $result = $self->model('Reset')->_reset( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'result'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;