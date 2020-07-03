package Freee::Model::Settings;

use Mojo::Base 'Freee::Model::Base';
use Mojo::JSON;
use JSON::XS;
use Encode qw( _utf8_off );

use Data::Dumper;

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
        $sql = 'SELECT id, label, name, parent, 1 as folder FROM "public".settings where id IN (SELECT DISTINCT parent FROM "public".settings) OR parent=0 ORDER by id';
    }
    else {
        $sql = 'SELECT id, label, name, parent FROM "public".settings ORDER by id';
    }

    $list = $self->{app}->pg_dbh->selectall_arrayref( $sql, { Slice => {} } );

    $list = $self->{app}->_list_to_tree( $list, 'id', 'parent', 'children' );

    return $list;

    # return $self->app->config;
}

# читаем фолдер
# my $row = $self->model('Settings')->_get_folder( 99 );
# возвращается строка в виде объекта
sub _get_folder {
    my ($self, $id) = @_;

    return unless $id;

    my $sql = 'SELECT * FROM "public"."settings" WHERE "id"='.$id;
    my $row;

    $row = $self->{app}->pg_dbh->selectrow_hashref($sql);

    # десериализуем поля vaue и selected
    my $out = [];
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

    if ($$data{'id'} && ($$data{'id'} == $$data{'parent'})) {
        warn 'Id and Parent is equal.';
        return;
    }

    my $sql ='INSERT INTO "public"."settings" ('.
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

    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $id = $sth->last_insert_id( undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' } );

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
    if ($$data{'id'} && ($$data{'id'} == $$data{'parent'})) {
        warn 'Id and Parent is equal.';
        return;
    }

    my $fields = join( ', ', map {
        if (length $$data{$_} && $$data{$_} =~ /^\d+$/) {
            '"'.$_.'"='.($$data{$_} + 0);
        }
        else {
            $$data{$_} ? '"'.$_.'"='.$self->{app}->pg_dbh->quote( $$data{$_} ) : '"'.$_."\"=''";
        }
    } keys %$data );

    $self->{app}->pg_dbh->do( 'UPDATE "public"."settings" SET '.$fields." WHERE \"id\"=".$$data{id} );

    return 1;
}

# выбираем листья ветки дерева по id парента
# my $true = $self->model('Settings')->_get_leafs( <id> );
sub _get_leafs {
    my ($self, $id) = @_;

    return unless defined $id;

    my $sql = 'SELECT * FROM "public".settings WHERE "parent"='.$id.' ORDER by id';

    my $list;
    $list = $self->{app}->pg_dbh->selectall_arrayref( $sql, { Slice=> {} } );

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

    # сериализуем поля vaue и selected
    if (defined $$data{'value'} ) {
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
    }
    if (defined $$data{'selected'} ) {
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');
    }

    my $sql ='INSERT INTO "public"."settings" ('.
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

    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $id = $sth->last_insert_id( undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' } );

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

    # сериализуем поля vaue и selected
    if (defined $$data{'value'} ) {
        $$data{'value'} = JSON::XS->new->allow_nonref->encode($$data{'value'}) if (ref($$data{'value'}) eq 'ARRAY');
    }
    if (defined $$data{'selected'} ) {
        $$data{'selected'} = JSON::XS->new->allow_nonref->encode($$data{'selected'}) if (ref($$data{'selected'}) eq 'ARRAY');
    }

    my $fields = join( ', ', map {
        $$data{$_} =~ /^\d+$/ ? '"'.$_.'"='.($$data{$_} + 0) : '"'.$_.'"='.$self->{app}->pg_dbh->quote( $$data{$_} )
    } keys %$data );

    my $sql = 'UPDATE "public"."settings" SET '.$fields." WHERE \"id\"=".$$data{'id'};

    $self->{app}->pg_dbh->do($sql);

    return $$data{'id'};
}


# удаление настройки
# my $true = $self->model('Settings')->_delete_setting( <id> );
# возвращается true/false
sub _delete_setting {
    my ($self, $id) = @_;
    return unless $id;

    my $result;
    my $sql = 'DELETE FROM "public"."settings" WHERE "id"='.$id;

    $result = $self->{app}->pg_dbh->do($sql) + 0;

    return $result;
}

# читаем одну настройку
# my $row = $self->model('Settings')->_get_setting( <id> );
# возвращается строка в виде объекта
sub _get_setting {
    my ( $self, $id ) = @_;

    return unless $id;

    my $sql = 'SELECT * FROM "public"."settings" WHERE "id"='.$id;
    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $row = $sth->fetchrow_hashref();

    # десериализуем поля vaue и selected
    my $out = [];
    if ( $row ) {
        $$row{'label'}       = $$row{'label'} ? $$row{'label'} : '';
        $$row{'mask'}        = $$row{'mask'} ? $$row{'mask'} : '';
        $$row{'name'}        = $$row{'name'} ? $$row{'name'} : '';
        $$row{'parent'}      = $$row{'parent'} // 0;
        $$row{'placeholder'} = $$row{'placeholder'} ? $$row{'placeholder'} : '';
        $$row{'readonly'}    = $$row{'readonly'} // 0;
        $$row{'required'}    = $$row{'required'} // 0;
        $$row{'type'}        = $$row{'type'} ? $$row{'type'} : '';
        if ($$row{'value'}) {
            $$row{'value'} = $$row{'value'} =~ /^\[/ ? JSON::XS->new->allow_nonref->decode($$row{'value'}) : $$row{'value'};
        }
        else {
            $$row{'value'} = '';
        }
        $$row{'selected'}  = $$row{'selected'} ? JSON::XS->new->allow_nonref->decode($$row{'selected'}) : [] ;
        $$row{'status'}    = $$row{'status'} // 0;
    }
    
    return $row;
}

# ?????????????????? не используется?
# получение списка настроек из базы в виде объекта как в Mock/Settings.pm
# my $row = $self->model('Settings')->_all_settings();
sub _all_settings {
    my $self = shift;

    my $sql = 'SELECT * FROM "public".settings ORDER by id';

    my $list;
    $list = $self->{app}->pg_dbh->selectall_arrayref( $sql, { Slice=> {} } );

    $list = $self->{app}->_list_to_tree($list, 'id', 'parent', 'children');

    return $list;
}

# создание объекта с настройками конфигурации
# my ( $object, $error ) = $self->model('Settings')->_get_config();
sub _get_config {
    my $self = shift;

    my ( $sql, $sth, $result, $settings );

    # получение настроек из бд
    $sql = 'SELECT "name", "value" FROM "public".settings WHERE "folder" = 0';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $result = $sth->fetchall_arrayref();

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
            $$settings{ $$setting[ 0 ] } = $val;
        }
        else {
            $$settings{ $$setting[ 0 ] } = $$setting[ 1 ];
        }
    }
    $self->{app}->{'settings'} = $settings;
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

1;