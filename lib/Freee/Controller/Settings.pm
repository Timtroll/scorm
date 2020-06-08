package Freee::Controller::Settings;

use utf8;
use Encode;

use Mojo::Base 'Mojolicious::Controller';
use JSON::XS;
use Encode;

use Freee::Mock::Settings;
use Data::Dumper;
use common;

#####################
# Работа с фолдерами

# получить данные фолдера
sub get_folder {
    my $self = shift;

    my ($resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_folder( $self->param('id') );
            push @mess, "Could not get '".$self->param('id')."'" unless $data;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

# получить дерево без листьев
sub get_tree {
    my $self = shift;

    # передаем 1, чтобы получить дерево без листьев
    my $list = $self->_get_tree(1);

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless $list;
    $resp->{'status'} = $list ? 'ok' : 'fail';
    $resp->{'list'} = $list if $list;

    $self->render( 'json' => $resp );
}

sub save_folder {
    my $self = shift;

    my ($id, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

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

            $id = $self->_save_folder( $data ) unless @mess;
            push @mess, "Could not save folder item '$$data{'id'}'" unless ( $id || @mess );
        }
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
# }
sub add_folder {
    my $self = shift;

    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            # проверяем поле name на дубликат
            if ($self->_exists_in_table('settings', 'name', $$data{'name'})) {
                push @mess, "Folder item named '$$data{'name'}' is exists";
            }
            else {
                unless ( $$data{'parent'} ) {
                    # устанавляваем обязательные поля для фолдера
                    $$data{'parent'} = 0;
                    $$data{'placeholder'} = '';
                    $$data{'type'} = '';
                    $$data{'mask'} = '';
                    $$data{'value'} = '';
                    $$data{'selected'} = '';
                    $$data{'required'} = 0;
                    $$data{'readonly'} = 0;
                    $$data{'status'} = 1;
                    $$data{'folder'} = 1;

                    $id = $self->_insert_folder( $data );
                    push @mess, "Could not create new folder item '$$data{'id'}'" unless $id;
                }
                else {
                    push @mess, "Parent '$$data{'parent'}' is wrong";
                }
            }
        }
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
# 'id' - id фолдера для которого выбираем листья (id = 0 - выбираем корневые записи)
sub get_leafs {
    my $self = shift;

    my ($resp, $list, $table, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            if ( ( $$data{'id'} == 0 ) || ( $self->_exists_in_table('settings', 'id', $$data{'id'} ) ) )  {
                $list = $self->_get_leafs( $$data{'id'} );
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
                          "per_page"        => 100,
                          "total"           => scalar(@$list)
                        }
                    },
                    "body" => $list
                } unless @mess;
            } else {
                push @mess, "Setting id '$$data{'id'}' not exists";
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

    my ( $sth, $res, $id, $sub, $resp, $create_script, @mess);

    # очистка таблицы и сброс счетчика
    $self->_reset_settings();

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
        $id = $self->_insert_folder($sub, []);
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

                my $chldid = $self->_insert_setting($sub, []);
                push @mess, "Could not add setting item '$$children{'label'}' in Folder '$$children{'label'}'" unless $chldid;
            }
        }
    }

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
        ($data, $error) = $self->_check_fields();
        # push @mess, $error unless $data;

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
            unless ( defined $$data{'status'} )      { $$data{'status'}      = 0 };

            # проверяем поле name на дубликат
            if ($self->_exists_in_table('settings', 'name', $$data{'name'})) {
                push @mess, "Setting named '$$data{'name'}' is exists";
            }
            else {
                $id = $self->_insert_setting( $data, [] );
                push @mess, "Could not create new setting item '$$data{'id'}'" unless $id;
            }
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

# получение настройки по id
# my $row = $self->edit()
# 'id' - id настрокйи
sub edit {
    my $self = shift;

    my ($id, $data, $error, @mess, $resp);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        if ($data) {
            $data = $self->_get_setting( $$data{'id'} );
            push @mess, "Could not get '".$$data{'id'}."'" unless $data;
            $data = {
                "folder" => $data->{'folder'},
                "id"     => $data->{'id'},
                "parent" => $data->{'parent'},
                "tabs" => [
                    {
                        "label" => "Основное",
                        "fields" => [
                            { "name"          => $data->{'name'} },
                            { "placeholder"   => $data->{'placeholder'} },
                            { "readonly"      => $data->{'readonly'} },
                            { "required"      => $data->{'required'} },
                            { "status"        => $data->{'status'} }
                        ]
                    },
                    {
                        "label" => 'Дополнительные поля',
                        "fields" => [
                            { "label"       => "шаг обновления" },
                            { "mask"        => $data->{'mask'} },
                            { "selected"    => $data->{'selected'} },
                            { "type"        => $data->{'type'} },
                            { "value"       => $data->{'value'} }
                        ]
                    }
                ]
            };
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'data'} = $data if $data;

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
    my ($id, $data, $error, $resp, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

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
            unless ( defined $$data{'status'} )      { $$data{'status'}      = 0 };
            
            # проверяем поле name на дубликат
            unless (@mess) {
                if ($self->_exists_in_table('settings', 'name', $$data{'name'}, $$data{'id'})) {
                    push @mess, "Setting named '$$data{'name'}' is exists";
                }
                else {
                    $id = $self->_save_setting( $data, [] ) unless @mess;
                    push @mess, "Could not update setting item '$$data{'id'}'" unless $id;
                }
            }
        }
    }

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

    my ($del, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        $del = $self->_delete_setting( $$data{'id'} ) unless @mess;
        push @mess, "Could not delete '$$data{'id'}'" unless ( $del || @mess );
    }

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

    my ($toggle, $resp, $data, $error, @mess);
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{$$vfields{$self->url_for}};

    unless (@mess) {
        # проверка данных
        ($data, $error) = $self->_check_fields();
        push @mess, $error unless $data;

        unless (@mess) {
            $$data{'table'} = 'settings';
            $toggle = $self->_toggle( $data ) unless @mess;
            push @mess, "Could not toggle '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @mess) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} if $toggle;

    $self->render( 'json' => $resp );
}

1;
