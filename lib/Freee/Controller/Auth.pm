package Freee::Controller::Auth;


use open qw(:utf8);
binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

use Mojo::Base 'Mojolicious::Controller';
use Digest::SHA qw( sha256_hex );

use Data::Dumper;

use common;

# route /login
# POST:
#   login    - 'chars' string
#   password - 'symbchars' string
#
# Return:
# {
#     'status' : 'ok',
#     'token'  : '72ade14d2d30c88f082f0410499fed05'
# }
# or
# {
#     "mess": "Login or password is wrong",
#     "status": "fail"
# }
sub login {
    my $self = shift;
warn '=login=';

    my ($data, $resp, $token, $salt, $user, $expires );

    # проверка данных   
    $data = $self->_check_fields();

    if ($$data{'login'} && $$data{'password'}) {
        # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

        # шифрование пароля
        $$data{'password'} = sha256_hex( $$data{'password'}, $salt );

        # проверяем наличие пользователя
        $user = $self->model('User')->_exists_in_users( $$data{'login'}, $$data{'password'} );

        if ( $user ) {
            # делаем token для пользователя
            $token = $$user{'login'} . time() . $$user{'password'};
            $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];
            $token = sha256_hex( $token, $salt );

            # устанавливаем время жизни
            $expires = time() + $$config{'expires'};

            # удаляем пароль из сессии
            delete $$user{'password'};

            # сохраняем токен в глобальном хранилище
            $$tokens{$token} = $user;
            $$tokens{$token}{'expires'} = $expires;
        }
    }
    else {
        push @!, 'Login or password or both are missing';
    }

    $resp->{'data'}->{'profile'} = $user if $user;
    $resp->{'data'}->{'token'} = $token unless @!;
    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();
    $self->render( json => $resp );
}

# route /logout
# POST or GET поля не передаются (удаляется кука sessions)
sub logout {
    my ($self);
    $self = shift;

warn '=logout=';
    # удаляем сессию, если она есть
    if ( $self->req->headers->header('token') ) {
        delete $$tokens{ $self->req->headers->header('token') };
    }

    $self->render( json => { 'status' => 'ok' } );
}

# check_token /check_token
# служебный роут для проверки наличия куки сессии
# Возвращает 1 - если все ок,
# редиректит на 666 ошибку, если все плохо
sub check_token {
    my ($self, %data);
    $self = shift;

warn '=check_token=';

warn "route = ", $self->url_for, "\n";
warn $self->req->headers->header('token');
use DDP;
p $tokens;

    # если ли такой роут
    unless (exists $$vfields{$self->url_for}) {
        # return;
        $self->redirect_to('/error/');
    }

    # проверка токена
    if (
        $self->req->headers->header('token') && 
        exists( $$tokens{ $self->req->headers->header('token') } ) && 
        $$tokens{ $self->req->headers->header('token') } 
    ) {
        # delete old tokens
        map {
            if (exists($$tokens{$_})) {
                unless ($$tokens{$_}{'expires'}) {
                    delete $$tokens{$_};
                }
                elsif ($$tokens{$_}{'expires'} <= time()) {
                    delete $$tokens{$_};
                }
            }
        } (keys %{$tokens});

# проверка пермишенов
# ????????? доработать?
warn "check permissions\n";
        # if ($$tokens{$self->session('token')}{'role_id'}) {
        #     my $route = $self->url_for;

        #     if ($$permissions{$$tokens{$self->session('token')}{'role_id'}}{$route}) {
        #         return 1;
        #     }
        # }
warn "checked";
        return 1;
    }

    # return;
    $self->redirect_to('/error/');
}

1;
