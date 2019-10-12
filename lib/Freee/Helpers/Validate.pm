package Freee::Helpers::Validate;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;
use HTML::Strip;

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
        }
        else {
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
        # Проверка наличия объекта для валидации
        if ( defined $vfields->{$_[1]} ) {
            my $valid = $vfields->{$_[1]};

            # проверка полей
            my $hs = HTML::Strip->new();

            # проверка для роутов */toggle
            if (defined $_[0]->param('fieldname')) {
                # есть ли в списке валидации значение param('fieldname')
                my $id = $_[0]->param('id');
                my $fieldname = $_[0]->param('fieldname');
                my $val = $_[0]->param('value') // 0;

                if ($fieldname && $id) {
                    $fieldname = $hs->parse($fieldname) if ($fieldname);

                    unless (grep {/$fieldname/} @{$$valid{'fieldname'}[1]}) {
                        push @error, "The 'fieldname' not contain needed name";
                    }
                }
                else {
                    push @error, "The 'fieldname' is empty";
                }
            }
            # проверка полей для остальных роутов
            else {
                foreach my $fld (keys %$valid) {
                    # Проверка обязательности поля
                    if ( defined $_[0]->param($fld) && ($$valid{$fld}[0] eq 'required') ) {
                        # читаем поле
                        my $val = $_[0]->param($fld) // 0;

                        # чистка от html
                        $val = $hs->parse($val) if ($val);

                        # проверяем длинну поля, если указано проверять
                        if ( $$valid{$fld}[2] ) {
                            if ( length($val) > $$valid{$fld}[2] ) {
                                push @error, "Validation error for '$fld'. Field has wrong length";
                                next;
                            }
                        }

                        my $re = $$valid{$fld}[1];
                        # валидация по регэкспу
                        unless ( $val =~ $re ) {
                            push @error, "Validation error for '$fld'. Field has wrong type";
                        }
                    }
                    else {
                        if ( $$valid{$fld}[0] && ($$valid{$fld}[0] eq 'required') ) {
                            push @error, "Validation error for '$fld'. Field is empty or not exists";
                        }
                    }
                }
            }
        }
        else {
            push @error, "Not exists validation data for route '$_[1]'";
        }

        return @error ? 0 : 1, \@error;
    });

    # формирование типов перед сохранением в БД
    # my $list = $self->_check_fields($$vfields{'/settings/save'}});
    # возвращает ссылку на хэш из $self->param(*)
    $app->helper( '_check_fields' => sub {
        my $self = shift;

        return unless $self->url_for;

        my %data = ();
        foreach (keys %{$$vfields{$self->url_for}}) {
            $data{$_} = $self->param($_) // 0;
        }

        return \%data
    });

    # загрузка правил валидации html полоей
    # my $list = $self->_param_fields('get_tree');
    # возвращает 1/undef
    $app->helper( '_param_fields' => sub {

        $vfields = {
            # валидация роутов
            '/settings/add_folder'  => {
                "parent"        => [ '', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
            },
            '/settings/get_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
            },
            '/settings/save_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "parent"        => [ '', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z]+$/os, 256 ],
                "label"         => [ '', qr/.*/os, 256 ],
            },
            '/settings/delete_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
            },
            '/settings/save'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "parent"        => [ 'required', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "placeholder"   => [ '', qr/.*/os, 256 ],
                "type"          => [ '', qr/\w+/os, 256 ],
                "mask"          => [ '', qr/.*/os, 256 ],
                "value"         => [ '', qr/.*/os, 10000 ],
                "selected"      => [ '', qr/.*/os, 10000 ],
                "required"      => [ '', qr/^[01]$/os ],
                "readonly"      => [ '', qr/^[01]$/os ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/settings/add'  => {
                "parent"        => [ 'required', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "placeholder"   => [ '', qr/.*/os, 256 ],
                "type"          => [ '', qr/\w+/os, 256 ],
                "mask"          => [ '', qr/.*/os, 256 ],
                "value"         => [ '', qr/.*/os, 10000 ],
                "selected"      => [ '', qr/.*/os, 10000 ],
                "required"      => [ '', qr/^[01]$/os ],
                "readonly"      => [ '', qr/^[01]$/os ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/settings/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            # изменение поля 1/0 (fieldname - список разрешенных полей)
            '/settings/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "fieldname"     => [ 'required', ['required', 'readonly', 'status'] ],
                "value"         => [ 'required', qr/^[01]$/os ]
            },

            'groups'  => {
                "id"            => [ '', qr/^\d+$/os ],
                "parent"        => [ '', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z]+$/os, 256 ],
                "label"         => [ '', qr/.*/os, 256 ],
                "value"         => [ '', qr/.*/os, 10000 ],
                "required"      => [ '', qr/^[01]$/os ],
                "readonly"      => [ '', qr/^[01]$/os ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            'routes'  => {
                "id"            => [ '', qr/^\d+$/os ],
                "parent"        => [ '', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z]+$/os, 256 ],
                "label"         => [ '', qr/.*/os, 256 ],
                "value"         => [ '', qr/.*/os, 10000 ],
                "required"      => [ '', qr/^[01]$/os ],
                "readonly"      => [ '', qr/^\d+$/os ]
            },
            'forum_themes'  => {
                "id"            => [ '', qr/^\d+$/os ],
                "user_id"       => [ '', qr/^\d+$/os ],
                "title"         => [ '', qr/.*/os, 10000 ],
                "url"           => [ '', qr/http.*?\/\/.*/os, 256 ],
                "rate"          => [ '', qr/^\d+$/os ],
                "date_created"  => [ '', qr/^\d+$/os ]
            },
            'forum_rates'  => {
                "user_id"       => [ '', qr/^\d+$/os ],
                "msg_id"        => [ '', qr/^\d+$/os ],
                "like_value"    => [ '', qr/^\d+$/os ]
            },
            'forum_rates'  => {
                "id"            => [ '', qr/^\d+$/os ],
                "theme_id"      => [ '', qr/^\d+$/os ],
                "user_id"       => [ '', qr/^\d+$/os ],
                "anounce"       => [ '', qr/^[01]$/os ],
                "date_created"  => [ '', qr/^\d+$/os ],
                "msg"           => [ '', qr/.*/os, 10000 ],
                "rate"          => [ '', qr/^\d+$/os ]
            }
        };

        return $vfields;
    });
}

1;