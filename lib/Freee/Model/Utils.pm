package Freee::Model::Utils;

use Mojo::Base 'Freee::Model::Base';
use Mojo::JSON;
use JSON::XS;
use Encode qw( _utf8_off );
use Time::Local;

use Data::Dumper;

# проверяем наличие таблицы и указанное поле на дубликат
# my $row = $self->model('Utils')->_exists_in_table(<table>, '<id>', <value>, <exclude_id>);
#  <table>       - имя таблицы, где будем искать
#  <id>         - название поле, которое будем искать
#  <value>      - значение поля, которое будем искать
#  <exclude_id>  - исключаем указанный id
# возвращается 1/undef
sub _exists_in_table {
    my ($self, $table,  $name, $val, $exclude_id) = @_;

    return unless $name;

    # Проверяем наличие таблицы в базе данных
    my $sql = "SELECT count(*) FROM pg_catalog.pg_tables WHERE schemaname != 'information_schema' and schemaname != 'pg_catalog' and tablename = '".$table."'";

    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $row = $sth->fetchrow_hashref();
    return unless $row->{'count'};

    # проверяем поле name на дубликат
    $sql = "SELECT id FROM \"public\".".$table." WHERE \"".$name."\"='".$val."'";
    # исключаем из поиска id
    $sql .='AND "id" <> '.$exclude_id if $exclude_id;

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $row = $sth->fetchrow_hashref();

    return $row->{'id'} ? 1 : 0;
}

# включение/отключение (1/0) определенного поля в указанной таблице по id
# my $true = $self->model('Utils')->_toggle_route( <table>, <id>, <field>, <val> );
# <id>    - id записи 
# <field> - имя поля в таблице
# <val>   - 1/0
# возвращается true/false
sub _toggle {
    my ($self, $data) = @_;

    return unless ( $data || $$data{'table'} || $$data{'id'} || $$data{'fieldname'} || $$data{'value'} );

    my $result;
    my $sql ='UPDATE "public"."'.$$data{'table'}.'" SET "'.$$data{'fieldname'}.'"='.$$data{'value'}.' WHERE "id"='.$$data{'id'};

    $result = $self->{app}->pg_dbh->do($sql);
    $result = $result ? $result : 0;

    return $result;
}

# получение значения поля folder по id
# my $true = $self->model('Utils')->_folder_check( <id> );
# возвращается 1/0
sub _folder_check {
    my ( $self, $id ) = @_;

    return unless $id;

    my $sql = 'SELECT "folder" FROM "public"."settings" WHERE "id"='.$id;

    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $result = $sth->fetchrow_hashref();

    return $result->{'folder'} ? 1 : 0;
}

# получить текущее время
sub _get_time {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime( time );

    my $nice_timestamp = sprintf ( "%04d%02d%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min,$sec );
    return $nice_timestamp;
}

# перевод секунд в дату
sub _sec2date {
    my ( $self, $time ) = @_;

    unless ( $time ) {
        push @!, 'no time';
        return;
    }

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime( $time );

    my $nice_timestamp = sprintf ( "%04d%02d%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min,$sec );
    return $nice_timestamp;
}

# перевод даты в секунды
sub _date2sec {
    my ( $self, $time ) = @_;

    unless ( $time ) {
        push @!, 'no time';
        return;
    }

    # перевод времени в секунды
    $time =~ /^(\d+)-(\d+)-(\d+)\ (\d+)\:(\d+)\:(\d+)$/;
    $time = timelocal( $6, $5, $4, $3, $2-1, $1 );
}


1;