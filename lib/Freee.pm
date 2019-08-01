package Freee;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Mojo::Log;

use Mojo::EventEmitter;
use Mojo::RabbitMQ::Client;
use Mojo::RabbitMQ::Client::Channel;

use common;
use validate;
use Data::Dumper;

$| = 1;
has [qw( websockets amqp )];

# This method will run once at server start
sub startup {
    my $self = shift;

    my ( $host );

    # load database config
    $config = $self->plugin(Config => { file => rel_file('./freee.conf') });
    $log = Mojo::Log->new(path => $config->{'log'}, level => 'debug');

    # Configure the application
    $self->secrets($config->{secrets});
    $host = $config->{'host'};

    # set life-time fo session (second)
    $self->sessions->default_expiration($config->{'expires'});

    $self->plugin('Freee::Helpers::PgEAV');
    $self->plugin('Freee::Helpers::Rabbit');

    # init Pg connection
    # $self->pg_dbh();
    # $self->pg_init();

    # prepare validate functions
    prepare_validate();

    # RabbitMQ
    # $amqp = Mojo::RabbitMQ::Client->new( url => ($ENV{MOJO_RABBITMQ_URL} || $config->{'ampq'}->{'url'}) );
    # $amqp->on(
    #     open => sub {
    #         my ($client) = @_;
    #         warn "client connected";

    #         my $channel = Mojo::RabbitMQ::Client::Channel->new();
    #         $channel->catch(sub { warn 'Error on channel received'; });
    #         $channel->on(
    #             open => sub {
    #                 # Forward every message from browser to message queue
    #                 app->events->on(
    #                     mojochat => sub {
    #                         return unless $_[1]->[0] eq 'browser';

    #                         $channel->publish(
    #                             exchange    => 'mojo',
    #                             routing_key => '',
    #                             body        => $_[1]->[1],
    #                             mandatory   => 0,
    #                             immediate   => 0,
    #                             header      => {}
    #                         )->deliver();
    #                     }
    #                 );

    #                 # Create anonymous queue and bind it to fanout exchange named mojo
    #                 my $queue = $channel->declare_queue(exclusive => 1);
    #                 $queue->on(
    #                     success => sub {
    #                         my $method = $_[1]->method_frame;
    #                         my $bind   = $channel->bind_queue(
    #                             exchange    => 'mojo',
    #                             queue       => $method->queue,
    #                             routing_key => '',
    #                         );
    #                         $bind->on(
    #                             success => sub {
    #                                 my $consumer = $channel->consume(queue => $method->queue);

    #                                 # Forward every received messsage to browser
    #                                 $consumer->on(
    #                                     message => sub {
    #                                         app->events->emit( mojochat => ['amqp', $_[1]->{body}->payload] );
    #                                     }
    #                                 );
    #                                 $consumer->deliver();
    #                             }
    #                         );
    #                         $bind->deliver();
    #                     }
    #                 );
    #                 $queue->deliver();
    #             }
    #         );
    #         $channel->on(close => sub { warn 'Channel closed'; });
    #         $client->open_channel($channel);
    #     }
    # );
    # $amqp->connect();

    # Router
    my $r = $self->routes;
    $r->post('/login')              ->to('auth#login');
    $r->any('/logout')              ->to('auth#logout');

    $r->any('/doc')                 ->to('index#doc');

    $r->any('/test')                ->to('websocket#test');
    $r->websocket('/channel')       ->to('websocket#index');

    my $auth = $r->under()          ->to('auth#check_token');
    $auth->post('/settings')        ->to('settings#index');

    # управление контентом
    $auth->post('/cms')                 ->to('cms#index');

    $auth->post('/cms/listpages')       ->to('cms#listpages');
    $auth->post('/cms/addpage')         ->to('cms#addpage');
    $auth->post('/cms/editpage')        ->to('cms#editpage');
    $auth->post('/cms/activatepage')    ->to('cms#activatepage');
    $auth->post('/cms/hidepage')        ->to('cms#hidepage');
    $auth->post('/cms/deletepage')      ->to('cms#deletepage');

    $auth->post('/cms/subject')         ->to('cmssubject#index');
    $auth->post('/cms/addsubject')      ->to('cmssubject#addsubject');
    $auth->post('/cms/editsubject')     ->to('cmssubject#editsubject');
    $auth->post('/cms/activatesubject') ->to('cmssubject#activatesubject');
    $auth->post('/cms/hidesubject')     ->to('cmssubject#hidesubject');
    $auth->post('/cms/deletesubject')   ->to('cmssubject#deletesubject');

    $auth->post('/cms/items')           ->to('cmsitems#index');
    $auth->post('/cms/listitems')       ->to('cmsitems#listitems');
    $auth->post('/cms/additem')         ->to('cmsitems#additem');
    $auth->post('/cms/edititem')        ->to('cmsitems#edititem');
    $auth->post('/cms/activateitem')    ->to('cmsitems#activateitem');
    $auth->post('/cms/hideitem')        ->to('cmsitems#hideitem');
    $auth->post('/cms/delitem')         ->to('cmsitems#delitem');

    # управление библиотекой
    $auth->post('/library')             ->to('library#index');
    $auth->post('/library/list')        ->to('library#list');
    $auth->post('/library/search')      ->to('library#search');
    $auth->post('/library/add')         ->to('library#add');
    $auth->post('/library/edit')        ->to('library#edit');
    $auth->post('/library/save')        ->to('library#save');
    $auth->post('/library/upload')      ->to('library#upload');
    $auth->post('/library/activate')    ->to('library#activate');
    $auth->post('/library/hide')        ->to('library#hideitem');
    $auth->post('/library/delete')      ->to('library#delete');

    # управление календарями/расписанием
    $auth->post('/scheduler')           ->to('scheduler#index');
    $auth->post('/scheduler/add')       ->to('scheduler#add');
    $auth->post('/scheduler/edit')      ->to('scheduler#edit');
    $auth->post('/scheduler/save')      ->to('scheduler#save');
    $auth->post('/scheduler/move')      ->to('scheduler#move');
    $auth->post('/scheduler/delete')    ->to('scheduler#delete');

    # согласование программы предмета
    $auth->post('/agreement')           ->to('agreement#index');
    $auth->post('/agreement/add')       ->to('agreement#add');
    $auth->post('/agreement/edit')      ->to('agreement#edit');
    $auth->post('/agreement/request')   ->to('agreement#request');
    $auth->post('/agreement/reject')    ->to('agreement#reject');
    $auth->post('/agreement/approve')   ->to('agreement#approve');
    $auth->post('/agreement/comment')   ->to('agreement#comment');
    $auth->post('/agreement/delete')    ->to('agreement#delete'); # возможно не нужно ?????????

    # управление темами
    $auth->post('/user')                ->to('user#index');
    $auth->post('/user/list')           ->to('user#list');
    $auth->post('/user/add')            ->to('user#add');
    $auth->post('/user/edit')           ->to('user#edit');
    $auth->post('/user/save')           ->to('user#save');
    $auth->post('/user/activate')       ->to('user#activate');
    $auth->post('/user/hide')           ->to('user#hide');
    $auth->post('/user/delete')         ->to('user#index');

    # управление темами
    $auth->post('/subject')             ->to('subject#index');
    $auth->post('/subject/list')        ->to('subject#list');
    $auth->post('/subject/add')         ->to('subject#add');
    $auth->post('/subject/edit')        ->to('subject#edit');
    $auth->post('/subject/save')        ->to('subject#save');
    $auth->post('/subject/activate')    ->to('subject#activate');
    $auth->post('/subject/hide')        ->to('subject#hide');
    $auth->post('/subject/delete')      ->to('subject#delete');

    # управление темами
    $auth->post('/themes')              ->to('themes#index');
    $auth->post('/themes/list')         ->to('themes#list');
    $auth->post('/themes/add')          ->to('themes#add');
    $auth->post('/themes/edit')         ->to('themes#edit');
    $auth->post('/themes/save')         ->to('themes#save');
    $auth->post('/themes/activate')     ->to('themes#activate');
    $auth->post('/themes/hide')         ->to('themes#hide');
    $auth->post('/themes/delete')       ->to('themes#delete');

    # управление лекциями
    $auth->post('/lections')            ->to('lections#index');
    $auth->post('/lections/list')       ->to('lections#list');
    $auth->post('/lections/add')        ->to('lections#add');
    $auth->post('/lections/edit')       ->to('lections#edit');
    $auth->post('/lections/save')       ->to('lections#save');
    $auth->post('/lections/activate')   ->to('lections#activate');
    $auth->post('/lections/hide')       ->to('lections#hide');
    $auth->post('/lections/delete')     ->to('lections#delete');

    # управление заданиями
    $auth->post('/tasks')               ->to('tasks#index');
    $auth->post('/tasks/list')          ->to('tasks#list');
    $auth->post('/tasks/add')           ->to('tasks#add');
    $auth->post('/tasks/edit')          ->to('tasks#edit');
    $auth->post('/tasks/save')          ->to('tasks#save');
    $auth->post('/tasks/activate')      ->to('tasks#activate');
    $auth->post('/tasks/hide')          ->to('tasks#hide');
    $auth->post('/tasks/delete')        ->to('tasks#delete');

    # проверка заданий
    $auth->post('/mentors')             ->to('mentors#index');
    $auth->post('/mentors/setmentor')   ->to('mentors#setmentor');
    $auth->post('/mentors/unsetmentor') ->to('mentors#unsetmentor');
    $auth->post('/mentors/tasks')       ->to('mentors#tasks');
    $auth->post('/mentors/viewtask')    ->to('mentors#viewtask');
    $auth->post('/mentors/addcomment')  ->to('mentors#addcomment');
    $auth->post('/mentors/savecomment') ->to('mentors#savecomment');
    $auth->post('/mentors/setmark')     ->to('mentors#setmark'); # возможно не нужно ?????????
 # возможно еще что-то ?????????

    # экзамены
    $auth->post('/exam')                ->to('exam#index');
    $auth->post('/exam/list')           ->to('exam#list');
    $auth->post('/exam/start')          ->to('exam#start');
    $auth->post('/exam/edit')           ->to('exam#edit');
    $auth->post('/exam/save')           ->to('exam#save');
    $auth->post('/exam/finish')         ->to('exam#finish');
 # возможно еще что-то ?????????

    # обучение
    $auth->post('/lesson')            ->to('lesson#index');
    $auth->post('/lesson/video')      ->to('lesson#video');
    $auth->post('/lesson/text')       ->to('lesson#text');
    $auth->post('/lesson/examples')   ->to('lesson#examples');
    $auth->post('/lesson/tasks')      ->to('lesson#tasks'); # возможно дублирует /tasks/list ?????????

    # форум
    $auth->post('/forum')               ->to('forum#index');
    $auth->post('/forum/listthemes')    ->to('forum#listthemes');
    $auth->post('/forum/theme')         ->to('forum#theme');
    $auth->post('/forum/addtext')       ->to('forum#addtext');
    $auth->post('/forum/deltext')       ->to('forum#deltext');

    $r->any('/*')->to('index#index');
}

1;
