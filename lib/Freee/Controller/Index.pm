package Freee::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub doc {
    my ($self);
    $self = shift;

# Postgres Работа с полями

# очистка базы 
print Dumper( $self->tranc_bases() );


# удаление поля
# print Dumper( $self->delete_field(5) );

# # создание полей
print Dumper( $self->create_field(
{
    id      => 1,
    alias   => 'theme',
    title   => 'Тема',
    type    => 'string',
    set     => 'user'
}));
print Dumper( $self->create_field(
{
    id      => 2,
    alias   => 'name',
    title   => 'Матем 2',
    type    => 'string',
    set     => 'lesson'
}));

# # update поля
# print Dumper( $self->update_field(
# {
#     id      => 1,
#     alias   => 'theme',
#     title   => 'Тема',
#     type    => 'string',
#     set     => 'lesson'
# }));

# список полей
print Dumper( $self->list_fields() );

# добавление записи
print Dumper( $self->pg_create(
{
    type => 'lesson',
    parent      => 0,
    publish     => \1,
    import_id   => 1,

    title       => 'Математика',
    theme   => 'Дискретная Математика',
    name    => 'Костенко'
}
));

# сохранение хаписи
# print Dumper( $self->pg_store('lesson',
# {
#     publish => \1,
#     import_id => 1,
#     title => 'Математика',
# }
# ));
# print Dumper( $self->ampq());

    $self->render(
        'template'    => 'index',
        'title'       => 'Описание роутов'
    );
}


1;