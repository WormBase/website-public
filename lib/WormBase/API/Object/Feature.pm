package WormBase::API::Object::Feature;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# Some good examples: WBsf000001, WBsf027925

=pod 

=head1 NAME

WormBase::API::Object::Feature

=head1 SYNPOSIS

Model for the Ace ?Feature class.

=head1 URL

http://wormbase.org/species/*/feature

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


#######################################
#
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub method { }
# Supplied by Role; POD will automatically be inserted here.
# << include method >>

=head3 flanking_sequences

This method will return a data structure containing sequences adjacent to the feature.

=over

=item PERL API

 $data = $model->flanking_sequences();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/flanking_sequences

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub flanking_sequences {
    my $self   = shift;
    my $object = $self->object;

    my ($seq, @flanks);
    if (my ($flanking_seq) = $self->object->Flanking_sequences) {
        ($seq, @flanks) = $flanking_seq->row;
        $seq = $self->_pack_obj($seq);
        @flanks = map {"$_"} @flanks;
    }

    return {
        description => 'sequences flanking the feature',
        data        => $seq && {
            seq    => $seq,
            flanks => \@flanks,
        },
    };
}

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>


=head3 annotation

This method will return a data structure
containing annotation info on the feature.

=over

=item PERL API

 $data = $model->annotation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/annotation

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub annotation {
    my $self   = shift;
    my $object = $self->object; 

    my $annotation;
    if ($annotation = $object->Annotation) {
        $annotation = $annotation->right;
    }
    
    return { description => 'annotation of the feature',
	     data        => $annotation && "$annotation", };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub taxonomy {}
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

=head3 sequence_ontology_terms

This method will return a data structure
containing sequence ontology terms on the feature.

=over

=item PERL API

 $data = $model->sequence_ontology_terms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/sequence_ontology_terms

B<Response example>

<div class="response-example"></div>

=back

=cut

sub sequence_ontology_terms {
    my $self   = shift;
    my $object = $self->object;

    my @terms = map {"$_"} $object->SO_term;
    return { description => 'sequence ontology terms describing the feature',
	     data        => @terms ? \@terms : undef, };
}

=head3 sequence

# TODO

=over

=item PERL API

 $data = $model->sequence();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/sequence

B<Response example>

<div class="response-example"></div>

=back

=cut

sub sequence {
    my ($self) = @_;

    return {
        description => 'TODO',
        data => $self->_pack_obj($self ~~ 'Sequence'),
    };
}

#######################################
#
# The Associations widget
#
#######################################

=head2


=head3 defined_by

This method returns a data structure detailing 
how the sequence feature was defined.

=over

=item PERL API

 $data = $model->defined_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/defined_by

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub defined_by {
    my $self   = shift;
    my $object = $self->object; 

    my @data;
    foreach my $definer ($object->Defined_by) {
    	my @definer_objs = $definer->col;
    	foreach my $definer_object (@definer_objs) {
	    my $definer_data = $self->_pack_obj($definer_object);
	    (my $label = "$definer") =~ s/Defined_by_(.)/\u$1/;
	    push @data, {
		'object' 	=> $definer_data,
		'label' 	=> "$label",
	    };
    	}
    }
    
    return { description => 'how the sequence feature was defined',
	     data        => @data ? \@data : undef, };
}

=head3 associations

This method will return a data structure listing
sequences associated with this feature.

=over

=item PERL API

 $data = $model->associations();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/associations

B<Response example>

<div class="response-example"></div>

=back

=cut

sub associations {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    my @association_types = $object->Associations;
    
    foreach my $assoc_type (@association_types) { # assoc_type is tag
    	my @association_objs = $assoc_type->col;
    	foreach my $association_object (@association_objs) {
	    my $association = $self->_pack_obj($association_object);
	    (my $label = "$assoc_type") =~ s/Associated_with_(.)/\u$1/;
	    push @data, { association 	=> $association,
			  label 	=> $label       };
	}
    }
    return { description => 'objects that define this feature',
	     data        => @data ? \@data : undef,
    };
}


=head3 binds_gene_product

This method will return a data structure containing 
the gene whose product binds the feature.

=over

=item PERL API

 $data = $model->binds_product_of_gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/binds_gene_product

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub binds_gene_product {
    my $self   = shift;
    my $object = $self->object;
    my $data = $self->_pack_objects($object->Bound_by_product_of);
    return { data => %$data ? $data : undef,
	     description => 'gene products that bind to the feature' };
}


=head3 transcription_factor

This method will return a data structure containing
the transcription factors that associate with this feature.

=over

=item PERL API

 $data = $model->transcription_factor();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A feature ID (eg WBsf000753)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/transcription_factor

B<Response example>

<div class="response-example"></div>

=back

=cut

sub transcription_factor {
    my $self   = shift;
    my $object = $self->object;

    my $factor = $object->Transcription_factor;
    return { description => 'Transcription factor of the feature',
	     data        => $factor && $self->_pack_obj($factor) };
}



__PACKAGE__->meta->make_immutable;

1;

