package Freee::Helpers::PgSettings;

use strict;
use warnings;
use utf8;

use base 'Mojolicious::Plugin';
use JSON::XS;

use DBD::Pg;
use DBI;
use Encode qw( _utf8_off );
use Mojo::JSON; # qw( decode_json );

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    ###################################################################
    # таблица настроек
    ###################################################################

    # читаем одну настройку
    # my $row = $self->_get_folder( 99 );
    # возвращается строка в виде объекта
    $app->helper( '_get_folder' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT * FROM "public"."settings" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

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
    });

    # добавление фолдера настроек
    # my $row = $self->_insert_folder({
    #   'parent'  => 0,
    #   'name':   => 'test23',
    #   'label':  => 'цкцкцук',
    # });
    # возвращается объект
    $app->helper( '_insert_folder' => sub {
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
                    $$data{$_} ? $self->pg_dbh->quote( $$data{$_} ) : "''";
                }
            } keys %$data ).
            ') RETURNING "id"';

        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ if $@;
        return if $@;


        my $id = $self->pg_dbh->last_insert_id(undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' });

        return $id;
    });

    # сохранить данные фолдера настроек
    # my $true = $self->_save_folder({
    #   'id'      => 12,
    #   'parent'  => 0,
    #   'name':   => 'test23',
    #   'label':  => 'цкцкцук'
    # });
    $app->helper( '_save_folder' => sub {
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
                    $$data{$_} ? '"'.$_.'"='.$self->pg_dbh->quote( $$data{$_} ) : '"'.$_."\"=''";
                }
        } keys %$data );

        eval {
            $self->pg_dbh->do( 'UPDATE "public"."settings" SET '.$fields." WHERE \"id\"=".$$data{id} );
        };
        warn $@ if $@;
        return if $@;

        return 1;
    });

    # выбираем листья ветки дерева по id парента
    # my $true = $self->_get_leafs( <id> );
    $app->helper( '_get_leafs' => sub {
        my ($self, $id) = @_;

        return unless defined $id;

        my $sql = 'SELECT * FROM "public".settings WHERE "parent"='.$id.' ORDER by id';
        my $list;
        eval {
            $list = $self->pg_dbh->selectall_arrayref( $sql, { Slice=> {} } );
        };
        warn $@ if $@;
        return if $@;

        return $list;
    });

    # создание настройки
    # my $id = $self->_insert_setting({
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
    # my $id = $self->_insert_setting({
    #     "parent",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "readonly", - не обязательно, по умолчанию 0
    # });
    $app->helper( '_insert_setting' => sub {
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
                    $$data{$_} ? $self->pg_dbh->quote( $$data{$_} ) : "''";
                }
            } keys %$data ).
            ') RETURNING "id"';

        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ if $@;
        return if $@;

        my $id = $self->pg_dbh->last_insert_id(undef, 'public', 'settings', undef, { sequence => 'settings_id_seq' });

        return $id;
    });

    # сохранение настройки
    # my $id = $self->_save_setting({
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
    # my $id = $self->_save_setting({
    #     "id",       - обязательно (должно быть больше 0),
    #     "parent",   - обязательно (если корень - 0, или owner id),
    #     "label",    - обязательно
    #     "name",     - обязательно
    #     "readonly", - не обязательно, по умолчанию 0
    # });
    # возвращается id записи
    $app->helper( '_save_setting' => sub {
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
            $$data{$_} =~ /^\d+$/ ? '"'.$_.'"='.($$data{$_} + 0) : '"'.$_.'"='.$self->pg_dbh->quote( $$data{$_} )
        } keys %$data );

        my $sql = 'UPDATE "public"."settings" SET '.$fields." WHERE \"id\"=".$$data{'id'};

        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ if $@;
        return if $@;

        return $$data{'id'};
    });

    # удаление настройки
    # my $true = $self->_delete_setting( <id> );
    # возвращается true/false
    $app->helper( '_delete_setting' => sub {
        my ($self, $id) = @_;
        return unless $id;

        my $result;
        my $sql = 'DELETE FROM "public"."settings" WHERE "id"='.$id;
        eval {
            $result = $self->pg_dbh->do($sql) + 0;
        };
        warn $@ if $@;
        return if $@;

        return $result;
    });

    # читаем одну настройку
    # my $row = $self->_get_setting( <id> );
    # возвращается строка в виде объекта
    $app->helper( '_get_setting' => sub {
        my ($self, $id) = @_;

        return unless $id;

        my $sql = 'SELECT * FROM "public"."settings" WHERE "id"='.$id;
        my $row;
        eval {
            $row = $self->pg_dbh->selectrow_hashref($sql);
        };
        warn $@ if $@;
        return if $@;

        # десериализуем поля vaue и selected
        my $out = [];
        if ($row) {
            $$row{'label'}      = $$row{'label'} ? $$row{'label'} : '';
            $$row{'mask'}       = $$row{'mask'} ? $$row{'mask'} : '';
            $$row{'name'}       = $$row{'name'} ? $$row{'name'} : '';
            $$row{'parent'}     = $$row{'parent'} // 0;
            $$row{'placeholder'} = $$row{'placeholder'} ? $$row{'placeholder'} : '';
            $$row{'readonly'}   = $$row{'readonly'} // 0;
            $$row{'required'}   = $$row{'required'} // 0;
            $$row{'type'}       = $$row{'type'} ? $$row{'type'} : '';
            if ($$row{'value'}) {
                $$row{'value'} = $$row{'value'} =~ /^\[/ ? JSON::XS->new->allow_nonref->decode($$row{'value'}) : $$row{'value'};
            }
            else {
                $$row{'value'} = '';
            }
            $$row{'selected'}   = $$row{'selected'} ? JSON::XS->new->allow_nonref->decode($$row{'selected'}) : [] ;
            $$row{'status'}     = $$row{'status'} // 0;
        }
        
        return $row;
    });

    # очистка дефолтных настроек
    # my $true = $self->_reset_settings();
    $app->helper( '_reset_settings' => sub {
        my $self = shift;

        my $sql = 'TRUNCATE "public"."settings" RESTART IDENTITY';
        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ if $@;
        return if $@;

        $sql = 'ALTER SEQUENCE settings_id_seq RESTART';
        eval {
            $self->pg_dbh->do($sql);
        };
        warn $@ if $@;
        return if $@;

        return 1;
    });

    # получение списка настроек из базы в виде объекта как в Mock/Settings.pm
    $app->helper( '_all_settings' => sub {
        my $self = shift;

        my $sql = 'SELECT * FROM "public".settings ORDER by id';
        my $list;
        eval {
            $list = $self->pg_dbh->selectall_arrayref( $sql, { Slice=> {} } );
        };
        warn $@ if $@;
        return if $@;

        $list = $self->_list_to_tree($list, 'id', 'parent', 'children');

        return $list;
    });

    # создание объекта с настройками конфигурации
    # my ( $object, $error ) = $self->_get_config();
    $app->helper( '_get_config' => sub {
        my $self = shift;

        my ( $sql, $sth, $result, $settings );

        # получение настроек из бд
        $sql = 'SELECT "name", "value" FROM "public".settings WHERE "folder" = 0';
        $sth = $self->pg_dbh->prepare( $sql );
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
        $self->{'settings'} = $settings;
    });
}
1;