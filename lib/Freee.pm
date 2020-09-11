package Freee;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Mojo::Log;
use Freee::EAV;
use Freee::Model; 
use DBD::Pg;
use DBI;

use common;
use Data::Dumper;

$| = 1;
# has 'dbh', 'mime';

# This method will run once at server start
sub startup {
    my $self = shift;

    my ( $host, $r, $auth );

    # load database config
    $config = $self->plugin(Config => { file => rel_file('./freee.conf') });
    $log = Mojo::Log->new(path => $config->{'log'}, level => 'debug');

    # Configure the application
    $self->secrets($config->{secrets});
    $host = $config->{'host'};

    # set life-time fo session (second)
    # $self->sessions->cookie_name('token');
    # $self->sessions->default_expiration($config->{'expires'});
    # $self->session->samesite('None');
use Mojolicious::Sessions;

my $sessions = Mojolicious::Sessions->new;
$sessions->cookie_name('token');
$sessions->default_expiration($config->{'expires'});
# $sessions->samesite('none');

    $self->plugin('Freee::Helpers::Utils');
    $self->plugin('Freee::Helpers::PgGraph');
    $self->plugin('Freee::Helpers::Beanstalk');
    $self->plugin('Freee::Helpers::PgForum');

    # init Pg connection
    $dbh = $self->pg_dbh();

    # Модель EAV передаем коннекшн базы
    Freee::EAV->new( 'User', { 'dbh' => $dbh } );

    # подгружаем модель и создадим соответствующий хелпер для вызова модели + передадим ссылки на $self и коннект к базе
    my $model = Freee::Model->new( app => $self );
    $self->helper(
        model => sub {
            my ($self, $model_name) = @_;
            return $model->get_model($model_name);
        }
    );

    # обновление объекта с настройками
    $settings = $self->model('Settings')->_get_config();

    # init Beanstalk connection
    $self->_beans_init();

    # загрузка правил валидации
    $self->plugin('Freee::Helpers::Validate');
    $vfields = $self->_param_fields();

    # Router
    $r = $self->routes;
    $r->any('/api/doc')                 ->to('index#doc');

    $r->any('/api/test')                ->to('websocket#test');
    $r->post('/api/deploy')             ->to('deploy#index');           # deploy после push
    $r->websocket('/api/channel')       ->to('websocket#index');

    # webrtc роуты
    $r->get('/wschannel/index')         ->to('wschannel#index');
    $r->websocket('/wschannel/:type')   ->to('wschannel#type');

# ??? требуется переписать так,чтобы можно было использовать безопасно
    $r->get('/settings/load_default')   ->to('settings#load_default');    # загрузка дефолтных настроек

    # роут на который происходит редирект, для вывода ошибок при валидации и в других случаях
    $r->any('/error/')                  ->to('index#error');

    # Вход-выход в/из системы
# ????? нафиг
    $r->post('/auth/login')              ->to('auth#login');
    $r->any('/auth/logout')              ->to('auth#logout');

    $auth = $r->under()->to('auth#check_token');

    # работа с EAV объектами (служебное)
    $auth->get('/manage_eav/')            ->to('manage#index');         # граф EAV
    $auth->get('/manage_eav/root')        ->to('manage#root');          # json графа EAV

    # загрузка файлов
    $auth->post('/upload/')               ->to('upload#index');         # сохранение загружаемого файла
    $auth->post('/upload/search/')        ->to('upload#search');        # поиск загруженного файла
    $auth->post('/upload/delete/')        ->to('upload#delete');        # удаление загруженного файла
    $auth->post('/upload/update/')        ->to('upload#update');        # обновление описания загруженного файла

    # левая менюха (дерево без листочков) - обязательная проверка на фолдер
    $auth->post('/settings/get_tree')     ->to('settings#get_tree');    # Все дерево без листочков
    $auth->post('/settings/get_folder')   ->to('settings#get_folder');  # получить данные фолдера настроек
    $auth->post('/settings/add_folder')   ->to('settings#add_folder');  # добавление фолдера
    $auth->post('/settings/save_folder')  ->to('settings#save_folder'); # сохранение фолдера
    $auth->post('/settings/proto_folder') ->to('proto#proto_folder');   # прототип настройки

    # строки настроек - обязательная проверка на фолдер
    $auth->post('/settings/add')          ->to('settings#add');         # добавление настройки
    $auth->post('/settings/proto_leaf')   ->to('proto#proto_leaf');     # прототип настройки
    $auth->post('/settings/edit')         ->to('settings#edit');        # загрузка одной настройки
    $auth->post('/settings/save')         ->to('settings#save');        # добавление/сохранение настройки

    # управление импортом и экспортом
    $auth->post('/settings/export')       ->to('settings#export');      # экспорт текущих настроек
    $auth->post('/settings/import')       ->to('settings#import');      # импорт сохранённых настроек
    $auth->post('/settings/del_export')   ->to('settings#del_export');  # удаление сохранённых настроек
    $auth->post('/settings/list_export')  ->to('settings#list_export'); # вывод списка сохранённых настроек

    # проверка на фолдер не нужна
    $auth->post('/settings/get_leafs')  ->to('settings#get_leafs');     # список листочков узла дерева
    $auth->post('/settings/toggle')     ->to('settings#toggle');        # включение/отключение поля в строке настройки
    $auth->post('/settings/delete')     ->to('settings#delete');        # удаление фолдера или настройки

    # управление контентом
    $auth->post('/cms/article')         ->to('cmsarticle#index');
    $auth->post('/cms/article_add')     ->to('cmsarticle#add');
    $auth->post('/cms/article_edit')    ->to('cmsarticle#edit');
    $auth->post('/cms/article_save')    ->to('cmsarticle#save');
    $auth->post('/cms/article_toggle')  ->to('cmsarticle#toggle');
    $auth->post('/cms/article_delete')  ->to('cmsarticle#delete');

    # управление предметами
    $auth->post('/discipline/')         ->to('discipline#index');       # Список предметов
    $auth->post('/discipline/add')      ->to('discipline#add');         # Добавить предмет
    $auth->post('/discipline/edit')     ->to('discipline#edit');        # Получить данные для редактирования предмета
    $auth->post('/discipline/save')     ->to('discipline#save');        # Сохранить предмет
    $auth->post('/discipline/toggle')   ->to('discipline#toggle');      # Изменить статус предмета (вкл/выкл)
    $auth->post('/discipline/delete')   ->to('discipline#delete');      # Удалить предмет

    # управление темами
    $auth->post('/theme/')              ->to('theme#index');            # Список тем
    $auth->post('/theme/add')           ->to('theme#add');              # Добавить тему
    $auth->post('/theme/edit')          ->to('theme#edit');             # Получить данные для редактирования темы
    $auth->post('/theme/save')          ->to('theme#save');             # Сохранить тему
    $auth->post('/theme/toggle')        ->to('theme#toggle');           # Изменить статус темы (вкл/выкл)
    $auth->post('/theme/delete')        ->to('theme#delete');           # Удалить тему

    $auth->post('/cms/subject')         ->to('cmssubject#index');
    $auth->post('/cms/subject_add')     ->to('cmssubject#add');
    $auth->post('/cms/subject_edit')    ->to('cmssubject#edit');
    $auth->post('/cms/subject_save')    ->to('cmssubject#save');
    $auth->post('/cms/subject_toggle')  ->to('cmssubject#toggle');
    $auth->post('/cms/subject_delete')  ->to('cmssubject#delete');

    $auth->post('/cms/item')            ->to('cmsitems#index');
    $auth->post('/cms/item_add')        ->to('cmsitems#add');
    $auth->post('/cms/item_edit')       ->to('cmsitems#edit');
    $auth->post('/cms/item_save')       ->to('cmsitems#saveitem');
    $auth->post('/cms/item_toggle')     ->to('cmsitems#toggle');
    $auth->post('/cms/item_delete')     ->to('cmsitems#delete');

    # управление почтовыми сообщениями, рассылками
    $auth->post('/cms/mail')            ->to('cmsmail#index');
    $auth->post('/cms/mail_add')        ->to('cmsmail#add');
    $auth->post('/cms/mail_edit')       ->to('cmsmail#edit');
    $auth->post('/cms/mail_save')       ->to('cmsmail#save');
    $auth->post('/cms/mail_toggle')     ->to('cmsmail#toggle');
    $auth->post('/cms/mail_delete')     ->to('cmsmail#delete');

    # управление библиотекой
    $auth->post('/library/')            ->to('library#index');
    $auth->post('/library/list')        ->to('library#list');
    $auth->post('/library/search')      ->to('library#search');
    $auth->post('/library/add')         ->to('library#add');
    $auth->post('/library/edit')        ->to('library#edit');
    $auth->post('/library/save')        ->to('library#save');
    $auth->post('/library/upload')      ->to('library#upload');
    $auth->post('/library/toggle')      ->to('library#toggle');
    $auth->post('/library/delete')      ->to('library#delete');

    # проверка заданий
    $auth->post('/mentors/')            ->to('mentors#index');
    $auth->post('/mentors/setmentor')   ->to('mentors#setmentor');
    $auth->post('/mentors/unsetmentor') ->to('mentors#unsetmentor');
    $auth->post('/mentors/tasks')       ->to('mentors#tasks');
    $auth->post('/mentors/viewtask')    ->to('mentors#viewtask');
    $auth->post('/mentors/addcomment')  ->to('mentors#addcomment');
    $auth->post('/mentors/savecomment') ->to('mentors#savecomment');
    $auth->post('/mentors/setmark')     ->to('mentors#setmark');    # возможно не нужно ?????????
 # возможно еще что-то ?????????

    # управление календарями/расписанием
    $auth->post('/scheduler/')          ->to('scheduler#index');
    $auth->post('/scheduler/add')       ->to('scheduler#add');
    $auth->post('/scheduler/edit')      ->to('scheduler#edit');
    $auth->post('/scheduler/save')      ->to('scheduler#save');
    $auth->post('/scheduler/move')      ->to('scheduler#move');
    $auth->post('/scheduler/toggle')    ->to('scheduler#toggle');
    $auth->post('/scheduler/delete')    ->to('scheduler#delete');

    # согласование программы предмета
    $auth->post('/agreement/')          ->to('agreement#index');
    $auth->post('/agreement/add')       ->to('agreement#add');
    $auth->post('/agreement/edit')      ->to('agreement#edit');
    $auth->post('/agreement/save')      ->to('agreement#save');
    $auth->post('/agreement/request')   ->to('agreement#request');
    $auth->post('/agreement/reject')    ->to('agreement#reject');
    $auth->post('/agreement/approve')   ->to('agreement#approve');
    $auth->post('/agreement/comment')   ->to('agreement#comment');
    $auth->post('/agreement/delete')    ->to('agreement#delete');   # возможно не нужно ?????????

    # управление пользователями
    $auth->post('/user/')               ->to('user#index');         # список юзеров по группам (обязательно id группы)
    $auth->post('/user/add')            ->to('user#add');           # заполнение пустышки юзера (регистрация юзера)
    $auth->post('/user/edit')           ->to('user#edit');          # редактирование юзера
    $auth->post('/user/registration')   ->to('user#registration');  # регистрация пользователя
    $auth->post('/user/save')           ->to('user#save');          # обновление данных юзера
    $auth->post('/user/toggle')         ->to('user#toggle');        # включение юзера
    $auth->post('/user/profile')        ->to('user#profile');       # пермишены и профиль юзера
    $auth->post('/user/delete')         ->to('user#delete');        # удаление пользователя

    # управление группами пользователей
    $auth->post('/groups/')             ->to('groups#index');       # список групп
    $auth->post('/groups/add')          ->to('groups#add');         # добавление группы
    $auth->post('/groups/edit')         ->to('groups#edit');        # загрузка данных группы
    $auth->post('/groups/save')         ->to('groups#save');        # обновление данных группы
    $auth->post('/groups/delete')       ->to('groups#delete');      # удаление группы
    $auth->post('/groups/toggle')       ->to('groups#toggle');      # включение/отключение группы

    # управление роутами
    $auth->post('/routes/')             ->to('routes#index');       # список роутов конкретной группы
    $auth->post('/routes/edit')         ->to('routes#edit');        # данные указанного роута
    $auth->post('/routes/save')         ->to('routes#save');        # обновление данных по роуту
    $auth->post('/routes/toggle')       ->to('routes#toggle');      # Изменить статус поля роута (вкл/выкл)

    # управление заданиями
    $auth->post('/tasks/')              ->to('tasks#index');
    $auth->post('/tasks/add')           ->to('tasks#add');
    $auth->post('/tasks/edit')          ->to('tasks#edit');
    $auth->post('/tasks/save')          ->to('tasks#save');
    $auth->post('/tasks/toggle')        ->to('tasks#toggle');
    $auth->post('/tasks/delete')        ->to('tasks#delete');
    $auth->post('/tasks/finished')      ->to('tasks#finished');

    # экзамены
    $auth->post('/exam/')               ->to('exam#index');
    $auth->post('/exam/start')          ->to('exam#start');
    $auth->post('/exam/edit')           ->to('exam#edit');
    $auth->post('/exam/save')           ->to('exam#save');
    $auth->post('/exam/finish')         ->to('exam#finish');
# возможно еще что-то ?????????

    # обучение
    $auth->post('/lesson/')             ->to('lesson#index');
    $auth->post('/lesson/video')        ->to('lesson#video');
    $auth->post('/lesson/text')         ->to('lesson#text');
    $auth->post('/lesson/examples')     ->to('lesson#examples');
    $auth->post('/lesson/tasks')        ->to('lesson#tasks');       # возможно дублирует /tasks/list ?????????
    $auth->post('/lesson/finished')     ->to('lesson#finished');

    # учет успеваемости
    $auth->post('/accounting/')         ->to('accounting#index');
    $auth->post('/accounting/search')   ->to('accounting#search');
    $auth->post('/accounting/add')      ->to('accounting#add');
    $auth->post('/accounting/stat')     ->to('accounting#stat');

    # форум
    $auth->any('/forum/')               ->to('forum#index');        # стартовая страница
    $auth->post('/forum/list_themes')   ->to('forum#list_themes');
    $auth->post('/forum/theme')         ->to('forum#theme');
    $auth->post('/forum/add_theme')     ->to('forum#add_theme');
    $auth->post('/forum/edit_theme')    ->to('forum#edit_theme');
    $auth->post('/forum/del_theme')     ->to('forum#del_theme');

    $auth->post('/forum/list_groups')   ->to('forum#list_groups');
    $auth->post('/forum/group')         ->to('forum#group');
    $auth->post('/forum/add_group')     ->to('forum#add_group');
    $auth->post('/forum/edit_group')    ->to('forum#edit_group');
    $auth->post('/forum/del_group')     ->to('forum#del_group');

    $auth->post('/forum/list_messages') ->to('forum#list_messages'); # список сообщений по теме
    $auth->post('/forum/add')           ->to('forum#add');           # добавление сообщения
    $auth->post('/forum/save')          ->to('forum#save');          # редактирование сообщения
    $auth->post('/forum/edit')          ->to('forum#edit');          # вывод сообщения по id
    $auth->post('/forum/delete')        ->to('forum#delete');        # удаление сообщения
    $auth->post('/forum/toggle')        ->to('forum#toggle');        # изменение статуса

    $r->any('/*')->to('index#index');

    # сохраняем все роуты
    foreach (@{$auth->{children}} ) {
        $$routs{ $_->{pattern}->{defaults}->{action} } = $_->{pattern}->{'unparsed'};
    }
}

1;
