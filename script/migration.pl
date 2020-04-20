#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurper 'read_text';
use DBI;

my $filename = '../freee.conf';
my $dir = '../sql';

my $config = read_text( $filename );
$config = eval( $config );
my $db = $config->{'dbs'}->{'databases'}->{'pg_main'};

if (
    $db &&
    $db->{'options'} &&
    $db->{'options'}->{'RaiseError'} 
) {
    $db->{'options'}->{'RaiseError'} = 0;
}

my $dbh = DBI->connect(
    $db->{'dsn'},
    $db->{'username'},
    $db->{'password'},
    $db->{'options'}
);

my @list = `ls $dir`;

foreach ( @list ){
    my $filename = $dir . '/' . $_;
    chomp ( $filename );
    next if ( -d $filename || $_ !~ /\.sql$/);

    my $sql = read_text( $filename );
    my $sth = $dbh->prepare( $sql );
    my $res = $sth->execute();

    unless ( $res ) {
        my $error = DBI->errstr;
        print "$error in $filename script!\n";
        last;    
    }
}