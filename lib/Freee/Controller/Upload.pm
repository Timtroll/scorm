package Freee::Controller::Upload;

use utf8;
use Encode;
use Mojo::Base 'Mojolicious::Controller';
use File::Slurp;
use Data::Dumper;
use common;

sub index {
    my $self = shift;

    my ( $file, $data, $error, $filename, $extension, $path, $local_path, $coincidence, $title, $name_length, $content, $result, $description, @list, @mess );
    push @mess, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    unless (@mess) {
        # проверка данных
        ( $data, $error ) = $self->_check_fields();
    }

warn Dumper( $data );
warn Dumper( $error );
# warn Dumper( $self->{ 'app' }->{ 'config' }->{ 'upload_max_size' } );
# warn Dumper( @mess );
# print '++++++++++++';
# warn Dumper( $self->url_for );
# print '++++++++++++';

#     # получение загруженного файла
#     $file = $self->param('upload');

# # warn Dumper( $file );

#     # получение описания файла
#     $description = $self->param('description');

#     # получение старого имени файла
#     $title = $file->{'filename'};

#     # путь файла
#     $path = 'local';

#     # валидация?
#     # unless (
#     #     $file &&
#     #     $file->{'headers'} &&
#     #     $file->{'headers'}->{'headers'} &&
#     #     $file->{'headers'}->{'headers'}->{'content-disposition'} &&
#     #     $file->{'headers'}->{'headers'}->{'content-disposition'}->[0]
#     # ) {
#     #     warn'wrong upload file!';
#     #     exit;
#     # }

#     # получение расширения
#     $extension = $file->{'headers'}->{'headers'}->{'content-disposition'}->[0];
#     $extension =~ s/^.*filename=".*\.//;
#     $extension =~ s/".*$//;
#     $extension = "\L$extension";

#     ############### проверка расширения

#     $local_path = './upload/';

#     # чтение файлов директории скриптов
#     @list = `ls $local_path 2>&1`;
#     if ( $? ) {
#         warn( "can't read directory $local_path" ); 
#         exit; 
#     };

#     $name_length = 48;

#     do {
#         $coincidence = 0;

#         # генерация случайного имени файла
#         $filename = $self->_random_string( $name_length );

#         $filename = $filename . '.' . $extension;

#         foreach ( @list ){
#             chomp;
#             if ( $_ eq $filename ){
#                 $coincidence = 1;
#                 last;
#             }
#         }
#     } 
#     while ( $coincidence );

#     # получение содержимого файла
#     $content = $file->{'asset'}->{'content'};

#     # запись файла
#     $result = write_file( $local_path . $filename, $content) or die( "can't write file $title: $!" );

    $self->render(
        'json'    => {
            'controller'    => 'upload',
            'route'         => 'index',
            'status'        => 'ok'
        }
    );
}

1;