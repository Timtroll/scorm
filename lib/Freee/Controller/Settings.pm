package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use Encode;

use Freee::Mock::Settings;
use Freee::Mock::Extensions;

use Freee::Model::Settings;
use Freee::Model::Utils;
use File::Slurp;

use Data::Dumper;
use common;

#####################
# Работа с фолдерами

# получить данные фолдера
sub get_folder {
    my $self = shift;

    my ( $resp, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверка существования id
        unless ( $self->model('Utils')->_exists_in_table( 'settings', 'id', $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' doesn't exist";
        }
        # проверка того, что id принадлежит группе настроек
        elsif ( !$self->model('Utils')->_folder_check( $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' is not a folder";
        }
    }

    unless ( @mess ) {
        $data = $self->model('Settings')->_get_folder( $self->param('id') );
        push @mess, "Could not get '".$self->param('id')."'" unless $data;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data unless @mess;

    $self->render( 'json' => $resp );
}

# получить дерево без листьев
sub get_tree {
    my $self = shift;

    # передаем 1, чтобы получить дерево без листьев
    my $list = $self->model('Settings')->_get_tree( 1 );

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless $list;
    $resp->{'status'} = $list ? 'ok' : 'fail';
    $resp->{'list'} = $list if $list;

    $self->render( 'json' => $resp );
}

# сохранить группу настроек
sub save_folder {
    my $self = shift;

    my ($id, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    # проверка данных
    unless (@mess) {
        ($data, $error) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверка существования id
        unless ( $self->model('Utils')->_exists_in_table( 'settings', 'id', $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' doesn't exist";
        }
        # проверка того, что id принадлежит группе настроек
        elsif ( !$self->model('Utils')->_folder_check( $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' is not a folder";
        }
    }

    # сохранение
    unless (@mess) {
        # устанавляваем неиспользуемые для фолдера поля
        $$data{'placeholder'} = '';
        $$data{'type'} = '';
        $$data{'mask'} = '';
        $$data{'value'} = '';
        $$data{'selected'} = '';
        $$data{'required'} = 0;
        $$data{'readonly'} = 0;
        $$data{'folder'} = $self->param('folder') // 1;
        $$data{'status'} = $self->param('status') // 0;

        $id = $self->model('Settings')->_save_folder( $data );
        push @mess, "Could not save folder item '$$data{'id'}'" unless $id;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# создание группы настроек
# my $id = $self->add();
# {
#     "parent"      => 0,           - обязательно (должно быть натуральным числом)
#     "label"       => 'название',  - обязательно (название для отображения)
#     "name",       => 'name'       - обязательно (системное название, латиница)
#     "status",     => 1            - статус поля (1 - включено (ставится по умолчанию), 0 - выключено)
# }
sub add_folder {
    my $self = shift;

    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверяем поле name на дубликат
        if ($self->model('Utils')->_exists_in_table('settings', 'name', $$data{'name'})) {
            push @mess, "Folder item named '$$data{'name'}' is exists";
        }
    }

    unless ( @mess ) {
        # проверяем существование родителя ( корневой каталог существует всегда )
        if ( $$data{'parent'} ne 0 && !( $self->model('Utils')->_exists_in_table('settings', 'id', $$data{'parent'} ) ) ) {
            push @mess, "Parent folder with id '$$data{'parent'}' doesn't exist";
        }
    }

    unless ( @mess ) {
        # устанавляваем обязательные поля для фолдера
        $$data{'placeholder'} = '';
        $$data{'type'} = '';
        $$data{'mask'} = '';
        $$data{'value'} = '';
        $$data{'selected'} = '';
        $$data{'required'} = 0;
        $$data{'readonly'} = 0;
        $$data{'status'} = 1;
        $$data{'folder'} = 1;

        # добавление фолдера
        $id = $self->model('Settings')->_insert_folder( $data );

        push @mess, "Could not create new folder item '$$data{'id'}'" unless $id;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

#####################
# Работа с Настройками

# выбираем листья ветки дерева
# my $id = $self->get_leafs();
# 'id' - id фолдера, для которого выбираем листья (id = 0 - выбираем корневые записи)
sub get_leafs {
    my $self = shift;

    my ( $resp, $list, $table, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;

        unless ( @mess ) {
            if ( $$data{'id'} == 0 || $self->model('Utils')->_exists_in_table('settings', 'id', $$data{'id'} ) && !$self->model('Utils')->_folder_check( $$data{'parent'} ) )  {
                $list = $self->model('Settings')->_get_leafs( $$data{'id'} );
                push @mess, "Could not get leafs for folder id '".$$data{'id'}."'" unless $list;

                # данные для таблицы
                $table = {
                    "settings" => {
                        "massEdit"  => 0,        # групповое редактировани
                        "editable"  => 1,        # разрешение редактирования
                        "removable" => 1,        # разрешение удаления
                        "sort" => {         # сотрировка по
                            "name"    => "id",
                            "order"   => "asc"
                        },
                        "page" => {
                          "current_page"    => 1,
                          "per_page"        => 10,
                          "total"           => scalar(@$list)
                        }
                    },
                    "body" => $list
                } unless @mess;
            } else {
                push @mess, "Folder id '$$data{'id'}' does not exist";
            }
        }
    }
    else {
        push @mess, "Setting id '$$data{'id'}' not exists";
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'list'} = $table if $table;

    $self->render( 'json' => $resp );
}

# загрузка данных в таблицу настроек из /Mock/Settings.pm
# my $id = $self->load_default();
sub load_default {
    my $self = shift;

    # очистка таблицы и сброс счетчика
    $self->model('Settings')->_reset_settings();

    my ($id, $sub, $resp, @mess);
    foreach my $folder ( @{$settings->{'settings'}} ) {
        $sub = {
            "name"          => $$folder{'name'},
            "placeholder"   => $$folder{'placeholder'} // '',
            "label"         => $$folder{'label'},
            "mask"          => $$folder{'mask'} // '',
            "type"          => $$folder{'type'} // '',
            "value"         => $$folder{'value'} // '',
            "selected"      => $$folder{'selected'} // '',
            "required"      => $$folder{'required'} // 0,
            "readonly"      => 0,
            "status"        => 1,
            "folder"        => 1,
            "parent"        => 0
        };
        $id = $self->model('Settings')->_insert_folder($sub, []);
        push @mess, "Could not add setting Folder '$$folder{'label'}'" unless $id;

        if (@{$$folder{'children'}}) {
            foreach my $children ( @{$$folder{'children'}} ) {
                $sub = {
                    "name"          => $$children{'name'},
                    "placeholder"   => $$children{'placeholder'} // '',
                    "label"         => $$children{'label'},
                    "mask"          => $$children{'mask'} // '',
                    "type"          => $$children{'type'} // '',
                    "value"         => ref( $$children{'value'} ) eq 'ARRAY' ? JSON::XS->new->allow_nonref->encode( $$children{'value'} ) : $$children{'value'},
                    "selected"      => ref( $$children{'selected'} ) eq 'ARRAY' ? JSON::XS->new->allow_nonref->encode( $$children{'selected'} ) : '[]',
                    "required"      => $$children{'required'} // 0,
                    "readonly"      => 0,
                    "folder"        => 0,
                    "status"        => 1,
                    "parent"        => $id  # указываем родительский id
                };
                # значение valid_extensions берётся из Mock/extensions.pm
                if ( $$children{'name'} eq 'valid_extensions' ) {
                    $$sub{'value'} = $mime;
                }
                my $chldid = $self->model('Settings')->_insert_setting($sub, []);
                push @mess, "Could not add setting item '$$children{'label'}' in Folder '$$children{'label'}'" unless $chldid;
            }
        }
    }

    # добавление valid_extensions из extensions.json

    # обновление объекта с настройками
    $self->{'settings'} = $self->model('Settings')->_get_config();

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

# создание настройки
# my $id = $self->add();
# "folder"      => 0,             - это запись настроек
# "parent"      => 0,             - обязательно (должно быть натуральным числом)
# "label"       => 'название',    - обязательно (название для отображения)
# "name",       => 'name'         - обязательно (системное название, латиница)
# "status",     => 0/1            - обязательно (системное название, латиница)
# "readonly"    => 0,             - не обязательно, по умолчанию 0
# "value"       => "",            - строка или json
# "type"        => "InputNumber", - тип поля из конфига
# "placeholder" => 'это название',- название для отображения в форме
# "mask"        => '\d+',         - регулярное выражение
# "selected"    => "CKEditor",    - значение по-умолчанию для select
# "required"    => 1              - обязательное поле
sub add {
    my $self = shift;

    # read params
    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;

        unless (@mess) {
            # корректирование пустых значений
            $$data{'folder'} = 0;
            unless ( defined $$data{'placeholder'} ) { $$data{'placeholder'} = '' };
            unless ( defined $$data{'type'} )        { $$data{'type'}        = '' };
            unless ( defined $$data{'mask'} )        { $$data{'mask'}        = '' };
            unless ( defined $$data{'value'} )       { $$data{'value'}       = '' };
            unless ( defined $$data{'selected'} )    { $$data{'selected'}    = '' };
            unless ( defined $$data{'required'} )    { $$data{'required'}    = 0 };
            unless ( defined $$data{'readonly'} )    { $$data{'readonly'}    = 0 };
            unless ( defined $$data{'status'} )      { $$data{'status'}      = 1 };

            # проверяем поле name на дубликат
            if ( $self->model('Utils')->_exists_in_table('settings', 'name', $$data{'name'} ) ) {
                push @mess, "Setting named '$$data{'name'}' is exists";
            }
            # проверяем то, что родитель существует и является фолдером
            elsif ( !$self->model('Utils')->_folder_check( $$data{'parent'} ) ) {
                push @mess, "setting have wrong parent $$data{'parent'}";
            }
            # запись настройки в бд
            else {
                $id = $self->model('Settings')->_insert_setting( $data, [] );
                push @mess, "Could not create new setting item '$$data{'id'}'" unless $id;
            }
        }
    }
    # обновление объекта с настройками
    $self->{'settings'} = $self->model('Settings')->_get_config();

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# получение настройки по id
# my $row = $self->edit()
# 'id' - id настрокйи
sub edit {
    my $self = shift;

    my ($id, $data, $result, $error, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {    
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # проверка того, что id принадлежит настройке
    unless ( @mess ) {
        if ( $self->model('Utils')->_folder_check( $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' is not a setting";
        }
    }

    unless ( @mess ) {
        $result = $self->model('Settings')->_get_setting( $$data{'id'} );
        push @mess, "Could not get id ".$$data{'id'} unless $result;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $result if $result;

    $self->render( 'json' => $resp );
}

# сохранение настройки
# my $id = $self->save();
# "folder"      => 0,           - это запись настроек
# "parent"      => 0,           - обязательно (должно быть натуральным числом)
# "label"       => 'название',  - обязательно (название для отображения)
# "name",       => 'name'       - обязательно (системное название, латиница)
# "readonly"    => 0,           - не обязательно, по умолчанию 0
# "value"       => "",            - строка или json
# "type"        => "InputNumber", - тип поля из конфига
# "placeholder" => 'это название',- название для отображения в форме
# "mask"        => '\d+',         - регулярное выражение
# "selected"    => "CKEditor",    - значение по-умолчанию для select
# "required"    => 1              - обязательное поле
sub save {
    my $self = shift;

    # read params
    my ( $id, $data, $error, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # проверка существования id
        unless ( $self->model('Utils')->_exists_in_table( 'settings', 'id', $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' doesn't exist";
        }
        # проверка того, что id принадлежит настройке
        elsif ( $self->model('Utils')->_folder_check( $$data{'id'} ) ) {
            push @mess, "Id '$$data{'id'}' is not a setting";
        }
    }

    unless ( @mess ) {
        # корректирование пустых значений
        $$data{'folder'} = 0;
        unless ( defined $$data{'placeholder'} ) { $$data{'placeholder'} = '' };
        unless ( defined $$data{'type'} )        { $$data{'type'}        = '' };
        unless ( defined $$data{'mask'} )        { $$data{'mask'}        = '' };
        unless ( defined $$data{'value'} )       { $$data{'value'}       = '' };
        unless ( defined $$data{'selected'} )    { $$data{'selected'}    = '' };
        unless ( defined $$data{'required'} )    { $$data{'required'}    = 0 };
        unless ( defined $$data{'readonly'} )    { $$data{'readonly'}    = 0 };
        unless ( defined $$data{'status'} )      { $$data{'status'}      = 0 };

        # проверяем поле name на дубликат
        if ($self->model('Utils')->_exists_in_table('settings', 'name', $$data{'name'}, $$data{'id'})) {
            push @mess, "Setting named '$$data{'name'}' is exists";
        }
        # проверяем то, что родитель существует и является фолдером
        elsif ( !$self->model('Utils')->_folder_check( $$data{'parent'} ) ) {
            push @mess, "setting have wrong parent $$data{'parent'}";
        }
        # сохранение настройки
        else {
            $id = $self->model('Settings')->_save_setting( $data, [] );
            push @mess, "Could not update setting item '$$data{'id'}'" unless $id;
        }
    }

    # обновление объекта с настройками
    $self->{'settings'} = $self->model('Settings')->_get_config();

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok' ;
    $resp->{'id'} = $id if $id;

    $self->render( 'json' => $resp );
}

# удаление фолдера настроек (с дочерними листьями) или отдельной настройки
# my $true = $self->delete();
# 'id'  - id настрокйи
sub delete {
    my $self = shift;

    my ( $del, $resp, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;

        $del = $self->model('Settings')->_delete_setting( $$data{'id'} ) unless @mess;
        push @mess, "Could not delete '$$data{'id'}'" unless ( $del || @mess );
    }
    # обновление объекта с настройками
    $self->{'settings'} = $self->model('Settings')->_get_config();

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $del;

    $self->render( 'json' => $resp );
}

# изменение поля на 1/0
# my $true = $self->toggle();
# 'id'    - id записи 
# 'field' - имя поля в таблице
# 'val'   - 1/0
sub toggle {
    my $self = shift;

    my ( $toggle, $resp, $data, $error, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;

        unless ( @mess ) {
            $$data{'table'} = 'settings';

            # проверка существования элемента для изменения
            unless ($self->model('Utils')->_exists_in_table('settings', 'id', $$data{'id'})) {
                push @mess, "Id '$$data{'id'}' doesn't exist";
            }
            # изменение поля
            unless ( @mess ) {
                $toggle = $self->model('Utils')->_toggle( $data );
                push @mess, "Could not toggle '$$data{'id'}'" unless $toggle;
            }
        }
    }
    # обновление объекта с настройками
    $self->{'settings'} = $self->model('Settings')->_get_config();

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}

# экспорт текущих настроек
# my $id = $self->export();
# 'title' - описание файла с настройками в базе
sub export {
    my $self = shift;

    my ( $id, $error, $resp, $data, $result, $json, $time, $filename, $filepath, @result, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # получение всех настроек
    unless ( @mess ) {
        $result = $self->model('Settings')->_get_all_settings();
        if ( $result ) {
                foreach ( keys %$result ) {
                push @result, $$result{ $_ };
            }
            $result = \@result;
        }
        else {
            push @mess, 'can\'t get data from settings';
        }
    }

    # кодирование данных в json
    unless ( @mess ) {
        # перевод настреок в json
        $json = encode_json( $result );
        push @mess, "Can't encode into json" unless $json;
    }

    # запись данных в файл
    unless ( @mess ) {
        # получение времени
        $time = $self->model('Utils')->_get_time();
        # имя файла
        $filename = $time . '.json';
        # путь к файлу
        $filepath = $self->{'app'}->{'config'}->{'export_settings_path'} . '/' . $filename;
        # запись файла
        $result = write_file(
            $filepath,
            $json,
            {err_mode => 'silent'}
        );
        push @mess, "Can't store '$filepath'" unless $result;
    }

    # запись данных о файле с настройками
    unless ( @mess ) {
        $id = $self->model('Settings')->_insert_export_setting( $$data{'title'}, $filename, $time );
        push @mess, "Can't insert '$filename' file into DB" unless $id;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @mess;

    $self->render( 'json' => $resp );
}

# импорт сохранённых настроек
# my $true = $self->export();
# 'title' - описание файла с настройками в базе
sub import {
    my $self = shift;

    my ( $result, $resp, $data, $error, $filename, $filepath, $json, $settings, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # получение имени файла экспортированной настройки
    unless ( @mess ) {
        $filename = $self->model('Settings')->_get_export_setting( $$data{'id'} );
        push @mess, "can't get filename with id '$$data{'id'}'" unless $filename;
    }

    # чтение файла
    unless ( @mess ) {
        # путь к файлу
        $filepath = $self->{'app'}->{'config'}->{'export_settings_path'} . '/' . $filename;
        # чтение файла
        $json = read_file( $filepath, {err_mode => 'silent'} );
        push @mess, "can't read '$filepath'" unless $json;
    }

    # декодирование данных из json
    unless ( @mess ) {
        $settings = decode_json( $json );
        push @mess, "Can't decode from json" unless $settings;
    }

    # загрузка экспортированных настроек
    unless ( @mess ) {
        # очистка текущей таблицы настроек
        $self->model('Settings')->_reset_settings();

        # импорт настроек
        $result = $self->model('Settings')->_import_setting( $settings );
        push @mess, "Can't import settings" unless $result;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

# удаление файла с экспортом и записи в таблице
sub del_export {
    my $self = shift;

    my ( $data, $error, $filename, $filepath, $cmd, $id, $resp, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless ( @mess ) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # получение имени файла экспортированной настройки
    unless ( @mess ) {
        $filename = $self->model('Settings')->_get_export_setting( $$data{'id'} );
        push @mess, "can't get filename with id '$$data{'id'}'" unless $filename;
    }

    # проверка существования файла
    unless ( @mess ) {
        # путь к файлу
        $filepath = $self->{'app'}->{'config'}->{'export_settings_path'} . '/' . $filename;
        push @mess, "'$filepath' doen't exist" unless ( $self->_exists_in_directory( $filepath ) );
    }
warn Dumper( $filepath );
    # удаление файла
    unless ( @mess ) {
        $cmd = `rm $filepath`;
        if ( $? ) {
            push @mess, "Can't delete $filepath, $?";
        }
    }

    # удаление записи из таблицы
    unless ( @mess ) {
        $id = $self->model('Settings')->_delete_export_setting( $id );
        push @mess, "Can't delete '$filename' file from DB" unless $id;
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @mess;

    $self->render( 'json' => $resp );
}
1;
