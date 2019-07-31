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
has [qw( websockets amqp )]; # events init_pg list_fields 

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

    $self->plugin('Freee::Helpers::Dbase');

    $self->init_pg();
print "init-\n";

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

    $auth->post('/cms/listpages')       ->to('cms#index');
    $auth->post('/cms/addpage')         ->to('cms#index');
    $auth->post('/cms/editpage')        ->to('cms#index');
    $auth->post('/cms/activatepage')    ->to('cms#index');
    $auth->post('/cms/hidepage')        ->to('cms#index');
    $auth->post('/cms/deletepage')      ->to('cms#index');

    $auth->post('/cms/addsubject')      ->to('cms#index');
    $auth->post('/cms/editsubject')     ->to('cms#index');
    $auth->post('/cms/activatesubject') ->to('cms#index');
    $auth->post('/cms/hidesubject')     ->to('cms#index');
    $auth->post('/cms/deletesubject')   ->to('cms#index');

    $auth->post('/cms/listitems')       ->to('cms#index');
    $auth->post('/cms/additem')         ->to('cms#index');
    $auth->post('/cms/edititem')        ->to('cms#index');
    $auth->post('/cms/activateitem')    ->to('cms#index');
    $auth->post('/cms/hideitem')        ->to('cms#index');
    $auth->post('/cms/delitem')         ->to('cms#index');

    # управление библиотекой
    $auth->post('/library')             ->to('library#index');
    $auth->post('/library/list')        ->to('library#index');
    $auth->post('/library/search')      ->to('library#index');
    $auth->post('/library/add')         ->to('library#index');
    $auth->post('/library/edit')        ->to('library#index');
    $auth->post('/library/activate')    ->to('library#index');
    $auth->post('/library/hide')        ->to('library#index');
    $auth->post('/library/delete')      ->to('library#index');

    # управление календарями/расписанием
    $auth->post('/scheduler')           ->to('scheduler#index');
    $auth->post('/scheduler/add')       ->to('scheduler#index');
    $auth->post('/scheduler/edit')      ->to('scheduler#index');
    $auth->post('/scheduler/move')      ->to('scheduler#index');
    $auth->post('/scheduler/delete')    ->to('scheduler#index');

    # согласование программы предмета
    $auth->post('/agreement')           ->to('agreement#index');
    $auth->post('/agreement/request')   ->to('agreement#index');
    $auth->post('/agreement/reject')    ->to('agreement#index');
    $auth->post('/agreement/approve')   ->to('agreement#index');
    $auth->post('/agreement/comment')   ->to('agreement#index');
    $auth->post('/agreement/delete')    ->to('agreement#index'); # возможно не нужно ?????????

    # управление темами
    $auth->post('/user')                ->to('user#index');
    $auth->post('/user/list')           ->to('user#index');
    $auth->post('/user/add')            ->to('user#index');
    $auth->post('/user/edit')           ->to('user#index');
    $auth->post('/user/activate')       ->to('user#index');
    $auth->post('/user/hide')           ->to('user#index');
    $auth->post('/user/delete')         ->to('user#index');

    # управление темами
    $auth->post('/subject')             ->to('subject#index');
    $auth->post('/subject/list')        ->to('subject#index');
    $auth->post('/subject/add')         ->to('subject#index');
    $auth->post('/subject/edit')        ->to('subject#index');
    $auth->post('/subject/activate')    ->to('subject#index');
    $auth->post('/subject/hide')        ->to('subject#index');
    $auth->post('/subject/delete')      ->to('subject#index');

    # управление темами
    $auth->post('/themes')              ->to('themes#index');
    $auth->post('/themes/list')         ->to('themes#index');
    $auth->post('/themes/add')          ->to('themes#index');
    $auth->post('/themes/edit')         ->to('themes#index');
    $auth->post('/themes/activate')     ->to('themes#index');
    $auth->post('/themes/hide')         ->to('themes#index');
    $auth->post('/themes/delete')       ->to('themes#index');

    # управление лекциями
    $auth->post('/lections')            ->to('lections#index');
    $auth->post('/lections/list')       ->to('lections#index');
    $auth->post('/lections/add')        ->to('lections#index');
    $auth->post('/lections/edit')       ->to('lections#index');
    $auth->post('/lections/activate')   ->to('lections#index');
    $auth->post('/lections/hide')       ->to('lections#index');
    $auth->post('/lections/delete')     ->to('lections#index');

    # управление заданиями
    $auth->post('/tasks')               ->to('tasks#index');
    $auth->post('/tasks/list')          ->to('tasks#index');
    $auth->post('/tasks/add')           ->to('tasks#index');
    $auth->post('/tasks/edit')          ->to('tasks#index');
    $auth->post('/tasks/activate')      ->to('tasks#index');
    $auth->post('/tasks/hide')          ->to('tasks#index');
    $auth->post('/tasks/delete')        ->to('tasks#index');

    # проверка заданий
    $auth->post('/mentors')             ->to('mentors#index');
    $auth->post('/mentors/comment')     ->to('mentors#index');
    $auth->post('/mentors/mark')        ->to('mentors#index'); # возможно не нужно ?????????
 # возможно еще что-то ?????????

    # экзамены
    $auth->post('/exam')                ->to('exam#index');
    $auth->post('/exam/list')           ->to('exam#index');
    $auth->post('/exam/add')            ->to('exam#index');
    $auth->post('/exam/edit')           ->to('exam#index');
    $auth->post('/exam/activate')       ->to('exam#index');
    $auth->post('/exam/hide')           ->to('exam#index');
    $auth->post('/exam/tasks')          ->to('exam#index');
    $auth->post('/exam/submit')         ->to('exam#index');
 # возможно еще что-то ?????????

    # обучение
    $auth->post('/training')            ->to('training#index');
    $auth->post('/training/video')      ->to('training#index');
    $auth->post('/training/text')       ->to('training#index');
    $auth->post('/training/examples')   ->to('training#index');
    $auth->post('/training/tasks')      ->to('training#index'); # возможно дублирует /tasks/list ?????????

    # форум
    $auth->post('/forum')               ->to('forum#index');
    $auth->post('/forum/listthemes')    ->to('forum#index');
    $auth->post('/forum/theme')         ->to('forum#index');
    $auth->post('/forum/addtext')       ->to('forum#index');
    $auth->post('/forum/deltext')       ->to('forum#index');

    $r->any('/*')->to('index#index');
}

1;
