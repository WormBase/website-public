package WormBase::API::Service::mysql;

use Moose;
use DBI;
use DBD::mysql;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Ref',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
);

with 'WormBase::API::Role::Service';

has 'database' => (
    is  => 'rw',
    isa => 'Str',
);

sub _build_function {
    return 'get connection to MySQL database';
}

sub ping {
  my $self = shift;
  return @_;

}

sub connect {
    my $self = shift;
    my $source = $self->source;
    my $pass   = $self->pass;
    my $host   = $self->host;
    my $user   = $self->user;

    my $dsn = "DBI:mysql:database=$source;host=$host";
    my $db = DBI->connect($dsn,$user,$pass);
    return $db;
}


1;
