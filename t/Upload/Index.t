#!/usr/bin/perl -w
# загрузка файла

use strict;
use warnings;
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use FindBin;

use Data::Dumper;
use Mojo::UserAgent;

my $ua  = Mojo::UserAgent->new;

use File::Slurp::Unicode qw(slurp);;
my $filename = './../../freee.conf';
# чтение конфигурации
my $config = slurp( $filename, encoding => 'utf8' ) or die( "can't read file $filename: $!" );
# преобразование текста файла конфигурации в объект
$config = eval( $config );

# Устанавливаем адрес
my $host = $config->{'host'};

my $data = { id => '50' };
my $address = $host . '/upload/delete/';
# my $address = 'http://127.0.0.1:4444/upload/delete/';

my $res = $ua->post( $address => form => $data )->result;

if    ($res->is_success)  { say $res->body }
elsif ($res->is_error)    { say $res->message }
elsif ($res->code == 301) { say $res->headers->location }
else                      { say 'Whatever...' }