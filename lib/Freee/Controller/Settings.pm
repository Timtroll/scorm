package Freee::Controller::Settings;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my ($self);
    $self = shift;

    # показываем все настройки
    $self->render(
        json    => {
            'core'  => {
                'usr'   => 'http://freee.su'
            },
            'pages'  => {
                'type'          => 'chapter',           # chater/text/good/
                'title'         => 'Заголовок',
                'meta'          => 'meta теги',
                'description'   => 'краткое содержание',
                'text'          => 'текст',
                'media'         => [1, 2, 3],           # id медиа-файлов
                'owner'         => 'id родителя',
                'distance'      => 1,                   # уровень вложенности
                'status'        => 1,                   # вкл/выкл
            },
            'catalog'  => {
            },
            'users'  => {
                'name'          => 'Вася',              # имя пользователя
                'phone'         => '+7 981 888-8888',   # телефон
                'email'         => 'troll@spam.net.ua', # имя пользователя
                'status'        => 1,                   # вкл/выкл
            },
            'media'  => {
            },
            'news'  => {
            },
            'mention'  => {
            },
            'scorm'  => {
            },
        }
    );
}

sub update {
    my ($self);
    $self = shift;

    # сохраняем указанные настройки

    $self->index();
}

############# Subs #############

sub settings_list {

}

1;