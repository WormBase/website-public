package WormBase::API::Object::Feature;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

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
    my $self      = shift;
    my $object    = $self->object;
    my @sequences = $object->Flanking_sequences;

    my @data = map {$_=$self->_pack_obj($_)} @sequences;
    return {
        description => 'sequences flanking the feature',
        data        => @data ? \@data : undef
    };
}

# sub taxonomy { }
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

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
    my $self   = shift;
    my $object = $self->object;
    my %data;
    my @tag_objects = qw/sequence paper author analysis/;
    foreach my $tag_object (@tag_objects) {
        my $tag = "Defined_by_" . $tag_object;
        my @data = map {$self->_pack_obj($_)} $object->$tag;
        $data{"$tag_object"} = \@data if @data;
    }
    return {
        description => 'objects that define this feature',
        data        => \%data
    };
}

=head3 associations

This method will return a data structure of the 
name for the requested position matrix.

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
    my %data;
    my @tag_objects =
      qw/gene CDS transcript pseudogene transposon variation Position_matrix operon gene_regulation expression_pattern Feature/;
    foreach my $tag_object (@tag_objects) {
        my $tag = "Associated_with_" . $tag_object;
        my @data = map { $self->_pack_obj($_) } $object->$tag;
        $data{"$tag_object"} = \@data if @data;
    }
    return {
        description => 'objects that define this feature',
        data        => \%data
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
    my @genes  = $object->Bound_by_product_of;
    my @data   = map { $self->_pack_obj( $_, $_->Public_name ) } @genes;
    return {
        description => 'gene products thtat bind this feature',
        data        => @data ? \@data : undef
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
    my $self                 = shift;
    my $object               = $self->object;
    my $transcription_factor = $object->Transcription_factor;

    my $data = $self->_pack_obj($transcription_factor);
    return {
        description => 'transcription factor that binds the feature',
        data        => $data ? $data : undef
    };
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
    my $self   = shift;
    my $object = $self->object;
    my $data   = map { $self->_pack_obj($_) } $object->Annotation;
    return {
        description => 'annotations on the feature',
        data        => $data ? $data : undef
    };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

1;
