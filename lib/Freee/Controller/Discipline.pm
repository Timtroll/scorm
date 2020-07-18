package Freee::Controller::Discipline;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub index {
    my $self = shift;
print 1;
    my $list = [
        {
            "folder" => 1,
            "id" => 1,
            "label" => "Предмет 1",
            "description" => "Краткое описание",
            "content" => "Полное описание",
            "keywords" => "ключевые слова",
            "url" => "как должен выглядеть url",
            "seo" => "дополнительное поле для seo",
            "route" => "/discipline/",
            "parent" => 0,
            "type" => "",
            "status" => "ok",
            "attachment" => [345,577,643]
        },
        {
            "folder" => 1,
            "id" => 2,
            "label" => "Предмет 2",
            "description" => "Краткое описание",
            "content" => "Полное описание",
            "keywords" => "ключевые слова",
            "url" => "как должен выглядеть url",
            "seo" => "дополнительное поле для seo",
            "route" => "/discipline/",
            "parent" => 0,
            "type" => "",
            "status" => "ok",
            "attachment" => [345,577,643]
        }
    ];

    my $resp;
    $resp->{'label'} = 'Предметы';
    $resp->{'add'}   = 1;
    $resp->{'child'} = {
        "add"    => 1,
        "edit"   => 1,
        "remove" => 1,  
        "route"  => "/theme/" # роут для получения детей
    };
    $resp->{'message'} = 'Tree has not any branches' unless scalar(@$list);
    $resp->{'status'} = scalar(@$list) ? 'ok' : 'fail';
    $resp->{'list'} = $list if scalar(@$list);

    $self->render( 'json' => $resp );
}

sub get {
    my $self = shift;

    my $data = {
        "folder" => 1,
        "id" => $self->param('id'),
        "label" => "Предмет 1",
        "description" => "Краткое описание",
        "content" => "Полное описание",
        "keywords" => "ключевые слова",
        "url" => "как должен выглядеть url",
        "seo" => "дополнительное поле для seo",
        "route" => "/discipline/",
        "parent" => $self->param('parent'),
        "type" => "",
        "attachment" => [345,577,643]
    };

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless scalar(keys %$data);
    $resp->{'status'} = scalar(keys %$data) ? 'ok' : 'fail';
    $resp->{'data'} = $data if $data;

    $self->render( 'json' => $resp );
}

sub add {
    my $self = shift;

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless 1;
    $resp->{'status'} = $self->param('id') ? 'ok' : 'fail';
    $resp->{'id'} = $self->param('id') if $self->param('id');

    $self->render( 'json' => $resp );
}

sub save {
    my $self = shift;

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless 1;
    $resp->{'status'} = $self->param('id') ? 'ok' : 'fail';
    $resp->{'id'} = $self->param('id') if $self->param('id');

    $self->render( 'json' => $resp );
}

sub toggle {
    my $self = shift;

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless 1;
    $resp->{'status'} = $self->param('id') ? 'ok' : 'fail';
    $resp->{'id'} = $self->param('id') if $self->param('id');

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my $resp;
    $resp->{'message'} = 'Tree has not any branches' unless 1;
    $resp->{'status'} = $self->param('id') ? 'ok' : 'fail';
    $resp->{'id'} = $self->param('id') if $self->param('id');

    $self->render( 'json' => $resp );
}

1;