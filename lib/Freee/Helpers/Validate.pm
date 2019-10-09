package Freee::Helpers::Validate;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;
# use experimental 'smartmatch';

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Validation

    # Проверка даты
    # my $list = $self->_vdate('YYYY-MM-DD');
    # возвращает 1/undef
    $app->helper( '_vdate' => sub {
        my ($self, $date) = @_;

        return unless defined $date;

        my ($year, $month, $day);
        my $re = qr{^\d{4}-\d{1,2}-\d{1,2}$};
        if ( $date =~ /$re/ ) {
            ($year, $month, $day) = split/-/, $date;
        } else {
            return;
        }

        $month--;
        eval { timelocal(0, 0, 0, $day, $month, $year) };

        return $@ ? undef : 1;
    });

    # Валидация указанного блока полей при чтении html запроса
    # my $list = $self->_check('settings');
    # возвращает 1/undef
    $app->helper( '_check' => sub {
        return 0 unless $_[1];

        my @error = ();
        if ( defined $config->{'vfields'}->{$_[1]} ) {
            my $valid = $config->{'vfields'}->{$_[1]};

            foreach my $fld (keys %$valid) {
                # читаем поле
                if (my $val = $_[0]->param($fld)) {
                    # проверяем длинну поля, если указано проверять
                    if ($$valid{$fld}[2]) {
                        if ( length($val) < $$valid{$fld}[2]) {
                            push @error, "Validation error for '$fld' field (wrong length)";
                            next;
                        }
                    }

                    my $re = $$valid{$fld}[1];
                    # валидация по регэкспу
                    unless ( $val =~ /$re/oi ) {
                        push @error, "Validation error for '$fld' field (wrong type)";
                    }
                }
                else {
                    if ($$valid{$fld}[0] && ($$valid{$fld}[0] eq 'required')) {
                        push @error, "Validation error for '$fld' field (empty)";
                    }
                }
            }
        }

        return @error ? 0 : 1, \@error;
        # return {
        #     status => @error ? 'fail' : 'ok',
        #     mess => \@error
        # };
    });

    # формирование типов перед сохранением в БД
    # my $list = $self->_check_fields($$vfields{'/settings/save'}});
    # возвращает ссылку на хэш из $self->param(*)
    $app->helper( '_check_fields' => sub {
        my $self = shift;

        return unless $self->url_for;

        my %data = ();
        foreach (keys %{$$vfields{$self->url_for}}) {
            $data{$_} = $self->param($_) if defined $self->param($_);
        }

        return \%data
    });

    # загрузка правил валидации html полоей
    # my $list = $self->_param_fields('get_tree');
    # возвращает 1/undef
    $app->helper( '_param_fields' => sub {

        $vfields = {
            # волидация роутов
            '/settings/add_folder'  => {
                "parent"        => [ '', qr{^\d+$} ],
                "name"          => [ 'required', qr{[A-Za-z]+}, 256 ],
                "label"         => [ 'required', qr{.*}, 256 ],
            },
            '/settings/save_folder'  => {
                "id"            => [ 'required', qr{^\d+$} ],
                "parent"        => [ '', qr{^\d+$} ],
                "name"          => [ 'required', qr{[A-Za-z]+}, 256 ],
                "label"         => [ '', qr{.*}, 256 ],
            },

            '/settings/save'  => {
                "id"            => [ 'required', qr{^\d+$} ],
                "parent"        => [ '', qr{^\d+$} ],
                "name"          => [ 'required', qr{^[A-Za-z]+$}, 256 ],
                "label"         => [ '', qr{.*}, 256 ],
                "placeholder"   => [ '', qr{.*}, 256 ],
                "type"          => [ '', qr{\w+}, 256 ],
                "mask"          => [ '', qr{.*}, 256 ],
                "value"         => [ '', qr{.*}, 10000 ],
                "selected"      => [ '', qr{.*}, 10000 ],
                "required"      => [ '', qr{^\d+$} ],
                "readonly"      => [ '', qr{^\d+$} ],
                "status"        => [ 'required', qr{^[01]$} ]
            },
            '/settings/add'  => {
                "parent"        => [ '', qr{^\d+$} ],
                "name"          => [ 'required', qr{[A-Za-z]+}, 256 ],
                "label"         => [ 'required', qr{.*}, 256 ],
                "placeholder"   => [ '', qr{.*}, 256 ],
                "type"          => [ '', qr{\w+}, 256 ],
                "mask"          => [ '', qr{.*}, 256 ],
                "value"         => [ '', qr{.*}, 10000 ],
                "selected"      => [ '', qr{.*}, 10000 ],
                "required"      => [ '', qr{^\d+$} ],
                "readonly"      => [ '', qr{^\d+$} ],
                "status"        => [ 'required', qr{^[01]$} ]
            },

            'groups'  => {
                "id"            => [ '', qr{^\d+$} ],
                "parent"        => [ '', qr{^\d+$} ],
                "name"          => [ 'required', qr{[A-Za-z]+}, 256 ],
                "label"         => [ '', qr{.*}, 256 ],
                "value"         => [ '', qr{.*}, 10000 ],
                "required"      => [ '', qr{^\d+$} ],
                "readonly"      => [ '', qr{^\d+$} ],
                "status"        => [ '', qr{^[01]$} ]
            },
            'routes'  => {
                "id"            => [ '', qr{^\d+$} ],
                "parent"        => [ '', qr{^\d+$} ],
                "name"          => [ 'required', qr{[A-Za-z]+}, 256 ],
                "label"         => [ '', qr{.*}, 256 ],
                "value"         => [ '', qr{.*}, 10000 ],
                "required"      => [ '', qr{^\d+$} ],
                "readonly"      => [ '', qr{^\d+$} ]
            },
            'forum_themes'  => {
                "id"            => [ '', qr{^\d+$} ],
                "user_id"       => [ '', qr{^\d+$} ],
                "title"         => [ '', qr{.*}, 10000 ],
                "url"           => [ '', qr{http.*?//.*}, 256 ],
                "rate"          => [ '', qr{^\d+$} ],
                "date_created"  => [ '', qr{^\d+$} ]
            },
            'forum_rates'  => {
                "user_id"       => [ '', qr{^\d+$} ],
                "msg_id"        => [ '', qr{^\d+$} ],
                "like_value"    => [ '', qr{^\d+$} ]
            },
            'forum_rates'  => {
                "id"            => [ '', qr{^\d+$} ],
                "theme_id"      => [ '', qr{^\d+$} ],
                "user_id"       => [ '', qr{^\d+$} ],
                "anounce"       => [ '', qr{^[01]$} ],
                "date_created"  => [ '', qr{^\d+$} ],
                "msg"           => [ '', qr{.*}, 10000 ],
                "rate"          => [ '', qr{^\d+$} ]
            }
            # поля запросов
            # ''  => {

            # }
        };

        return $vfields;
    });
}

1;