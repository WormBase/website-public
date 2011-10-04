package WormBase::API::Service::aql_wql;

use Moose;

use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';

sub index {
    # nothing to do... ?
}

sub run {
    my ($self, $params) = @_;

    my %result = (
        result_type => $params->{'result-type'},
        query_type  => $params->{'query-type'} || 'AQL',
        query       => $params->{'ql-query'},
    );

    unless ($params->{'ql-query'}) {
        return { %result, error => 'No query. Please enter a query' };
    }

    my $acedb = $self->dsn->{acedb}->dbh;
    my $data = $params->{'query-type'} eq 'AQL'
             ? $self->_run_aql($params, $acedb)
             : $self->_run_wql($params, $acedb);

    return { %result, data => $data };
}

sub _run_aql {
    my ($self, $params, $dbh) = @_;

    my $result;
    foreach my $row ($dbh->aql($params->{'ql-query'})) {
        push @$result, [
            map { $_->isObject ? $self->_pack_obj($_) : "$_" } @$row
        ];
    }
    return $result;
}

sub _run_wql {
    my ($self, $params, $dbh) = @_;

    $self->log->info("Running a WQL query");
    my $it = $dbh->fetch_many(-query => $params->{'ql-query'}); # count, offset, total ?
    # this is a raw iterator that returns objects... no good for the view

    return {
        next => sub { return $self->_pack_obj($it->next) },
    };
}

__PACKAGE__->meta->make_immutable;

1;
