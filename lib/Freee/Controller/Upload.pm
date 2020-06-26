package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Mojo::JSON qw( encode_json );
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my ( $data, $error, $result, $filename, $resp, $url, $json, $local_path, $extension, $write_result, $name_length, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # store real file name
        $$data{'title'} = $$data{'filename'};

        # генерация случайного имени
        $name_length = $self->{'app'}->{'settings'}->{'upload_name_length'};
        $$data{'filename'} = $self->_random_string( $name_length );
        while ( $self->_exists_in_directory( './upload/'.$$data{'filename'} ) ) {
            $$data{'filename'} = $self->_random_string( $name_length );
        }

        # путь файла
        $$data{'path'} = 'local';

        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

        # получение mime
        $$data{'mime'} = $$mime{$$data{'extension'}} || '';

        # запись файла
        $result = write_file(
            $self->{'app'}->{'settings'}->{'upload_local_path'} . $$data{'filename'} . '.' . $$data{'extension'},
            $$data{'content'}
        );
        push @mess, "Can not store '$$data{'filename'}' file" unless $result;
    }

    # ввод данных в таблицу
    unless ( @mess ) {
        ( $result, $error ) = $self->model('Upload')->_insert_media( $data );
        push @mess, $error unless $result;
    }

    # преобразование данныхв json
    unless ( @mess ) {
        delete $$data{'content'};
        $json = encode_json ( $data );
        push @mess, "Can not convert into json $$data{'title'}" unless $json;
    }

    # создание файла с описанием
    unless ( @mess ) {
        $local_path = $self->{'app'}->{'settings'}->{'upload_local_path'};
        $extension = $self->{'app'}->{'settings'}->{'desc_extension'};
        $write_result = write_file( $local_path . $$data{'filename'} . '.' . $extension, $json );
        push @mess, "Can not write desc of $$data{'title'}" unless $write_result;
    }

    # получение url
    unless ( @mess ) {
        $url = $self->{'app'}->{'settings'}->{'site_url'} . $self->{'app'}->{'settings'}->{'upload_url_path'} . $$data{'filename'} . '.' . $$data{ 'extension' };
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'id'} = $result if $result;
    $resp->{'mime'} = $$data{'mime'} if $result;
    $resp->{'url'} = $url if $url;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my ( $data, $fileinfo, $error, $result, $resp, $filename, $cmd, $local_path, $full_path, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # получение данных об удаляемом файле из базы данных
    unless ( @mess ) {
        ( $fileinfo, $error ) = $self->model('Upload')->_check_media( $$data{'id'} );
        push @mess, $error if $error;
    }

    # удаление файла
    unless ( @mess ) {
        $filename = $$fileinfo{'filename'} . '.' . $$fileinfo{'extension'};
        $local_path = $self->{'app'}->{'settings'}->{'upload_local_path'};
        $full_path = $local_path . $filename;
        if ( $self->_exists_in_directory( $full_path ) ) {
            $cmd = `rm $full_path`;
            if ( $? ) {
                push @mess, "Can not delete $full_path, $?";
            }
        }
    }

    # удаление описания файла
    unless ( @mess ) {
        $filename = $$fileinfo{'filename'} . '.' . 'desc';
        $full_path = $local_path . $filename;
        if ( $self->_exists_in_directory( $full_path ) ) {
            $cmd = `rm $full_path`;
            if ( $? ) {
                push @mess, "Can not delete $full_path description, $?";
            }
        }
    }

    # удаление записи о файле
    unless ( @mess ) {
        ( $data, $error ) = $self->model('Upload')->_delete_media( $$data{'id'} );
        push @mess, $error if $error;
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

sub search {
    my $self = shift;

    my ( $data, $error, $resp, $url, $host, $url_path, @data, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    # получение записи
    unless ( @mess ) {
        ( $data, $error ) = $self->model('Upload')->_get_media( $data );
        push @mess, $error if $error;
    }

    # добавление данных об url
    unless ( @mess ) {
        $host = $self->{'app'}->{'settings'}->{'site_url'};
        $url_path = $self->{'app'}->{'settings'}->{'upload_url_path'};
        foreach my $row ( values %{$data} ) {
            $url = $host . $url_path . $$row{'filename'} . '.' . $$row{'extension'};
            delete @{$row}{'filename', 'extension'};
            push @data, { %$row, 'url' => $url };
        }
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'status'} = @mess ? 'warn' : 'ok';
    $resp->{'data'} = \@data unless @mess;
    $self->render( 'json' => $resp );
}

sub update {
    my $self = shift;

    my ( $data, $error, $url, $resp, $host, $local_path, $url_path, $desc_extension, $json, $rewrite_result, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @mess ) {
        ( $data, $error ) = $self->_check_fields();
        push @mess, $error if $error;
    }

    unless ( @mess ) {
        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

        # обновление записи
        ( $data, $error ) = $self->model('Upload')->_update_media( $data );
        push @mess, $error if $error;
    }

    # преобразование данных в json
    unless ( @mess ) {
        $json = encode_json ( $data );
        push @mess, "Can not convert into json $$data{'title'}" unless $json;
    }

    # запись нового файла с описанием
    $host = $self->{'app'}->{'settings'}->{'site_url'};
    $local_path = $self->{'app'}->{'settings'}->{'upload_local_path'};
    $url_path = $self->{'app'}->{'settings'}->{'upload_url_path'};
    $desc_extension = $self->{'app'}->{'settings'}->{'desc_extension'};
    unless ( @mess ) {
        $rewrite_result = write_file( $local_path . $$data{'filename'} . '.' . $desc_extension, $json );
        push @mess, "Can not update description of $$data{'title'}" unless $rewrite_result;
    }

    unless ( @mess ) {
        $url = $host . $url_path . $$data{'filename'} . '.' . $$data{'extension'};
    }

    $resp->{'message'} = join( "\n", @mess ) if @mess;
    $resp->{'id'} = $$data{'id'} unless @mess;
    $resp->{'mime'} = $$data{'mime'} unless @mess;
    $resp->{'url'} = $url unless @mess;
    $resp->{'status'} = @mess ? 'fail' : 'ok';

    $self->render( 'json' => $resp );
}

1;