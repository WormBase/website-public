package WormBase::Web::Controller::Tools::blast_blat;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

sub index :Path Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'tools/blast_blat/index.tt2';

    my $api = $c->model('WormBaseAPI')->_tools->{blast_blat};
    $c->stash->{blast_databases} = $api->blast_databases;
}


sub end :Private {
    my ($self, $c) = @_;
    $c->forward('/end') if $c->res->content_type ne 'text/plain';
    # do nothing for plain text.
}

__PACKAGE__->meta->make_immutable;

1;
