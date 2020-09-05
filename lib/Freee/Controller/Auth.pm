package Freee::Controller::Auth;


use open qw(:utf8);
binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

use Mojo::Base 'Mojolicious::Controller';
use Digest::SHA qw( sha256 );

use Data::Dumper;

use common;

# route /login
# POST:
#   login   - 'chars' string
#   pass    - 'symbchars' string
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

    my ($data, $resp, $token );

    # проверка данных
    $data = $self->_check_fields();

    if ($$data{'login'} && $$data{'pass'}) {
        $token = $self->check_login( $$data{'login'}, $$data{'pass'} );
    }
    else {
        push @!, 'Login or password or both are missing';
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = { 'token' => $token->{'token'} } unless @!;

    @! = ();

    $self->render( json => $resp );
}

# route /logout
# POST or GET поля не передаются (удаляется кука sessions)
sub logout {
    my ($self, %data);
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

print "route = ", $self->url_for, "\n";
    # проверка токена
    # ???????????????

    # валидируем входные параметры, если есть соответствующие правила
    if (defined $$vfields{$self->url_for}) {
        # my ($res, $err) = $self->_check( $$routs{$self->url_for} );
#??????????????????????????????????????????????????????????????????
#         my ( $res, $error ) = $self->_check_fields( $self->url_for );
# # print "check_token $res, error:\n";
# # print Dumper($err);
#         unless ($res) {
#             # выводим ошибки, если валидация html данных не прошла
#             $self->render( json => { 'status' => 'fail', message => join("\n", @$error) } );
#             return;
#         }
    }

    # проверка пермишенов
    # ????????

# для отладки
return 1;

# ????????? удаляем?
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

    if ( $self->session('token') ) {
        if ( exists( $$tokens{$self->session('token')} ) ) {
            if ( $$tokens{$self->session('token')} ) {
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

    return 0;
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
        $pass = sha256( $pass, $salt );

        # проверяем наличие пользователя
        $user = $self->model('Auth')->_exists_in_users( $login, $pass );

        # делаем token для пользователя
        if ($user) {
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
    $token = sha256( $token, $salt );

    $expires = time() + $$config{'expires'};

    # %data = (
    #     'status'    => 'ok',
    #     'token'     => $token,
    #     'expires'   => $expires
    # );

# ?????????????? добавить проверку permission, role_id

    # сохраняем токен в глобальном хранилище
    $tokens->{$token} = {
        'expires'   => $expires,
        'login'     => $$user{'login'},
#???????? добавить пермишенов
        # 'groups'   => $$user{'groups'},
        'permission'=> 0,
        'id'        => $$user{'id'}
    };

    # store token in cookie
    $self->session(token => $token);

    return $token;
}

1;
