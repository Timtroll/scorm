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

    my ($data, $resp, $token, $user );
warn '===';
    # проверка данных
    $data = $self->_check_fields();

    if ($$data{'login'} && $$data{'password'}) {
        $token = $self->check_login( $$data{'login'}, $$data{'password'} );

        # берем данные пользователя, если токен получен
        if ( $token && $token->{'id'} && $token->{'token'} ) {
            ( $user ) = $self->model('User')->_get_user( { id => $token->{'id'} } );
        }
    }
    else {
        push @!, 'Login or password or both are missing';
    }

    # пока не поправили фронт
$resp->{'token'} = $token->{'token'} unless @!;

    $resp->{'data'}->{'profile'} = $user if $user;
    $resp->{'data'}->{'token'} = $token->{'token'} unless @!;
    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

use DDP;
p $resp;
    @! = ();
    $self->render( json => $resp );
}

# route /logout
# POST or GET поля не передаются (удаляется кука sessions)
sub logout {
    my ($self);
    $self = shift;

    if ($self->session('token')) {
        $self->session(expires => -1);
    }

    $self->render( json => { 'status' => 'ok' } );
}

# check_token /check_token
# служебный роут для проверки наличия куки сессии
sub check_token {
    my ($self, %data);
    $self = shift;

warn "route = ", $self->url_for, "\n";

    # если ли такой роут
    unless (exists $$vfields{$self->url_for}) {
warn "logout";
         $self->logout();
    }

    # проверка токена
    if ( $self->session('token') ) {
        if ( exists( $$tokens{ $self->session('token') } ) ) {
            if ( $$tokens{ $self->session('token') } ) {

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
                return 1;
            }
        }
    }

    $self->logout();
}

################## Subs ##################

# проверяем наличие пользователя по базе users
#  $self->check_login(\%in);
# %in = (
#    'login' => 'login',
#    'pass'  => 'passord',
# );
# возвращает token если пользователь есть и он единственный
# возвращает undef если пользователя нет или их много
sub check_login {
    my ($self, $login, $pass) = @_;

    my ($user, $token, $salt);

    if ( $login && $pass ) {
         # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

       # шифрование пароля
        $pass = sha256_hex( $pass, $salt );

        # проверяем наличие пользователя
        $user = $self->model('Auth')->_exists_in_users( $login, $pass );

        # делаем token для пользователя
        if ( $user ) {
            $token = $self->_create_token( $user );
        }
    }
    else {
        push @!, "Empty login or password for checking";
    }

    return $token;
}

# возвращает token 
sub _create_token {
    my ($self, $user) = @_;

    my ($salt, $token, $expires, %data);

    # create token
    $token = $$user{'login'}.$$user{'password'};
    $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];
    $token = sha256_hex( $token, $salt );

    $expires = time() + $$config{'expires'};

    # %data = (
    #     'status'    => 'ok',
    #     'token'     => $token,
    #     'expires'   => $expires
    # );

# ?????????????? добавить проверку permission, role_id

    # сохраняем токен в глобальном хранилище
    $$tokens{$token} = {
        'expires'   => $expires,
        'login'     => $$user{'login'},
        'token'     => $token,
#???????? добавить пермишенов
        # 'groups'   => $$user{'groups'},
        'permission'=> 0,
        'id'        => $$user{'id'}
    };

    # store token in cookie
    $self->session( { token => $token } );

    return $$tokens{$token};
}

1;
