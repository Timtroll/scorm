package Freee::Controller::Auth;

use open qw(:utf8);
binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

use Mojo::Base 'Mojolicious::Controller';
use Digest::MD5 qw/md5_hex/;

use Data::Dumper;

use common;
use validate;

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
    my ($self, $json, $token, $user, %data, %in);
    $self = shift;

    $json = { 'status' => 'ok' };

    # clear input data
    $in{'login'} = $self->validate('chars', 'login');
    $in{'pass'} = $self->validate('symbchars', 'pass');
    # $in{'capcha'} = $self->validate('chars', 'capcha');

    if ($in{'login'} && $in{'pass'}) {
        $token = $self->check_login(\%in);

        if ($token->{'status'} eq 'ok') {
            $json->{'token'} = $token->{'token'};
        }
        else {
            $json = {
                'status'  => 'fail',
                'mess'    => $token->{'mess'}
            };
        }
    }
    else {
        $json = {
            'status'  => 'fail',
            'mess'    => 'Login or password or both are missing'
        };
    }

    $self->render( json => $json );
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

print "route = ", $$routs{$self->url_for}, "\n";

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
# check permissions
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

# create temp session if login-pass ot token success
sub _get_token {
    my ($self, $user, $token, $expires, $error, %data, %in);
    $self = shift;
    $user = shift;

    $in{'token'} = $self->validate('chars', 'token');

    # create token
    $error = 0;
    if ($$user{'login'} && $$user{'pass'}) {
        $token = $$user{'login'}.time().$$user{'pass'};
    }
    elsif ($in{'token'}) {
        $token = time().$$config{'hardcore_token'};
    }
    else {
        $error = 1;
    }

    unless ($error) {
        $token = md5_hex($token);
        $expires = time() + $$config{'expires'};

        %data = (
            'status'    => 'ok',
            'token'     => $token,
            'expires'   => $expires
        );

        # store token
        $tokens->{$token} = {
            'expires'   => $expires,
            'login'     => $$user{'login'},
            'role_id'   => $$user{'role_id'},
            'id'        => $$user{'id'}
        };

        # store token in cookie
        $self->session(token => $token);
    }
    else {
        %data = (
            'status'    => 'fail'
        );
    }

    return \%data;
}

sub check_login {
    my ($self, $token, $in);
    $self = shift;
    $in = shift;

    $token = {
        'status'  => 'fail',
        'mess'    => 'Login or password is wrong',
    };

    if ($$in{'login'} && $$in{'pass'}) {
# ?????? need to change
        if ($$in{'login'} eq $$in{'pass'}) {
            $token = $self->_get_token($in);
        }
    }

    return $token;
}


1;
