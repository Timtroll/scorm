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

#     # Валидация указанного блока полей при чтении html запроса
#     # my $list = $self->_check('settings');
#     # возвращает 1/undef
#     $app->helper( '_check' => sub {
# # warn Dumper($_[0]->tx->req->params->to_hash);
#         return 0 unless $_[1];

#         my @error = ();

#        # Проверка наличия объекта для валидации
#         if ( defined $vfields->{$_[1]} ) {
#             my $valid = $vfields->{$_[1]};

#             # проверка полей
#             my $strip = HTML::Strip->new();

#             # проверка для роутов
#             foreach my $fld (keys %$valid) {

#                 # читаем и чистим поле от html
#                 my $val = $_[0]->param($fld) // 0;
#                 $val = $strip->parse($val) if $val;

#                 # Проверка обязательности поля
#                 if ( defined $_[0]->param($fld) && ($$valid{$fld}[0] eq 'required') ) {
#                     unless ($val) {
#                        push @error, "Field '$fld' has null length";
#                        next;
#                     }

#                     # проверяем длинну поля, если указано проверять ??????????????????????????????? дублируется в _check_fields
#                     if ( $$valid{$fld}[2] ) {
#                         if ( !$val || length($val) > $$valid{$fld}[2] ) {
#                             push @error, "Validation error for '$fld'. Field has wrong length";
#                             next;
#                         }
#                     }

#                     my $re = $$valid{$fld}[1];
# warn ref($re);
#                     #  задан ли Regexp
#                     if ( ref($re) eq 'Regexp' ) {
#                         unless ( grep {/$val/} @{$$valid{$fld}[1]} ) {
#                             push @error, "Validation error for '$fld'. Field has wrong type=";
#                         }
#                     }
#                     # # валидация по регэкспу
#                     # else {
#                     #     unless ( $val =~ $re ) {
#                     #         push @error, "Validation error for '$fld'. Field has wrong type";
#                     #     }
#                     # }
#                 }
#                 else {
# # ??????????????????
#                     if ( $$valid{$fld}[0] && ($$valid{$fld}[0] eq 'required') ) {
#                         push @error, "Validation error for '$fld'. Field is empty or not exists";
#                     }
#                 }
#             }
#         }
#         else {
#             push @error, "Not exists validation data for route '$_[1]'";
#         }

#         return @error ? 0 : 1, \@error;
#     });

    # Валидация указанного блока полей и формирование типов
    # my $list = $self->_check_fields($$vfields{'/settings/save'}});
    # возвращает ссылку на хэш из $self->param(*) + ошибку, если она есть
    $app->helper( '_check_fields' => sub {
        my $self = shift;

        return 0, '_check_fields: No route' unless $self->url_for;

        my @error;
        my %data = ();

        foreach ( keys %{$$vfields{$self->url_for}} ) {
warn $_;
            # проверка статуса
            if (
                $self->param($_) &&
                (
                    ( $$vfields{ $self->url_for }{$_}[0] eq 'required' ) ||
                    ( $$vfields{ $self->url_for }{$_}[0] eq '' )
                )
            ) {
                # проверка длины
                unless (
                    $vfields->{ $self->url_for }->{$_}->[2] &&
                    length( $self->param($_) ) <= $vfields->{ $self->url_for }->{$_}->[2]
                ) {
                    push @error, "_check_fields: wrong size of '$_'";
                    last;
                }

                # проверка соответствия рег выражению
                my $regular = $vfields->{ $self->url_for }->{$_}->[1];
                unless ( $regular && ( $self->param( $_ ) =~ /$regular/ ) ) {
                    push @error, "_check_fields: '$_' don't match regular expression";
                    last;
                }

                # ввод данных в хэш
                $data{$_} = $self->param($_);
            }
            elsif ( ( $$vfields{$self->url_for}{$_}[0] eq 'file_required' ) && ( $self->param($_) ) ) {
                # старое имя файла
                $data{'title'} = $self->param($_)->{'filename'} // 0;
                unless ( $data{'title'} ) {
                    push @error, "_check_fields: can't read file's old name";
                    last;
                }

                unless ( exists $self->param( $_ )->{'asset'}->{'content'} ) {
                    push @error, "_check_fields: file is too large for input limit";
                    last;
                }

                # содержимое файла
                $data{ 'content' } = $self->param( $_ )->{'asset'}->{'content'} // 0;
                unless ( $data{'content'} ) {
                    push @error, "_check_fields: no file's content";
                    last;
                }

                # имя файла
                unless ( $data{ 'title' } ) {
                    push @error, "_check_fields: can't read content";
                    last;
                }

                # размер файла
                $data{ 'size' } = length( $data{ 'content' } );

                if ( $data{ 'size' } > $self->{'app'}->{'settings'}->{ 'upload_max_size' } ) {
                    push @error, "_check_fields: file is too large";
                    last;
                }

                ## новое имя файла
                # расширение файла
use Data::Dumper;
warn Dumper $self->param( $_ )->{'headers'};
                $data{'extension'} = $self->param( $_ )->{'headers'}->{'headers'}->{'content-disposition'}->[0] // 0;
                unless ( $data{'extension'} ) {
                    push @error, "_check_fields: can't read extension";
                    last;
                }

                $data{'extension'} =~ /^.*filename=\"(.*?)\.(.*?)\"/;
                $data{'extension'} = lc $2;

                # проверка расширения
                unless ( exists( $self->{'app'}->{'settings'}->{'valid_extensions'}->{ $data{'extension'} } ) ) {
                    push @error, "_check_fields: extension $data{'extension'} is not valid";
                    last;
                }

# перенести в контроллер
                # генерация случайного имени
                my $name_length = $self->{'app'}->{'settings'}->{'upload_name_length'};
                $data{ 'filename' } = $self->_random_string( $name_length );
                my $fullname = $data{ 'filename' } . '.' . $data{'extension'};

                while ( $self->_exists_in_directory( './upload/'.$fullname ) ) {
                    $data{ 'filename' } = $self->_random_string( $name_length );
                    $fullname = $data{ 'filename' } . '.' . $data{'extension'};
                }
                # путь файла
                $data{ 'path' } = 'local';
            }
            else {
                unless ( ( $$vfields{ $self->url_for }{$_}[0] eq '' ) || ( $$vfields{$self->url_for}{$_}[0] eq 'filename' ) ) {
                    push @error, "_check_fields: don't have required data";
                    last;
                }
            }
        }


        my $route = $self->url_for;
        # проверка, указанынй id это фолдер или нет (для роутов с'settings'и 'folder' в названии)
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
                elsif ( $route =~ /(add|edit|save)$/ ) {
                    if ( $self->_folder_check( $data{'id'} ) ) {
                        return 0, "_check_fields: Action is not allowed for '$route'";
                    }
                }
            }
        }
        elsif ( ( ( $route =~ /^\/upload/ ) ) && ( $data{'id'} ) ) {
        }

        my $error;
        if ( @error ) {
            $error = join( "\n", @error );
        }

        return \%data, $error;

    });

    # загрузка правил валидации html полоей, например:
    # my $list = $self->_param_fields('get_tree');
    # возвращает 1/undef
    $app->helper( '_param_fields' => sub {
warn '_param_fields';
warn $self->{'app'}->{'upload_max_size'};
        $vfields = {
            # валидация роутов
################
            # роуты settings/*
            '/upload'  => {
                "upload"        => [ 'file_required', undef, $self->{'app'}->{'upload_max_size'} ],
                "description"   => [ '', qr/^[\w\ \-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ]
            },
            '/upload/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/upload/search'  => {
                "search"        => [ 'required', qr/^[\w\ \-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ],
            },
            '/upload/update'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "description"   => [ '', qr/^[\w\ \-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ]
            },
################
            # роуты user/*
            '/user/add'  => {
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\- \,\.№\'\"\/0-9]$/os, 64 ],
                'country'       => [ 'required', qr/^[\w\- ]+$/os, 32 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 9 ],
                'birthday'      => [ 'required', qr/^\d+$/os, 12 ],
                'status'        => [ 'required', qr/^[01]$/os, 1 ],
                'password'      => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'newpassword'   => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'avatar'        => [ 'required', qr/^https?\:\/\/.*?(\/[^\s]*)?$/os, 64 ],
                'type'          => [ 'required', qr/^\d+$/os, 3 ]
            },
            '/user/add_by_email'  => {
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\- \,\.№\'\"\/0-9]$/os, 64 ],
                'country'       => [ 'required', qr/^\d+$/os, 3 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 3 ],
                'birthday'      => [ 'required', qr/^\d+$/os, 12 ],
                'password'      => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'avatar'        => [ 'required', qr/^\d+$/os, 9 ],
                'type'          => [ 'required', qr/^(1|2|3|4)$/os, 1 ],
                'email'         => [ 'required', qr/^[\w\d\@]+$/os, 100 ]
            },
            '/user/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\- \,\.№\'\"\/0-9]$/os, 64 ],
                'country'       => [ 'required', qr/^[\w\- ]+$/os, 32 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 3 ],
                'birthday'      => [ 'required', qr/^\d+$/os, 12 ],
                'status'        => [ 'required', qr/^[01]$/os, 1 ],
                'password'      => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'newpassword'   => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'avatar'        => [ 'required', qr/^https?\:\/\/.*?(\/[^\s]*)?$/os, 64 ],
                'type'          => [ 'required', qr/^\d+$/os, 3 ]
            },
            '/user/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
################
            # роуты settings/*
            '/settings/add_folder'  => {
                "parent"        => [ '', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os ]
            },
            '/settings/get_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/save_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/settings/get_leafs'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/delete_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
            },
            '/settings/proto_leaf'  => {
                "parent"        => [ 'required', qr/^\d+$/os ]
            },
            '/settings/proto_folder'  => {
                "parent"        => [ 'required', qr/^\d+$/os ]
            },
            '/settings/add'  => {
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "placeholder"   => [ '', qr/.*/os, 256 ],
                "type"          => [ '', qr/\w+/os, 256 ],
                "mask"          => [ '', qr/.*/os, 256 ],
                "value"         => [ '', qr/.*/os, 10000 ],
                "selected"      => [ '', qr/.*/os, 10000 ],
                "required"      => [ '', qr/^[01]$/os, 1 ],
                "readonly"      => [ '', qr/^[01]$/os, 1 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/settings/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "placeholder"   => [ '', qr/.*/os, 256 ],
                "type"          => [ '', qr/\w+/os, 256 ],
                "mask"          => [ '', qr/.*/os, 256 ],
                "value"         => [ '', qr/.*/os, 10000 ],
                "selected"      => [ '', qr/.*/os, 10000 ],
                "required"      => [ '', qr/^[01]$/os, 1 ],
                "readonly"      => [ '', qr/^[01]$/os, 1 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/settings/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "fieldname"     => [ 'required', ['required', 'readonly', 'status'] ],
                "value"         => [ 'required', qr/^[01]$/os, 1 ]
            },
################
            # роуты groups/*
            '/groups/add'  => {
                "label"         => [ 'required', qr/.*/os, 256 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/groups/edit'  => {
                 "id"           => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/groups/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/groups/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/groups/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "fieldname"     => [ 'required', ['status'] ],
                "value"         => [ 'required', qr/^[01]$/os, 1 ]
            },
################
            # роуты routes/*
            '/routes'  => {
                "parent"        => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/routes/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/routes/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "list"          => [ 'required', qr/^[01]$/os, 1 ],
                "add"           => [ 'required', qr/^[01]$/os, 1 ],
                "edit"          => [ 'required', qr/^[01]$/os, 1 ],
                "delete"        => [ 'required', qr/^[01]$/os, 1 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/routes/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "fieldname"     => [ 'required', ['list', 'add', 'edit', 'delete', 'status'] ],
                "value"         => [ 'required', qr/^[01]$/os, 1 ]
            },
################
            # роуты forum/*
            '/forum/theme'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/add_theme'  => {
                "group_id"      => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/save_add_theme' => {
                "group_id"      => [ '', qr/^\d+$/os, 9 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "url"           => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/save_edit_theme' => {
                "group_id"      => [ '', qr/^\d+$/os, 9 ],
                "id"            => [ '', qr/^\d+$/os, 9 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "url"           => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/edit_theme'  => {
                "theme_id"      => [ '', qr/^\d+$/os, 9 ],
                "id"            => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/del_theme'  => {
                "parent_id"     => [ '', qr/^\d+$/os, 9 ],
                "id"            => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/add_group'  => {
                "name"          => [ '', qr/^.*$/os, 256 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/save_add_group'  => {
                "name"          => [ '', qr/^.*$/os, 256 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/save_edit_group'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ],
                "name"          => [ '', qr/^.*$/os, 256 ],
                "title"         => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/edit_group'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/del_group'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/add'  => {
                "theme_id"      => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/save_add'  => {
                "theme_id"      => [ '', qr/^\d+$/os, 9 ],
                "msg"           => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/save_edit'  => {
                "theme_id"      => [ '', qr/^\d+$/os, 9 ],
                "id"            => [ '', qr/^\d+$/os, 9 ],
                "msg"           => [ '', qr/^.*$/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/forum/delete'  => {
                "parent_id"     => [ '', qr/^\d+$/os, 9 ],
                "id"            => [ 'required', qr/^\d+$/os, 1 ]
            },
            '/forum/edit'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ]
            },
            'forum_rates'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ],
                "theme_id"      => [ '', qr/^\d+$/os, 9 ],
                "user_id"       => [ '', qr/^\d+$/os, 9 ],
                "anounce"       => [ '', qr/^[01]$/os, 1 ],
                "date_created"  => [ '', qr/^\d+$/os, 9],
                "msg"           => [ '', qr/.*/os, 10000 ],
                "rate"          => [ '', qr/^\d+$/os, 9 ]
            },
            '/forum/toggle'  => {
                "id"            => [ '', qr/^\d+$/os, 9 ],
                "table"         => [ '', ['forum_messages', 'forum_themes', 'forum_groups'] ],
                "value"         => [ '', qr/^[01]$/os, 1 ]
            }
        };

        return $vfields;
    });
}

1;
