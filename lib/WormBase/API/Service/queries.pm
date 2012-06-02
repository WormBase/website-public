package WormBase::API::Service::queries;

use Moose;
use namespace::autoclean -except => 'meta';

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';

# TODO: error trap on malformed queries

sub aql {
    my ($self, $c, $query) = @_;
    my $dbh = $self->dsn->{acedb}->dbh;    

    my @rows = $dbh->aql($query);
    return (\@rows, $dbh->error);
}

# params: query, [return all instead of iter?]
sub wql {
    my ($self, $c, $query, $ret_all) = @_;
    my $dbh = $self->dsn->{acedb}->dbh;
    # TODO: error trap on dbh

    if ($ret_all) {
        return [$dbh->fetch(-query => $query)];
    }
    my $api = $c->model('WormBaseAPI');
    my $it = $dbh->fetch_many(-query => $query); # count, offset, total ?

    return { next => sub { my $i = $it->next; return $api->xapian->_get_tag_info($c, "$i", $i->class, 1) if $i } };
}

sub objs2text {
    my $self = shift;
    if (@_ > 1 || ref $_[0] ne 'ARRAY') {
        die 'Expecting a single arrayref.';
    }

    return ref($_[0]->[0]) eq 'ARRAY' # multidimensional?
         ? join "\n", map { join "\t", @$_ } @{$_[0]}
         : join "\n", @{$_[0]};
}

sub objs2pack { # destructive for efficiency
    my $self = shift;
    if (@_ > 1 || ref $_[0] ne 'ARRAY' || wantarray) {
        die 'This is a destructive operation expecting a single arrayref, returning nothing.';
    }

    if (ref($_[0]->[0]) eq 'ARRAY') { # multidimensional array
        foreach (@{$_[0]}) {          # foreach row
            foreach (@$_) {           # foreach col
                $_ = $_->isObject ? $self->_pack_obj($_) : "$_";
            }
        }
    }
    else {                            # unidimensional array
        foreach (@{$_[0]}) {
            $_ = $_->isObject ? $self->_pack_obj($_) : "$_";
        }
    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;
