package WormBase::API::Object::Pcr_oligo;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# TODO:
#  Split according to widgets? (May be hard for this aggregated class)


=pod

=head1 NAME

WormBase::API::Object::Pcr_oligo

=head1 SYNPOSIS

Aggregate model for the Ace ?PCR_product, ?Oligo_set, and ?Oligo classes.

=head1 URL

http://wormbase.org/resources/pcr_oligo

=head1 METHODS/URIs

=cut


has '_segment' => (
	is		 => 'ro',
	required => 1,
	lazy	 => 1,
	default	 => sub {
		my ($self) = @_;
		my $object = $self->object;
		my $class = $object->class;
		$class .= ':reagent' if $class eq 'Oligo_set';
		return $self->gff_dsn->segment($class => $object);
	},
);

has '_oligos' => (
	is => 'ro',
	required => 1,
	lazy => 1,
	default => sub {
		my ($self) = @_;
		return $self ~~ '@Oligo';
	},
);

has '_object_class' => (
	is => 'ro',
	required => 1,
	default => sub {
		my ($self) = @_;
		(my $class = $self ~~ 'class') =~ s/_/ /g;
		return $class;
	},
);

################################################################################
# Methods pertaining to all three classes
################################################################################

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 canonical_parent

!!!Description

=head4 PERL API

 $data = $model->canonical_parent();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/canonical_parent

=head5 Response example

<div class="response-example"></div>

=cut


sub canonical_parent {
	my ($self) = @_;

	return {
		description => 'Canonical parent of this ' . $self->_object_class,
		data		=> $self->_pack_obj($self ~~ 'Canonical_parent'),
	};
}

=head3 oligos

!!!Description

=head4 PERL API

 $data = $model->oligos();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/oligos

=head5 Response example

<div class="response-example"></div>

=cut


sub oligos {
	my ($self) = @_;

	my @data;
	foreach (@{$self->_oligos}) {
		my $seq = $_->Sequence;
		push @data, {
			obj => $self->_pack_obj($_),
			sequence => $seq && "$seq",
		};
	}

	return {
		description => 'Oligos of this' . $self->_object_class,
		data		=> @data ? \@data : undef,
	};
}

=head3 overlapping_genes

!!!Description

=head4 PERL API

 $data = $model->overlapping_genes();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlapping_genes

=head5 Response example

<div class="response-example"></div>

=cut

sub overlapping_genes {
	my ($self) = @_;
	my %gene_info = map {
        my $name = $_->info->name;
        $name => {
            id    => $name,
            label => $name,
            class => 'Gene',
        }
    } $self->_overlapping_genes($self->_segment);

	return {
		description => 'Overlapping genes of this ' . $self->_object_class,
		data		=> %gene_info ? \%gene_info : undef,
	};
}

=head3 overlaps_CDS

!!!Description

=head4 PERL API

 $data = $model->overlaps_CDS();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_CDS

=head5 Response example

<div class="response-example"></div>

=cut

sub overlaps_CDS {
	my ($self) = @_;
	my $CDS = $self->_pack_objects($self ~~ '@Overlaps_CDS');

	return {
		description => 'CDS\'s that this ' . $self->_object_class . ' overlaps',
		data		=> %$CDS ? $CDS : undef,
	};
}

=head3 overlaps_transcript

!!!Description

=head4 PERL API

 $data = $model->overlaps_transcript();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_transcript

=head5 Response example

<div class="response-example"></div>

=cut


sub overlaps_transcript {
	my ($self) = @_;
	my $transcripts = $self->_pack_objects($self ~~ '@Overlaps_Transcript');

	return {
		description => 'Transcripts that this ' . $self->_object_class . ' overlaps',
		data		=> %$transcripts ? $transcripts : undef,
	};
}

=head3 overlaps_pseudogene

!!!Description

=head4 PERL API

 $data = $model->overlaps_pseudogene();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_pseudogene

=head5 Response example

<div class="response-example"></div>

=cut

sub overlaps_pseudogene {
	my ($self) = @_;
	my $pseudogenes = $self->_pack_objects($self ~~ '@Overlaps_Pseudogene');

	return {
		description => 'Pseudogenes that this ' . $self->_object_class . ' overlaps',
		data		=> %$pseudogenes ? \$pseudogenes : undef,
	};
}

=head3 overlaps_variation

!!!Description

=head4 PERL API

 $data = $model->overlaps_variation();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_variation

=head5 Response example

<div class="response-example"></div>

=cut

sub overlaps_variation {
	my ($self) = @_;
	my $variations = $self->_pack_objects($self ~~ '@Overlaps_Variation');

	return {
		description => 'Variations that this ' . $self->_object_class . ' overlaps',
		data		=> %$variations ? \$variations : undef,
	};
}

=head3 on_orfeome_project

!!!Description

=head4 PERL API

 $data = $model->on_orfeome_project();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/on_orfeome_project

=head5 Response example

<div class="response-example"></div>

=cut


# classic site note: MRC Genesevice and Open Biosystems links are invalid now
sub on_orfeome_project {
	my ($self) = @_;

	$self->object->name =~ /^mv_(.*)/;
	my $data = $1;

	return {
		description => 'Finding this ' . $self->_object_class . ' on the ORFeome project',
		data		=> $data,
	};
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 microarray_results

!!!Description

=head4 PERL API

 $data = $model->microarray_results();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/microarray_results

=head5 Response example

<div class="response-example"></div>

=cut


sub microarray_results {
	my ($self) = @_;

	my $results = $self->_pack_objects($self ~~ '@Microarray_results');
	return {
		description => 'Microarray results involving this ' . $self->_object_class,
		data => %$results ? $results : undef,
	};
}

=head3 segment

!!!Description

=head4 PERL API

 $data = $model->segment();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/segment

=head5 Response example

<div class="response-example"></div>

=cut


sub segment {
	my ($self) = @_;

	my %data;
	if (my $segment = $self->_segment) {
		%data = map { $_ => $segment->$_ }
		        qw(refseq ref abs_start abs_stop start stop length dna);
	}

	return {
		description => 'Sequence/segment data about this ' . $self->_object_class,
		data		=> %data ? \%data : undef,
	};
}


########################################
## Methods pertaining to PCR_product
########################################


=head3 amplified

!!!Description

=head4 PERL API

 $data = $model->amplified();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/amplified

=head5 Response example

<div class="response-example"></div>

=cut

sub amplified {
	my ($self) = @_;

	my $amplified = $self ~~ 'Amplified';
	return {
		description => 'Whether this PCR product is amplified',
		data		=> $amplified && $amplified->name,
	};
}

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

=head3 SNP_loci

!!!Description

=head4 PERL API

 $data = $model->SNP_loci();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/SNP_loci

=head5 Response example

<div class="response-example"></div>

=cut

sub SNP_loci {
	my ($self) = @_;

	my @loci = map {$self->_pack_obj($_)} @{$self ~~ '@SNP_locus'};
	return {
		description => 'SNP loci for this PCR product',
		data		=> @loci ? \@loci : undef,
	};
}

=head3 assay_conditions

!!!Description

=head4 PERL API

 $data = $model->assay_conditions();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/assay_conditions

=head5 Response example

<div class="response-example"></div>

=cut

sub assay_conditions {
	my ($self) = @_;
	my $conditions = $self ~~ 'Assay_conditions';

	return {
		description => 'Assay conditions for this PCR product',
		data		=> $conditions && $conditions->name,
	};
}

########################################
## Methods pertaining to Oligo_set
########################################

########################################
## Methods pertaining to Oligo
########################################


########################################
## Private Methods
########################################

sub _overlapping_genes {
	my ($self, @segments) = @_;
	return map { $_->features('CDS:curated') } @segments;
}


1;
