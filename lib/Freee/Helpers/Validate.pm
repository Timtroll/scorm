package Freee::Helpers::Validate;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;
use HTML::Strip;

use Data::Dumper;
use Freee::Model::Utils;
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

    # Валидация указанного блока полей и формирование типов
    # my $list = $self->_check_fields($$vfields{'/settings/save'}});
    # возвращает ссылку на хэш из $self->param(*) + ошибку, если она есть
    $app->helper( '_check_fields' => sub {
        my $self = shift;

        return 0, '_check_fields: No route' unless $self->url_for;

        my $url_for = $self->url_for;
        my %data = ();

        foreach my $field ( keys %{$$vfields{$url_for}} ) {
            my $param = $self->param($field);
            my ( $required, $regexp, $max_size ) = @{ $$vfields{$url_for}{$field} };

            # проверка длины
            if ( defined $param && $max_size && length( $param ) > $max_size ) {
                push @!, "_check_fields: '$field' has wrong size";
                last;
            }
##########################     переделать на проверку на хэш
            # проверка заполнения обязательного поля parent, оно не undef и не пустая строка
            if ( ( $required eq 'required' ) && $field eq 'parent' && ( !defined $param || $param eq '' ) ) {
                push @!, "_check_fields: didn't has required data in '$field'";
                last;
            }
            # проверка заполнения обязательного поля status, оно не undef и не пустая строка
            if ( ( $required eq 'required' ) && $field eq 'status' && ( !defined $param || $param eq '' ) ) {
                push @!, "_check_fields: didn't has required data in '$field'";
                last;
            }
            # проверка заполнения обязательного поля id роута get_leafs, оно не undef и не пустая строка
            elsif ( ( $required eq 'required' ) && $url_for =~ /get_leafs/ && ( !defined $param || $param eq '' ) ) {
                push @!, "_check_fields: didn't has required data in '$field'";
                last;
            }
            # проверка заполнения обязательных полей роута \/routes\/save, они не undef и не пустая строка
            elsif ( ( $required eq 'required' ) && $url_for =~ /\/routes\/save/ && ( !defined $param || $param eq '' ) ) {
                push @!, "_check_fields: didn't has required data in '$field'";
                last;
            }
            # проверка обязательности заполнения ( исключение - 0 для toggle, get_leafs, parent, /routes/save )
            elsif ( ( $required eq 'required' ) && $url_for !~ /(toggle|get_leafs|\/routes\/save)/ && $field ne 'parent' && $field ne 'status' && !$param ) {
                push @!, "_check_fields: didn't has required data in '$field'";
                last;
            }
############################
            # отдельная проверка для загружаемых файлов
            elsif ( ( $required eq 'file_required' ) && $param ) {
                # проверка наличия содержимого файла
                unless ( $param->{'asset'}->{'content'} ) {
                    push @!, "_check_fields: no file's content";
                    last;
                }
                $data{'content'} = $param->{'asset'}->{'content'};

                # проверка размера файла
                $data{'size'} = length( $data{'content'} );

                if ( $data{'size'} > $max_size ) {
                    push @!, "_check_fields: file is too large";
                    last;
                }

                # получение имени файла
                $data{'filename'} = $param->{'filename'};

                # получения расширения файла в нижнем регистре
                $data{'extension'} = '';
                $data{'filename'} =~ /^.*\.(\w+)$/;
                $data{'extension'} = lc $1 if $1;
                unless ( $data{'extension'} ) {
                    push @!, "_check_fields: can't read extension";
                    last;
                }

                # проверка того, что разрешено загружать файл с текущим расширением
                unless ( exists( $self->{'app'}->{'settings'}->{'valid_extensions'}->{ $data{'extension'} } ) ) {
                    push @!, "_check_fields: extension $data{'extension'} is not valid";
                    last;
                }
                next;
            }
            elsif ( $required eq 'file_required' ) {
                push @!, "_check_fields: didn't has required data in '$field'";
                last;
            }
            # проверка на toggle
            if ( $url_for =~ /toggle/ ) {
                if ( ( $field eq 'fieldname' ) && ( ref($regexp) eq 'ARRAY' ) ) {
                    unless ( defined $param && grep( /^$param$/, @{$regexp} ) ) {
                        push @!, "_check_fields: '$field' didn't match required in check array";
                        last;
                    }
                }
                else {
                    unless ( $regexp && defined $param && ( $param =~ /$regexp/ ) ) {
                        push @!, "_check_fields: '$field' didn't match regular expression";
                        last;
                    }
                }
            }
            else {
                # unless ( $regexp && ( $param =~ /$regexp/ ) ) {
                unless ( !defined $param || $param eq '' || ( $regexp && ( $param =~ /$regexp/ ) ) ) {
                    push @!, "_check_fields: '$field' didn't match regular expression";
                    last;
                }
            }

            # cохраняем переданные данные
            $data{$field} = $param;
        }

        return \%data;
    });

    # загрузка правил валидации html полоей, например:
    # my $list = $self->_param_fields('get_tree');
    # возвращает 1/undef
    $app->helper( '_param_fields' => sub {

        $vfields = {
            # валидация роутов
################
            # роуты upload/*
            '/upload'  => {
                "upload"        => [ 'file_required', undef, $app->{'settings'}->{'upload_max_size'} ],
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
            '/user'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/user/add'  => {
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 64 ],
                'phone'         => [ 'required', qr/^\+\d{11}$/os, 12 ],
                'email'         => [ 'required', qr/^[\w\@\.]+$/os, 24 ],
                'country'       => [ '', qr/^[\w\- ]+$/os, 32 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 9 ],
                'birthday'      => [ '', qr/^[\d\.\-\: ]+$/os, 12 ],
                'status'        => [ '', qr/^[01]$/os, 1 ],
                'password'      => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'avatar'        => [ '', qr/^https?\:\/\/.*?(\/[^\s]*)?$/os, 64 ],
                # 'type'          => [ '', qr/^\d+$/os, 3 ],
                'groups'        => [ 'required', qr/^\[(\d+\,)*\d+\]$/os, 255 ]
            },
            '/user/add_by_email'  => {
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 64 ],
                'country'       => [ '', qr/^[\w\- ]+$/os, 32 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 3 ],
                'birthday'      => [ '', qr/^[\d\.]+$/os, 12 ],
                'status'        => [ '', qr/^[01]$/os, 1 ],
                'password'      => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 64 ],
                'avatar'        => [ '', qr/^https?\:\/\/.*?(\/[^\s]*)?$/os, 64 ],
                # 'type'          => [ 'required', qr/^(1|2|3|4)$/os, 1 ],
                'email'         => [ 'required', qr/^[\w\d\@\.]+$/os, 100 ],
                'groups'        => [ 'required', qr/^\[(\d+\,)*\d+\]$/os, 255 ]
            },
            '/user/add_by_phone'  => {
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 64 ],
                'phone'         => [ 'required', qr/^\+\d{11}$/os, 12 ],
                'country'       => [ '', qr/^[\w\- ]+$/os, 32 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 9 ],
                'birthday'      => [ '', qr/^[\d\.\-\: ]+$/os, 12 ],
                'status'        => [ '', qr/^[01]$/os, 1 ],
                'password'      => [ 'required', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'avatar'        => [ '', qr/^https?\:\/\/.*?(\/[^\s]*)?$/os, 64 ],
                # 'type'          => [ '', qr/^\d+$/os, 3 ],
                'groups'        => [ 'required', qr/^\[(\d+\,)*\d+\]$/os, 255 ]
            },
            '/user/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'patronymic'    => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 32 ],
                'place'         => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 64 ],
                'phone'         => [ 'required', qr/^\+\d{11}$/os, 12 ],
                'email'         => [ 'required', qr/^[\w\@\.]+$/os, 24 ],
                'country'       => [ '', qr/^[\w\- ]+$/os, 32 ],
                'timezone'      => [ 'required', qr/^(\+|\-)*\d+$/os, 3 ],
                'birthday'      => [ '', qr/^[\d\.\-\: ]+$/os, 12 ],
                'status'        => [ 'required', qr/^[01]$/os, 1 ],
                'password'      => [ '', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'newpassword'   => [ '', qr/^[\w\_\-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'avatar'        => [ '', qr/^https?\:\/\/.*?(\/[^\s]*)?$/os, 64 ],
                # 'type'          => [ '', qr/^\d+$/os, 3 ],
                'groups'        => [ 'required', qr/^\[(\d+\,)*\d+\]$/os, 255 ]
            },
            '/user/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "status"        => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/user/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
################
            # роуты settings/*
            '/settings/add_folder'  => {
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/settings/get_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/save_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/settings/get_leafs'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/delete_folder'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/proto_leaf'  => {
                "parent"        => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/proto_folder'  => {
                "parent"        => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/add'  => {
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
                "status"        => [ '', qr/^[01]$/os, 1 ]
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
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/settings/edit'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "fieldname"     => [ 'required', ['required', 'readonly', 'status'], 8 ],
                "value"         => [ 'required', qr/^[01]$/os, 1 ]
            },
            '/settings/export'  => {
                "title"         => [ 'required', qr/^[\w\ \-0-9~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ]
            },
            '/settings/import'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/settings/del_export' => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
################
            # роуты discipline/*
            '/discipline'  => {
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
            },
            '/discipline/get'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/discipline/add'  => {
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "description"   => [ 'required', qr/.*/os, 256 ],
                "content"       => [ 'required', qr/.*/os, 2048 ],
                "route"         => [ 'required', qr/.*/os, 2048 ], # ????????? не нужен
                "attachment"    => [ 'required', qr/.*/os, 2048 ], # ????????? порверить regexp
                "keywords"      => [ 'required', qr/.*/os, 2048 ],
                "link"          => [ 'required', qr/.*/os, 256 ],
                "seo"           => [ 'required', qr/.*/os, 2048 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/discipline/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "parent"        => [ 'required', qr/^\d+$/os, 9 ],
                "name"          => [ 'required', qr/^[\w0-9_]+$/os, 256 ],
                "label"         => [ 'required', qr/.*/os, 256 ],
                "description"   => [ 'required', qr/.*/os, 256 ],
                "content"       => [ 'required', qr/.*/os, 2048 ],
                "route"         => [ 'required', qr/.*/os, 2048 ], # ????????? не нужен
                "attachment"    => [ 'required', qr/.*/os, 2048 ], # ????????? порверить regexp
                "keywords"      => [ 'required', qr/.*/os, 2048 ],
                "link"          => [ 'required', qr/.*/os, 256 ],
                "seo"           => [ 'required', qr/.*/os, 2048 ],
                "status"        => [ '', qr/^[01]$/os, 1 ]
            },
            '/discipline/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/discipline/toggle'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "fieldname"     => [ 'required', ['required', 'readonly', 'status'], 8 ],
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
                "fieldname"     => [ 'required', ['status'], 6 ],
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
                "fieldname"     => [ 'required', ['list', 'add', 'edit', 'delete', 'status'], 6],
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
                "table"         => [ '', ['forum_messages', 'forum_themes', 'forum_groups'], 14 ],
                "value"         => [ '', qr/^[01]$/os, 1 ]
            }
        };

        return $vfields;
    });
}

1;
