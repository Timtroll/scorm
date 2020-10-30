package Freee::Controller::Mail;

use utf8;
use Encode;

use Data::Dumper;
use common;

sub send {
    my $self = shift;

    my ( $data, $code, $expires, $param, $result, $resp );

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
        $$params{'email_body'} = $self->render_to_string(
            'template'   => 'mail/reset_password_notification',
            'email_text' => 'https://freee/reset_password/confirmation?code=' . $code
        );
        push @!, "can't render template" unless $$params{'email_body'};
    }

    unless ( @! ) {
        # отправка письма
        $$params{'to'}       = $$data{'email'};
        $$params{'subject'}  = '[Scorm] Please reset your password';

        # отправка письма
        $result = $self->model('Mail')->_send_mail( $params );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'result'} = $result unless @!;
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

                # отправка поля с заменой пароля
                $self->render(
                    'template'   => 'mail/reset_password',
                    'email_text' => $$data{'code'}
                );

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
}

sub reset {
    my $self = shift;

    my ( $data, $email, $salt, $result, $resp );

    # проверка данных
    $data = $self->_check_fields();

    # если пароль и подтверждение различны
    unless ( $$data{'password'} eq $$data{'con_password'} ) {
        # отправка поля с заменой пароля
        $self->render(
            'template'   => 'mail/reset_password',
            'email_text' => $self->param( 'code' )
        );
    }

    unless ( @! ) {
        $$data{'code'} =~ /^(\w+)@(.*)$/;
        $$data{'email'} = $2;

        # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

        # шифрование пароля
        $$data{'newpassword'} = sha256_hex( $$data{'password'}, $salt );

        $data = $self->model('Reset_password')->_reset( $data );
    }
}