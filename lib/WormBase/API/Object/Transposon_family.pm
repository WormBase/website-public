package WormBase::API::Object::Transposon_family;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';



=pod

=head1 NAME

WormBase::API::Object::Transposon_class

=head1 SYNPOSIS

Model for the Ace ?Transposon_class class.

=head1 URL

http://wormbase.org/species/*

=cut


#######################################
#
# CLASS METHODS
#
#######################################

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut



=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>




# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

#######################################
#
# The Overview widget
#
#######################################

sub title{
    my ($self) = @_;
    my $object = $self->object;

    my $title = $object->Title;

    return {
        description => "The title of this transposon family",
        data => $title ? "$title" : undef
    };
}

sub description{
    my ($self) = @_;
    my $object = $self->object;

    my $desc = $object->Description;

    return {
        description => "This transposon family's description",
        data => $desc ? "$desc" : undef
    };
}

############################################################
#
# The Family Members widget
#
############################################################

sub family_members{
    my ($self) = @_;
    my $object = $self->object;

    my @transposons = $object->Family_members;
    my @rows = ();

    foreach my $transposon (@transposons){
        push( @rows, {
            id => $self->_pack_obj($transposon),
            copy_status => $transposon->Copy_status ? $transposon->Copy_status : undef
        } );
    }

    return {
        description => "Transposon members of this family",
        data => @rows ? \@rows : undef
    };
}

############################################################
#
# The Variations and Motifs widget
#
############################################################

sub variations{
    my ($self) = @_;
    my $object = $self->object;

    my %data;

    my @rows = ();
    foreach my $var ($object->In_variation){
        push( @rows, {
            id => $self->_pack_obj($var),
            species => $var->Species,
            gene => $self->_pack_obj($var->Gene)
        });
    }

    return {
        description => "Variations attached to this record",
        data => @rows ? \@rows : undef
    };
}

sub motifs{
    my ($self) = @_;
    my $object = $self->object;

    my $motifs = [$object->Associated_motif];

    my $data = $self->_pack_objects($motifs);

    return {
        description => "Motifs attached to this record",
        data => $data
    };

}

# Sample wrapper function to copy
# replace the xxx's with stuff
0 if <<'SAMPLE_FUNC';
sub xxx{
    my ($self) = @_;
    my $object = $self->object;


    return {
        description => "xxx",
        data => xxx
    };
}
SAMPLE_FUNC


############################################################
#
# PRIVATE METHODS
#
############################################################



__PACKAGE__->meta->make_immutable;

1;

