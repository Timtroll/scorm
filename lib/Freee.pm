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

    $self->plugin('Freee::Helpers::Utils');
    $self->plugin('Freee::Helpers::Validate');
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
# warn Dumper( keys %{$settings->{'upload_max_size'}} );

    # init Beanstalk connection
    $self->_beans_init();

    # загрузка правил валидации
    $self->plugin('Freee::Helpers::Validate');
    $vfields = $self->_param_fields();
warn "+++++++++++";
    # Router
    $r = $self->routes;

    $r->any('/api/doc')                   ->to('index#doc');

    $r->any('/api/test')                  ->to('websocket#test');
    $r->post('/api/deploy')               ->to('deploy#index');           # deploy после push
    $r->websocket('/api/channel')         ->to('websocket#index');

    # webrtc роуты
    $r->get('/wschannel/index')           ->to('wschannel#index');
    $r->websocket('/wschannel/:type')     ->to('wschannel#type');

    $r->post('/user/registration')        ->to('user#registration');         # регистрация пользователя

# ??? требуется переписать так,чтобы можно было использовать безопасно
    $r->get('/settings/load_default')     ->to('settings#load_default');  # загрузка дефолтных настроек

    # Вход-выход в/из системы
# ????? нафиг
    $r->post('/auth/login')               ->to('auth#login');
    $r->any('/auth/logout')               ->to('auth#logout');

    $r->any('/mail/')                     ->to('mail#index');
    $r->any('/mail/send')                 ->to('mail#snd');

    # отправка сообщения
    $r->get('/mail/')                     ->to('mail#index');          # вызов страницы
    $r->post('/mail/send_mail')           ->to('mail#send_mail');      # отправка email

    # смена пароля
    $r->post('/reset/')                   ->to('reset#index');         # отправка сообщения о смене
    $r->get('/reset/confirmation')        ->to('reset#confirmation');  # подтверждение смены пароля
    $r->post('/reset/reset')              ->to('reset#reset');         # смена пароля

    $r->any('/error/')                    ->to('index#error');

    $auth = $r->under()->to('auth#check_token');

    $auth->any('/auth/config')               ->to('auth#config');

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

    # управление предметами
    $auth->post('/discipline/')         ->to('discipline#index');       # Список предметов
    $auth->post('/discipline/add')      ->to('discipline#add');         # Добавить предмет
    $auth->post('/discipline/edit')     ->to('discipline#edit');        # Получить данные для редактирования предмета
    $auth->post('/discipline/save')     ->to('discipline#save');        # Сохранить предмет
    $auth->post('/discipline/toggle')   ->to('discipline#toggle');      # Изменить статус предмета (вкл/выкл)
    $auth->post('/discipline/delete')   ->to('discipline#delete');      # Удалить предмет

    # управление курсами
    $auth->post('/course/')             ->to('course#index');           # Список курсов
    $auth->post('/course/add')          ->to('course#add');             # Добавить курс
    $auth->post('/course/edit')         ->to('course#edit');            # Получить данные для редактирования курса
    $auth->post('/course/save')         ->to('course#save');            # Сохранить курс
    $auth->post('/course/toggle')       ->to('course#toggle');          # Изменить статус курса (вкл/выкл)
    $auth->post('/course/delete')       ->to('course#delete');          # Удалить курс

    # управление темами
    $auth->post('/theme/')              ->to('theme#index');            # Список тем
    $auth->post('/theme/add')           ->to('theme#add');              # Добавить тему
    $auth->post('/theme/edit')          ->to('theme#edit');             # Получить данные для редактирования темы
    $auth->post('/theme/save')          ->to('theme#save');             # Сохранить тему
    $auth->post('/theme/toggle')        ->to('theme#toggle');           # Изменить статус темы (вкл/выкл)
    $auth->post('/theme/delete')        ->to('theme#delete');           # Удалить тему

    # управление шаблонами уроков
    $auth->post('/lesson/')             ->to('lesson#index');           # Список уроков
    $auth->post('/lesson/add')          ->to('lesson#add');             # Добавить урок
    $auth->post('/lesson/edit')         ->to('lesson#edit');            # Получить данные для редактирования урока
    $auth->post('/lesson/save')         ->to('lesson#save');            # Сохранить урок
    $auth->post('/lesson/toggle')       ->to('lesson#toggle');          # Изменить статус урока (вкл/выкл)
    $auth->post('/lesson/delete')       ->to('lesson#delete');          # Удалить урок

    # уроки
    $auth->post('/events/')             ->to('events#index');           # Расписание уроков
    $auth->post('/events/add')          ->to('events#add');             # Добавить событие
    $auth->post('/events/save')         ->to('events#save');             # Сохранить событие
    $auth->post('/events/delete')       ->to('events#delete');          # Удалить событие
    $auth->post('/events/toggle')       ->to('events#toggle');          # Изменить статус события
    $auth->post('/events/edit')         ->to('events#edit');            # Редактировать событие
    $auth->post('/events/lesson_users') ->to('events#lesson_users');    # Список участников урока (учитель - обязателен)
    $auth->post('/events/teacher_lessons')->to('events#teacher_lessons'); # Список уроков по учителю
    $auth->post('/events/student_lessons')->to('events#student_lessons'); # Список уроков по ученику

    # обучение
    $auth->post('/lesson/video')        ->to('lesson#video');
    $auth->post('/lesson/text')         ->to('lesson#text');
    $auth->post('/lesson/examples')     ->to('lesson#examples');
    $auth->post('/lesson/tasks')        ->to('lesson#tasks');           # возможно дублирует /tasks/list ?????????
    $auth->post('/lesson/finished')     ->to('lesson#finished');

    # управление уроками
    $auth->post('/task/')               ->to('task#index');             # Список уроков
    $auth->post('/task/add')            ->to('task#add');               # Добавить урок
    $auth->post('/task/edit')           ->to('task#edit');              # Получить данные для редактирования урока
    $auth->post('/task/save')           ->to('task#save');              # Сохранить урок
    $auth->post('/task/toggle')         ->to('task#toggle');            # Изменить статус урока (вкл/выкл)
    $auth->post('/task/delete')         ->to('task#delete');            # Удалить урок
    # управление заданиями
    $auth->post('/tasks/finished')      ->to('tasks#finished');

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
    $auth->post('/user/save')           ->to('user#save');          # обновление данных юзера
    $auth->post('/user/toggle')         ->to('user#toggle');        # включение юзера
    $auth->post('/user/profile')        ->to('user#profile');       # пермишены и профиль юзера
    $auth->post('/user/delete')         ->to('user#delete');        # удаление пользователя
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
    $auth->post('/routes/toggle')       ->to('routes#toggle');      # изменить статус поля роута (вкл/выкл)

    # управление потоками пользователей
    $auth->post('/stream/')             ->to('stream#index');       # список потоков
    $auth->post('/stream/edit')         ->to('stream#edit');        # получить данный для редактирования потока
    $auth->post('/stream/save')         ->to('stream#save');        # сохранить поток
    $auth->post('/stream/add')          ->to('stream#add');         # добавить поток
    $auth->post('/stream/toggle')       ->to('stream#toggle');      # изменить статус потока (вкл/выкл)
    $auth->post('/stream/delete')       ->to('stream#delete');      # удалить поток
    $auth->post('/stream/users')        ->to('stream#users');       # список студентов потока
    $auth->post('/stream/user_add')     ->to('stream#user_add');    # добавить пользователя в поток
    $auth->post('/stream/user_delete')  ->to('stream#user_delete'); # удалить пользователя из потока
    $auth->post('/stream/master_add')   ->to('stream#master_add');  # добавить руководителя в поток
    $auth->post('/stream/get_masters')  ->to('stream#get_masters');# удалить руководителя из потока

    # управление расписанием занятий
    $auth->post('/schedule/')             ->to('schedule#index');       # полный список расписаний
    $auth->post('/schedule/edit')         ->to('schedule#edit');        # получить данный для редактирования расписания
    $auth->post('/schedule/save')         ->to('schedule#save');        # сохранить расписание
    $auth->post('/schedule/add')          ->to('schedule#add');         # добавить расписание
    $auth->post('/schedule/toggle')       ->to('schedule#toggle');      # изменить статус расписания (вкл/выкл)
    $auth->post('/schedule/delete')       ->to('schedule#delete');      # удалить расписание
    $auth->post('/schedule/on_week')      ->to('schedule#on_week');     # расписание на неделю
    $auth->post('/schedule/on_month')     ->to('schedule#on_month');    # расписание на месяц

# возможно еще что-то ?????????

    # учет успеваемости
    $auth->post('/accounting/')         ->to('accounting#index');
    $auth->post('/accounting/search')   ->to('accounting#search');
    $auth->post('/accounting/add')      ->to('accounting#add');
    $auth->post('/accounting/stat')     ->to('accounting#stat');

####################
    # управление контентом
    $auth->post('/cms/article')         ->to('cmsarticle#index');
    $auth->post('/cms/article_add')     ->to('cmsarticle#add');
    $auth->post('/cms/article_edit')    ->to('cmsarticle#edit');
    $auth->post('/cms/article_save')    ->to('cmsarticle#save');
    $auth->post('/cms/article_toggle')  ->to('cmsarticle#toggle');
    $auth->post('/cms/article_delete')  ->to('cmsarticle#delete');

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

    # экзамены
    $auth->post('/exam/')               ->to('exam#index');
    $auth->post('/exam/start')          ->to('exam#start');
    $auth->post('/exam/edit')           ->to('exam#edit');
    $auth->post('/exam/save')           ->to('exam#save');
    $auth->post('/exam/finish')         ->to('exam#finish');

################
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

    # роут на который происходит редирект, для вывода ошибок при валидации и в других случаях
    $r->any('/*')->to('index#error');

    # сохраняем все роуты
    foreach (@{$auth->{children}} ) {
        $$routs{ $_->{pattern}->{defaults}->{action} } = $_->{pattern}->{'unparsed'};
    }
}

1;
