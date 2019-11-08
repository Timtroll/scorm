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
# warn Dumper($_[0]->tx->req->params->to_hash);
        return 0 unless $_[1];

        my @error = ();

       # Проверка наличия объекта для валидации
        if ( defined $vfields->{$_[1]} ) {
            my $valid = $vfields->{$_[1]};

            # проверка полей
            my $hs = HTML::Strip->new();

            # проверка для роутов
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
                    # есть ли значение в списке
                    if (ref($re) eq 'ARRAY') {
                        unless ( grep {/$val/} @{$$valid{$fld}[1]} ) {
                            push @error, "Validation error for '$fld'. Field has wrong type=";
                        }
                    }
                    # валидация по регэкспу
                    else {
                        unless ( $val =~ $re ) {
                            push @error, "Validation error for '$fld'. Field has wrong type";
                        }
                    }
                }
                else {
                    if ( $$valid{$fld}[0] && ($$valid{$fld}[0] eq 'required') ) {
                        push @error, "Validation error for '$fld'. Field is empty or not exists";
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

        return 0, '_check_fields: No route' unless $self->url_for;

        my %data = ();
        foreach (keys %{$$vfields{$self->url_for}}) {
            $data{$_} = $self->param($_);
            if ( defined $self->param($_) && ($$vfields{$self->url_for}{$_}[0] eq 'required') ) {
                $data{$_} = $self->param($_) // 0;
            }
        }

        my $route = $self->url_for;
        # проверка, указанынй id это фолдер или нет (для роутов с 'settings' и 'folder' в названии)
        if ( ( ( $route =~ /^\/settings/ ) ) && ( $data{'id'} ) ) {
            if ( $route =~ /folder$/ ) {
                unless ( $self->_folder_check( $data{'id'} ) ) {
                    return 0, "_check_fields: Action for '$data{'id'}' is not allowed for '$route'";
                }
            }
            else {
                # 'toggle' работает для фолдеров и записей
                if ( $route =~ /toggle$/ ) {
                    if ( defined $$vfields{$self->url_for}{'fieldname'} ) {
                        my $value = $data{'fieldname'};
                        unless ( grep( /^$value$/, @{$$vfields{$self->url_for}{'fieldname'}[1]} ) ) {
                            return 0, "_check_fields: Action is not allowed to '$route', wrong field '$data{'fieldname'}'";
                        }
                    }
                }
                elsif ($route =~ /(add|edit|save)$/) {
                    if ( $self->_folder_check( $data{'id'} ) ) {
                        return 0, "_check_fields: Action is not allowed for '$route'";
                    }
                }
            }
        }

        return \%data;
    });

    # загрузка правил валидации html полоей
    # my $list = $self->_param_fields('get_tree');
    # возвращает 1/undef
    $app->helper( '_param_fields' => sub {
        $vfields = {
            # валидация роутов
################
            # роуты settings/*
            '/settings/add_folder'  => {
                "parent"        => [ '', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/settings/get_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
            },
            '/settings/save_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "parent"        => [ 'required', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/settings/get_leafs'  => {
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            '/settings/delete_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
            },
            '/settings/add'  => {
                "parent"        => [ 'required', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z0-9_]+$/os, 256 ],
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
            '/settings/save'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "parent"        => [ 'required', qr/^\d+$/os ],
                "name"          => [ 'required', qr/^[A-Za-z0-9_]+$/os, 256 ],
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
            '/settings/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            '/settings/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            '/settings/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "fieldname"     => [ 'required', ['required', 'readonly', 'status'] ],
                "value"         => [ 'required', qr/^[01]$/os ]
            },
################
            # роуты groups/*
            '/groups/add'  => {
                "label"         => [ 'required', qr/.*/os, 256 ],
                "name"          => [ 'required', qr/^[A-Za-z0-9_]+$/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/groups/edit'  => {
                 "id"           => [ 'required', qr/^\d+$/os ]
            },
            '/groups/save'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "name"          => [ 'required', qr/^[A-Za-z0-9_]+$/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/groups/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            '/groups/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "fieldname"     => [ 'required', ['status'] ],
                "value"         => [ 'required', qr/^[01]$/os ]
            },
################
            # роуты routes/*
            '/routes'  => {
                "parent"        => [ 'required', qr/^\d+$/os ]
            },
            '/routes/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            '/routes/save'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "list"          => [ 'required', qr/^[01]$/os ],
                "add"           => [ 'required', qr/^[01]$/os ],
                "edit"          => [ 'required', qr/^[01]$/os ],
                "delete"        => [ 'required', qr/^[01]$/os ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/routes/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os ],
                "fieldname"     => [ 'required', ['list', 'add', 'edit', 'delete', 'status'] ],
                "value"         => [ 'required', qr/^[01]$/os ]
            },
################
            # роуты forum/*
            '/forum/theme'  => {
                "id"            => [ '', qr/^\d+$/os ]
            },
            '/forum/add_theme'  => {
                "user_id"       => [ '', qr/^\d+$/os ],
                "group_id"      => [ '', qr/^\d+$/os ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "url"           => [ '', qr/^.*$/os, 256 ],
                "rate"          => [ '', qr/^\d+$/os ],
                "date_created"  => [ '', qr/^\d+$/os ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            '/forum/save_theme' => {
                "group_id"      => [ '', qr/^\d+$/os ],
                "id"            => [ '', qr/^\d+$/os ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            '/forum/edit_theme'  => {
                "theme_id"      => [ '', qr/^\d+$/os ],
                "id"            => [ '', qr/^\d+$/os ]
            },
            '/forum/del_theme'  => {
                "parent_id"     => [ '', qr/^\d+$/os ],
                "id"            => [ '', qr/^\d+$/os ]
            },
            '/forum/group'  => {
                "id"            => [ '', qr/^\d+$/os ]
            },
            '/forum/add_group'  => {
                "name"          => [ '', qr/^.*$/os, 256 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            '/forum/save_group'  => {
                "id"            => [ '', qr/^\d+$/os ],
                "name"          => [ '', qr/^.*$/os, 256 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            '/forum/edit_group'  => {
                "id"            => [ '', qr/^\d+$/os ]
            },
            '/forum/del_group'  => {
                "id"            => [ '', qr/^\d+$/os ]
            },
            '/forum/add'  => {
                "theme_id"      => [ '', qr/^\d+$/os ],
                "user_id"       => [ '', qr/^\d+$/os ],
                "anounce"       => [ '', qr/^.*$/os, 256 ],
                "date_created"  => [ '', qr/^\d+$/os ],
                "date_edited"   => [ '', qr/^\d+$/os ],
                "msg"           => [ '', qr/^.*$/os, 256 ],
                "rate"          => [ '', qr/^\d+$/os ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            '/forum/save'  => {
                "theme_id"      => [ '', qr/^\d+$/os ],
                "id"            => [ '', qr/^\d+$/os ],
                "msg"           => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os ]
            },
            
            '/forum/delete'  => {
                "parent_id"     => [ '', qr/^\d+$/os ],
                "id"            => [ 'required', qr/^\d+$/os ]
            },
            '/forum/edit'  => {
                "theme_id"      => [ '', qr/^\d+$/os ],
                "id"            => [ '', qr/^\d+$/os ]
            },
            'forum_rates'  => {
                "id"            => [ '', qr/^\d+$/os ],
                "theme_id"      => [ '', qr/^\d+$/os ],
                "user_id"       => [ '', qr/^\d+$/os ],
                "anounce"       => [ '', qr/^[01]$/os ],
                "date_created"  => [ '', qr/^\d+$/os ],
                "msg"           => [ '', qr/.*/os, 10000 ],
                "rate"          => [ '', qr/^\d+$/os ]
            },
            '/forum/toggle'  => {
                "parent_id"     => [ '', qr/^\d+$/os ],
                "id"            => [ '', qr/^\d+$/os ],
                "fieldname"     => [ '', ['status'] ],
                "table"         => [ '', ['forum_messages', 'forum_themes', 'forum_groups'] ],
                "value"         => [ '', qr/^[01]$/os ]
            },
        };

        return $vfields;
    });
}

1;