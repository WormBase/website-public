package WormBase::API::Object::Transposon;
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';

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
        data        => $cs && "$cs",
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


