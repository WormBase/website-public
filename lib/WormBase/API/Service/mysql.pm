package WormBase::API::Service::mysql;

use Moose;
use DBI;
use DBD::mysql;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Ref',       # Could also be a seq feature store, eh?
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
    my $dsn = "DBI:mysql:database=".$self->source.";user='".$self->user."';host=".$self->host;
    return DBI->connect($dsn);
}


1;
