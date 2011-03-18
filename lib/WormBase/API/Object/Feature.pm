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

http://wormbase.org/species/feature

=head1 METHODS/URIs

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
    my ($self) = @_;

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

=head3 defined_by

This method will return a data structure 

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
    my ($self) = @_;

    my %defined_by;
    foreach my $definer (@{$self ~~ '@Defined_by'}) {
        my $definer_objs = $self->_pack_objects([$definer->col]);
        (my $label = "$definer") =~ s/Defined_by_(.)/\u$1/;
        $defined_by{$label} = $definer_objs;
    }

    return {
        description => 'objects that define this feature',
        data        => %defined_by ? \%defined_by : undef,
    };
}

=head3 associations

This method will return a data structure of the 
TODO

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
    my ($self) = @_;

    my %associations;
    foreach my $assoc_type (@{$self ~~ '@Associations'}) { # assoc_type is tag
        my %assoc_objs = map { $_ => {
            obj => $self->_pack_obj($_),
            # evidence => $_->right, # TODO: do something with evidence
        }} $assoc_type->col;
        (my $label = "$assoc_type") =~ s/Associated_with_(.)/\u$1/;
        $associations{$label} = \%assoc_objs;
    }

    return {
        description => 'objects that define this feature',
        data        => %associations ? \%associations : undef,
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
    my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Bound_by_product_of'); # TODO: evidence?
    return {
        description => 'gene products that bind this feature',
        data        => %$data ? $data: undef,
    };
}

=head3 transcription_factor

This method will return a data structure containing
the transcription factors associated with this feature.

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
    my ($self) = @_;

    my $factor = $self ~~ 'Transcription_factor';
    return {
        description => 'Transcription factor of the feature',
        data        => $factor && $self->_common_name($factor), # no TFactor model
    }
}

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
    my ($self) = @_;

    my $annotation;
    if ($annotation = $self ~~ 'Annotation') {
        $annotation = $annotation->right;
    }

    return {
        description => 'Annotation of the feature',
        data        => $annotation && "$annotation",
    };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 so_terms

This method will return a data structure
containing sequence ontology terms on the feature.

=over

=item PERL API

 $data = $model->so_terms();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/so_terms

B<Response example>

<div class="response-example"></div>

=back

=cut

sub so_terms {
    my ($self) = @_;

    my @terms = map {"$_"} @{$self ~~ '@SO_term'};
    return {
        description => 'SO term(s) of the feature',
        data        => @terms ? \@terms : undef,
    };
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

1;
