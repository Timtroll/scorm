package Freee::Model::Settings;

use Mojo::Base 'Freee::Model::Base';
use Mojo::JSON;
use JSON::XS;
use Encode qw( _utf8_off );

use Data::Dumper;
use common;

###################################################################
# таблица настроек
###################################################################

# получить дерево настроек
# my $true = $self->model('Settings')->_get_tree(1); - без листьев
# my $true = $self->get_tree();  - c листьями
sub _get_tree {
    my ( $self, $no_children ) = @_;

    my ( $list, $sql );
    if ( $no_children ) {
        $sql = 'SELECT id, label, name, parent, 1 as folder FROM "public"."settings" where id IN (SELECT DISTINCT parent FROM "public"."settings") OR parent=0 ORDER by id';
    }
    else {
        $sql = 'SELECT id, label, name, parent FROM "public"."settings" ORDER by id';
    }

    $list = $self->{app}->pg_dbh->selectall_arrayref( $sql, { Slice => {} } );

    $list = $self->{app}->_list_to_tree( $list, 'id', 'parent', 'children' );

    return $list;
}

# читаем фолдер
# my $row = $self->model('Settings')->_get_folder( 99 );
# возвращается строка в виде объекта
sub _get_folder {
    my ($self, $id) = @_;

    return unless $id;

    my ( $sql, $sth, $row );
    $sql = 'SELECT *, publish AS status FROM "public"."settings" WHERE "id" = :id';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $row = $sth->fetchrow_hashref();
    $sth->finish();

    # десериализуем поля vaue и selected
    if ($row) {
        $$row{'parent'}     = $$row{'parent'} // 0;
        $$row{'name'}       = $$row{'name'} ? $$row{'name'} : '';
        $$row{'label'}      = $$row{'label'} ? $$row{'label'} : '';
        $$row{'mask'}       = '';
        $$row{'placeholder'} = '';
        $$row{'readonly'}   = 0;
        $$row{'required'}   = 0;
        $$row{'type'}       = '';
        $$row{'value'}      = '';
        $$row{'selected'}   = '';
        $$row{'folder'}     = $$row{'folder'} // 0;
        $$row{'status'}     = $$row{'status'} // 0;
        delete $$row{'publish'};
    }
    
    return $row;
}

# добавление фолдера настроек
# my $row = $self->model('Settings')->_insert_folder({
#   'parent'  => 0,
#   'name':   => 'test23',
#   'label':  => 'цкцкцук',
# });
# возвращается объект
sub _insert_folder {
    my ($self, $data) = @_;

    return unless $data;

    my ( $sql, $sth, $id );

    if ( $$data{'id'} && ( $$data{'id'} == $$data{'parent'} ) ) {
        warn 'Id and Parent is equal.';
        return;
    }

    $sql ='INSERT INTO "public"."settings" ('.
        join( ',', map { '"'.$_.'"' } keys %$data ).
        ') VALUES ('.
        join( ',', map {
            # $$data{$_} =~/^\d+$/ ? ($$data{$_} + 0) : $self->pg_dbh->quote( $$data{$_} )
            if (length $$data{$_} && $$data{$_} =~ /^\d+$/) {
                ($$data{$_} + 0)
            }
            else {
                $$data{$_} ? $self->{app}->pg_dbh->quote( $$data{$_} ) : "''";
            }
        } keys %$data ).
        ') RETURNING "id"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $sth->finish();
    $id = $sth->last_insert_id( undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' } );
    $sth->finish();

    return $id;
}

# сохранить данные фолдера настроек
# my $true = $self->model('Settings')->_save_folder({
#   'id'      => 12,
#   'parent'  => 0,
#   'name':   => 'test23',
#   'label':  => 'цкцкцук'
# });
sub _save_folder {
    my ($self, $data) = @_;

    return unless $$data{'id'};

    my ( $fields, $sql, $sth );

    if ($$data{'id'} && ($$data{'id'} == $$data{'parent'})) {
        warn 'Id and Parent is equal.';
        return;
    }

    $fields = join( ', ', map {
        if (length $$data{$_} && $$data{$_} =~ /^\d+$/) {
            '"'.$_.'"='.($$data{$_} + 0);
        }
        else {
            $$data{$_} ? '"'.$_.'"='.$self->{app}->pg_dbh->quote( $$data{$_} ) : '"'.$_."\"=''";
        }
    } keys %$data );

    $sql = 'UPDATE "public"."settings" SET '.$fields.' WHERE "id" = :id';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $$data{'id'} );
    $sth->execute();
    $sth->finish();

    return $$data{'id'};
}

# выбираем листья ветки дерева по id парента
# my $true = $self->model('Settings')->_get_leafs( <id> );
sub _get_leafs {
    my ($self, $id) = @_;

    return unless defined $id;

    my ( $list, $sql, $sth );

    $sql = 'SELECT id, selected, type, label, required, folder, value, name, placeholder, mask, parent, readonly, publish AS status FROM "public"."settings" WHERE "parent" = :id ORDER by id';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $list = $sth->fetchall_arrayref({});
    $sth->finish();

    return $list;
}

# создание настройки
# my $id = $self->model('Settings')->_insert_setting({
#     "parent",   - обязательно
#     "label",    - обязательно
#     "name",     - обязательно
#     "value",
#     "type",
#     "placeholder",
#     "mask"
#     "selected",
# });
# создание группы настроек
# my $id = $self->model('Settings')->_insert_setting({
#     "parent",   - обязательно (если корень - 0, или owner id),
#     "label",    - обязательно
#     "readonly", - не обязательно, по умолчанию 0
# });
sub _insert_setting {
    my ($self, $data) = @_;

    return unless $data;

    my ( $id, $sql, $sth );

    # сериализуем поля vaue и selected
    if (defined $$data{'value'} ) {
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
    }
    if (defined $$data{'selected'} ) {
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');
    }

    $sql ='INSERT INTO "public"."settings" ('.
        join( ',', map { '"'.$_.'"' } keys %$data ).
        ') VALUES ('.
        join( ',', map {
            if (length $$data{$_} && $$data{$_} =~ /^\d+$/) {
                ($$data{$_} + 0)
            }
            else {
                $$data{$_} ? $self->{app}->pg_dbh->quote( $$data{$_} ) : "''";
            }
        } keys %$data ).
        ') RETURNING "id"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $sth->finish();
    $id = $sth->last_insert_id( undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' } );
    $sth->finish();

    return $id;
}

# сохранение настройки
# my $id = $self->model('Settings')->_save_setting({
#     "id",       - обязательно (должно быть больше 0)
#     "parent",   - обязательно (должно быть больше 0)
#     "label",    - обязательно
#     "name",     - обязательно
#     "value",
#     "type",
#     "placeholder",
#     "mask"
#     "selected",
# });
# сохранение группы настроек
# my $id = $self->model('Settings')->_save_setting({
#     "id",       - обязательно (должно быть больше 0),
#     "parent",   - обязательно (если корень - 0, или owner id),
#     "label",    - обязательно
#     "name",     - обязательно
#     "readonly", - не обязательно, по умолчанию 0
# });
# возвращается id записи
sub _save_setting {
    my ($self, $data) = @_;

    return unless $data;
    return unless $$data{'id'};

    my ( $fields, $sql, $sth );

    # сериализуем поля vaue и selected
    if (defined $$data{'value'} ) {
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
    }
    if (defined $$data{'selected'} ) {
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');
    }

    $fields = join( ', ', map {
        $$data{$_} =~ /^\d+$/ ? '"'.$_.'"='.($$data{$_} + 0) : '"'.$_.'"='.$self->{app}->pg_dbh->quote( $$data{$_} )
    } keys %$data );

    $sql = 'UPDATE "public"."settings" SET '.$fields.' WHERE "id"= :id';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $$data{'id'} );
    $sth->execute();
    $sth->finish();

    return $$data{'id'};
}


# удаление настройки
# my $true = $self->model('Settings')->_delete_setting( <id> );
# возвращается true/false
sub _delete_setting {
    my ($self, $id) = @_;
    return unless $id;

    my ( $result, $sql, $sth );

    $sql = 'DELETE FROM "public"."settings" WHERE "id" = :id';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $result = $sth->execute();
    $sth->finish();

    return $result + 0;
}

# читаем одну настройку
# my $row = $self->model('Settings')->_get_setting( <id> );
# возвращается строка в виде объекта
sub _get_setting {
    my ( $self, $id ) = @_;

    return unless $id;

    my ( $result, $row, $sql, $sth );

    $sql = 'SELECT * FROM "public"."settings" WHERE "id" = :id';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $row = $sth->fetchrow_hashref();
    $sth->finish();

    # десериализуем поля vaue и selected
    if ( $row ) {
        $$result{'parent'} = $$row{'parent'} // 0,
        $$result{'folder'} = 0,
        $$result{'id'} = $$row{'id'},
        $$result{'tabs'} = [
            {
                "label" => "Основные",
                "fields" => [
                    { "label"       => $$row{'label'} ? $$row{'label'} : '' },
                    { "name"        => $$row{'name'} ? $$row{'name'} : '' },
                    { "placeholder" => $$row{'placeholder'} ? $$row{'placeholder'} : '' },
                    { "selected"    => $$row{'selected'} ? JSON::XS->new->allow_nonref->decode($$row{'selected'}) : [] },
                    { "type"        => $$row{'type'} ? $$row{'type'} : '' },
                    { "value"       => $$row{'value'} =~ /^\[/ ? JSON::XS->new->allow_nonref->decode($$row{'value'}) : $$row{'value'} }
                ]
            },
            {
                "label" => "Дополнительно",
                "fields" => [
                    { "mask"        => $$row{'mask'} ? $$row{'mask'} : '' },
                    { "readonly"    => $$row{'readonly'} // 0 },
                    { "required"    => $$row{'required'} // 0 },
                    { "placeholder" => $$row{'placeholder'} ? $$row{'placeholder'} : '' },
                    { "status"      => $$row{'publish'} // 0 }
                ]
            }
        ]
    }
    
    return $result;
}

# ?????????????????? не используется?
# получение списка настроек из базы в виде объекта как в Mock/Settings.pm
# my $row = $self->model('Settings')->_all_settings();
sub _all_settings {
    my $self = shift;

    my $sql = 'SELECT * FROM "public"."settings" ORDER by id';

    my $list = $self->{app}->pg_dbh->selectall_arrayref( $sql, { Slice=> {} } );

    $list = $self->{app}->_list_to_tree($list, 'id', 'parent', 'children');

    return $list;
}

# создание объекта с настройками конфигурации
# my ( $object, $error ) = $self->model('Settings')->_get_config();
sub _get_config {
    my $self = shift;

    my ( $sql, $sth, $result, $set );

    # получение настроек из бд
    $sql = 'SELECT "name", "value" FROM "public"."settings" WHERE "folder" = 0';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $result = $sth->fetchall_arrayref();
    $sth->finish();

    # создание хэша настроек
    foreach my $setting ( @$result ) {
        if ( $$setting[1] && $$setting[1] =~ /^[\[\{].*[\]\}]$/ ) {
            # выключение флага utf8
            _utf8_off( $$setting[1] );

            my ( $flag, $val, $value, @tmp, %hash);
            # преобразование из json
            $value = decode_json $$setting[ 1 ];
            map {
                # объект является массивом
                if ( ref($_) eq 'ARRAY') {
                    # в массиве больше 1 эл-та
                    if ( scalar( @$_> 1 ) ) {
                        $hash{ $$_[1] } = $$_[0]; 
                        $flag++;
                    }
                    else {
                        push @tmp, $$_[0];
                    }
                }
                else {
                    push @tmp, $_;
                }
            } @$value;

            # присвоение значения
            $val = \@tmp;
            $val = \%hash if $flag;
            $$set{ $$setting[ 0 ] } = $val;
        }
        else {
            $$set{ $$setting[ 0 ] } = $$setting[ 1 ];
        }
    }
    $settings = $set;
}

# очистка дефолтных настроек
# my $true = $self->model('Settings')->_reset_settings();
sub _reset_settings {
    my $self = shift;

    my $sql = 'TRUNCATE "public"."settings" RESTART IDENTITY';
    $self->{app}->pg_dbh->do($sql);

    $sql = 'ALTER SEQUENCE settings_id_seq RESTART';
    $self->{app}->pg_dbh->do($sql);

    return 1;
}

# получение всех настроек
# my $hash = $self->model('Settings')->_get_all_settings();
sub _get_all_settings {
    my ( $self ) = @_;

    my ( $sql, $sth, $result );

    $sql = 'SELECT * FROM "public"."settings"';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $result = $sth->fetchall_hashref("id");
    $sth->finish();

    return $result;
}

# запись данных о файле с настройками
# my $id = $self->model('Settings')->_insert_export_setting( $title, $filename, $time );
sub _insert_export_setting {
    my ( $self, $title, $filename, $time ) = @_;

    my ( $sql, $sth, $id );

    return unless( $title && $filename && $time );

    $sql = 'INSERT INTO "public"."export_settings" ("title", "filename", "time_create") VALUES (:title, :filename, :time_create) RETURNING "id"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':title', $title );
    $sth->bind_param( ':filename', $filename );
    $sth->bind_param( ':time_create', $time );
    $sth->execute();
    $sth->finish();

    $id = $sth->last_insert_id( undef, 'public', 'export_settings', undef, { sequence => 'export_settings_id_seq' } );
    $sth->finish();

    return $id;
}

# получение имени файла экспортированной настройки
# my $filename = $self->model('Settings')->_get_export_setting( $id );
sub _get_export_setting {
    my ( $self, $id ) = @_;

    my ( $sql, $sth, $result );

    return unless( $id );

    $sql = 'SELECT filename FROM "public"."export_settings" WHERE id = :id';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $result = $sth->fetchrow_hashref();
    $sth->finish();

    return $$result{'filename'};
}

# загрузка экспортированных настроек
# my $true = $self->model('Settings')->_import_setting( $data );
sub _import_setting {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    return unless( $data );

    $sql = 'INSERT INTO "public"."settings" ("parent", "name", "label", "placeholder", "type", "mask", "value", "selected", "required", "readonly", "publish", "folder") VALUES (:parent, :name, :label, :placeholder, :type, :mask, :value, :selected, :required, :readonly, :publish, :folder)';

    foreach my $row ( sort {$a->{'id'} <=> $b->{'id'}} @$data ) {
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':parent', $$row{'parent'} );
        $sth->bind_param( ':name', $$row{'name'} );
        $sth->bind_param( ':label', $$row{'label'} );
        $sth->bind_param( ':placeholder', $$row{'placeholder'} );
        $sth->bind_param( ':type', $$row{'type'} );
        $sth->bind_param( ':mask', $$row{'mask'} );
        $sth->bind_param( ':value', $$row{'value'} );
        $sth->bind_param( ':selected', $$row{'selected'} );
        $sth->bind_param( ':required', $$row{'required'} );
        $sth->bind_param( ':readonly', $$row{'readonly'} );
        $sth->bind_param( ':publish', $$row{'publish'} );
        $sth->bind_param( ':folder', $$row{'folder'} );
        $result = $sth->execute();
        $sth->finish();
        return unless $result;
    }

    return 1;
}

# удаление записи об экспорт файле из бд
# ( $id ) = $self->model('Upload')->_delete_export_setting( $id );
sub _delete_export_setting {
    my ( $self, $id ) = @_;

    my ( $result, $sth, $sql );

    # проверка входных данных
    unless ( $id ) {
        return;
    }
    else {
        # удаление записи о файле
        $sql = 'DELETE FROM "public"."export_settings" WHERE "id" = :id returning "id"';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $id );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();

        return $$result{'id'};
    }
}

# получение списка экспортированных настроек
sub _get_list_exports {
    my $self = shift;

    my ( $sql, $sth, $list );

    $sql = 'SELECT * FROM "public"."export_settings"';
    $sth = $self->{'app'}->pg_dbh->prepare( $sql );
    $sth->execute();
    $list = $sth->fetchall_hashref("id");
    $sth->finish();

    return $list;
}
1;