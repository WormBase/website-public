package WormBase::API::Object::Transposon;
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';
with    'WormBase::API::Role::Position';

=pod 

=head1 NAME

WormBase::API::Object::Transposon

=head1 SYNPOSIS

Model for the Ace ?Transposon class.

=head1 URL

http://wormbase.org/resources/motif

=cut

#######################################
#
# CLASS METHODS
#
#######################################


has 'tracks' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return {
            description => 'tracks displayed in GBrowse',
            data        => [qw/TRANSPOSON_GENES TRANSPOSONS/],
        };
    }
);

#######################################
#
# INSTANCE METHODS
#
#######################################

#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# title { }
# This method will return a data structure of the 
# title for the requested motif.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/title


# remarks {}
# Supplied by Role

sub old_name {
    my ($self) = @_;
    my $oname = $self ~~ 'Old_name';
    return {
        description => 'Old name of the transposon',
        data        => $oname && "$oname",
    };
}

sub member_of {
    my ($self) = @_;
    my $oname = $self ~~ 'Member_of';
    return {
        description => 'The transposon family this transposon belongs to',
        data        => $oname && "$oname",
    };
}

sub copy_status {
    my ($self) = @_;
    my $cs = $self ~~ 'Copy_status';
    return {
        description => 'Copy status of this transposon',
        data        => $cs ? {text => "$cs",
                        evidence => $self->_get_evidence($cs)} : undef,
    };
}

#######################################
#
# The Associations Widget
#
#######################################
has 'sequences' => (
    is  => 'ro',
    lazy => 1,
    builder => '_build_sequences',
);

sub _build_sequences {
    my $self = shift;
    my %seen;
    my @seqs = $self->object->Corresponding_CDS;
    return \@seqs if @seqs;
}


sub _build__segments {
    my ($self) = @_;
    my $sequences = $self->sequences;
    my @segments;
    my $dbh = $self->gff_dsn() || return \@segments;

    my $object = $self->object;
    my $species = $object->Species;

    eval {$dbh->segment()}; return \@segments if $@;

    # Yuck. Still have some species specific stuff here.

    if ($sequences and $species =~ /briggsae/) {
        if (@segments = map {$dbh->segment(CDS => "$_")} @$sequences
            or @segments = map {$dbh->segment(Pseudogene => "$_")} @$sequences) {
            return \@segments;
        }
    }

    if (@segments = $dbh->segment(Gene => $object)
        or @segments = map {$dbh->segment(CDS => $_)} @$sequences
        or @segments = map { $dbh->segment(Pseudogene => $_) } $object->Corresponding_Pseudogene # Pseudogenes (B0399.t10)
    ) {
        return \@segments;
    }

    return;
}

sub gene {
    my ($self) = @_;
    my @genes = map { $self->_pack_obj($_)} $self->object->Gene;
    return {
        description => 'Gene(s) associated with this transposon',
        data        => @genes ? \@genes : undef,
    };
}

sub sequence {
    my ($self) = @_;
    my @sequence = map {$self->_pack_obj($_)} @{$self->sequences} if $self->sequences;
    return {
        description => 'Sequences associated with this transposon',
        data        => @sequence ? \@sequence : undef,
    };
}

#######################################
#
# The External Links widget
#
#######################################

# xrefs {}
# Supplied by Role


__PACKAGE__->meta->make_immutable;

1;


