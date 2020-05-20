package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Data::Dumper;
use common;

sub index {
    my ( $self, $file, $filename, $extension, $path, $coincidence, $new_filename, $name_length, $content, $result, @list );
    $self = shift;

    $file = $self->param('upload');

    # валидация?
    # unless (
    #     $file &&
    #     $file->{'headers'} &&
    #     $file->{'headers'}->{'headers'} &&
    #     $file->{'headers'}->{'headers'}->{'content-disposition'} &&
    #     $file->{'headers'}->{'headers'}->{'content-disposition'}->[0]
    # ) {
    #     warn'wrong upload file!';
    #     exit;
    # }

    # получение расширения
    $extension = $file->{'headers'}->{'headers'}->{'content-disposition'}->[0];
    $extension =~ s/^.*filename=".*\.//;
    $extension =~ s/".*$//;
    $extension = "\L$extension";

    ############### проверка расширения

    $path = './upload/';

    # чтение файлов директории скриптов
    @list = `ls $path 2>&1`;
    if ( $? ) {
        warn( "can't read directory $path" ); 
        exit; 
    };

    $name_length = 48;

    do {
        $coincidence = 0;

        # генерация случайного имени файла
        $new_filename = $self->_random_string( $name_length );

        $new_filename = $new_filename . '.' . $extension;

        foreach ( @list ){
            chomp;
            if ( $_ eq $new_filename ){
                $coincidence = 1;
                last;
            }
        }
    } 
    while ( $coincidence );

    # while ( !$coincidence  ){
    #     $coincidence = 1;

    #     # генерация случайного имени файла
    #     $new_filename = $self->_random_string( $name_length );
    #     $new_filename = $new_filename . '.' . $extension;

    #     foreach ( @list ){
    #         chomp;
    #         if ( $_ eq $new_filename ){
    #             $coincidence = 1;
    #             exit;
    #         }
    #     }
    # }
    

    # получение содержимого файла
    $content = $file->{'asset'}->{'content'};

    # запись файла
    $result = write_file( $path . $new_filename, $content) or die( "can't write file $filename: $!" );

    $self->render(
        'json'    => {
            'controller'    => 'upload',
            'route'         => 'index',
            'status'        => 'ok'
        }
    );
}

1;