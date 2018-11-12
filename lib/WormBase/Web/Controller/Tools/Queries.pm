package WormBase::Web::Controller::Tools::Queries;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

sub index :Path Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'tools/queries/index.tt2';
}

sub run :Path('run') :Args(0) {
    my ($self, $c) = @_;
    my $params = $c->req->params;
    my $stash  = $c->stash;

    $params->{'ql-query'} =~ s/\n\s+/ /g;

    $stash->{result_type} = $params->{'result-type'};
    $stash->{query_type}  = $params->{'query-type'} || 'AQL';
    $stash->{query}       = $params->{'ql-query'};

    # Log queries for debugging reasons.
    $c->log->info(
	$stash->{query_type}
	. ' submitted: "'
	. $stash->{query}
	. '" ; from '
	. $c->req->address);

    unless ($params->{'ql-query'}) {
        $stash->{error} = 'No query. Please enter a query';
        $stash->{template} = 'tools/queries/index.tt2';
        $c->detach;
    }

    my $qlserv = $c->model('WormBaseAPI')->_tools->{queries};
    my ($data, $error) = $params->{'query-type'} eq 'AQL'
             ? $qlserv->aql($c, $params->{'ql-query'})
             : $qlserv->wql($c, $params->{'ql-query'},
                            1);#$params->{'result-type'} ne 'HTML');
    $stash->{error} = $error;
    if ($params->{'result-type'} eq 'HTML') {
        if ($params->{'query-type'} eq 'AQL') {
            my @titles = map {$_->class} @{$data->[0]};
            $stash->{titles} = \@titles;
            $qlserv->objs2pack($data);
        }else{
        $qlserv->objs2pack($data);
        }
        $stash->{template} = 'tools/queries/index.tt2';
        $stash->{data} = $data;
    }
    else {
        my $text = $qlserv->objs2text($data);
        open my $fh, '<', \$text;

        $c->res->content_type('text/plain');
        $c->res->body($fh);
        # is the above significantly faster than the following?
        # $c->res->body($qlserv->objs2text($data);
        $c->detach;
    }
}

sub end :Private {
    my ($self, $c) = @_;
    $c->forward('/end') if $c->res->content_type ne 'text/plain';
    # do nothing for plain text.
}

__PACKAGE__->meta->make_immutable;

1;
