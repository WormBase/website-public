package WormBase::API::Service::Elasticsearch;

use base qw/Catalyst::Model/;
use Moose;
use JSON;
use URI::Escape;

use strict;

# base_url of the search web service running off elasticsearch
has 'base_url' => (isa => 'Str', is => 'rw');


has '_api' => (
    is => 'ro',
);

# Main search - returns a page of results
sub search {
    my ($self, $args) = @_;

    my $fixed_args = $self->_fix_args_paper_type($args);

    my $url = $self->_get_elasticsearch_url("/search", $fixed_args);
    my $resp = HTTP::Tiny->new->get($url);

    if ($resp->{success}) {
        return (decode_json($resp->{content}));
    } else {
        my $resp_code = $resp->{status};
        return (undef, "$url failed with $resp_code");
    }
}

# Autocomplete - returns 10 results
sub autocomplete {
    my ($self, $q, $type) = @_;

    my $url = $self->_get_elasticsearch_url("/autocomplete", {
        type => $type,
        query => $q
    });
    my $resp = HTTP::Tiny->new->get($url);

    if ($resp->{success}) {
        return (decode_json($resp->{content}));
    }
    return undef;
}


sub _get_elasticsearch_url {
    my ($self, $path, $args) = @_;
    my @paramParts = ();
    while(my($k, $v) = each %$args) {
        if ($v) {
            my $v_escaped = uri_escape($v);
            push @paramParts, "$k=$v_escaped";
        }
    }
    return $self->base_url . "/integration$path?" . join('&', @paramParts);
}


# This will fetch the object from Xapian and return a hashref containing the id, label and class (similar to _pack_obj)
# label - return the correct label (important for protein and interaction)
#       - default returns the label stored in Xapian
# fill - return more than just the name tag, all info from search results included
# footer - if a filled tag is returns, will insert this info as a footer

sub fetch {
    my ($self, $args) = @_;
    my $query = $args->{query};
    my $fill = $args->{fill};
    my $footer = $args->{footer};
    my $label = $args->{label};


    my $url = $self->_get_elasticsearch_url("/search-exact", $args);

    my $resp = HTTP::Tiny->new->get($url);
    if ($resp->{success} && $resp->{content}) {
        my $json = decode_json($resp->{content});
        my $non_empty_json = scalar keys %$json;
        if ($fill || $footer || $label || $non_empty_json) {
            return $json;
        }
    }
    return undef;
}


# Returns a random filled object from the database

sub random {
    my ($self) = @_;

    my $url = $self->_get_elasticsearch_url("/random");
    my $resp = HTTP::Tiny->new->get($url);
    if ($resp->{success} && $resp->{content}) {
        return decode_json($resp->{content});
    }
    return undef;
}

# Estimates the search results amount - accurate up to 500

sub count_estimate {
    my ($self, $q, $type, $species_or_paper) = @_;

    my $fixed_args = $self->_fix_args_paper_type({
        type => $type,
        query => $q,
        species => $species_or_paper
    });

    my $url = $self->_get_elasticsearch_url("/count", $fixed_args);

    my $resp = HTTP::Tiny->new->get($url);

    if ($resp->{success}) {
        return decode_json($resp->{content})->{count};
    }
    return undef;
}

# args may need to be fixed as client uses species param to send paper_type
# this will need to be fixed there.
sub _fix_args_paper_type {
    my ($self, $args) = @_;
    my $type = $args->{type};
    my $species_or_paper = $args->{species};

    my %fixed_args;
    if (($type && $type =~ m/paper/) && ($species_or_paper)) {
        my $paper_type = $self->_api->config->{sections}->{resources}->{paper}->{paper_types}->{$species_or_paper};
        if (defined $paper_type) {
            %fixed_args = (%$args, species => undef, paper_type => $species_or_paper);
        }
    }

    return %fixed_args ? \%fixed_args : $args;
}


1;
