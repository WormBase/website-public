package WormBase::API::Object::Variation;

use Moose;
use Bio::Graphics::Browser2::Markup;
use List::Util qw(first);

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';

# TODO:
# Mapping data
# Marked_rearrangement


=pod

=head1 NAME

WormBase::API::Object::Variation

=head1 SYNPOSIS

Model for the Ace ?Variation class.

=head1 URL

http://wormbase.org/species/*/variation

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
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub other_names { }
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>


# THIS METHOD IS PROBABLY DEPRECATED
sub cgc_name {
    my ($self) = @_;

    return {
        description => 'The Caenorhabditis Genetics Center (CGC) name for the variation',
        data        => $self->_pack_obj($self ~~ 'CGC_name'),
    };
}


=head3 variation_type

This method returns a data structure containing
the broad classification of the variation, eg SNP,
Allele, etc.

=over

=item PERL API

 $data = $model->variation_type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/variation_type

B<Response example>

<div class="response-example"></div>

=back

=cut 

# A unified classification of the type of variation
# general class: SNP, allele, etc
# physical class: deletion, insertion, etc
sub variation_type {
    my ($self) = @_;
    my $object = $self->object;

    # the following is contrary to what is done in the classic code...
    # is this the correct behaviour?
    my @types;
    if ($object->KO_consortium_allele(0)) {
        push @types,"Knockout Consortium allele";
    }

    if ($object->SNP) {
        my $type = 'Polymorphism';
        $type .= '; RFLP' if $object->RFLP;
        $type .= $object->Confirmed_SNP ? ' (confirmed)' : ' (predicted)';
        push @types, $type;
    }

    if ($object->Natural_variant) {
        push @types, 'Natural variant';
    }

    if (@types == 0) {
        push @types,'Allele';
    }

    my $physical_type = $object->Type_of_mutation; # what about text?
    if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
        $physical_type = 'Transposon insertion';
    }

    return {
        description => 'the general type of the variation',
        data        => {
            general_class  => @types ? \@types : undef,
            physical_class => $physical_type && "$physical_type",
        },
    };
}


# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub status {}
# Supplied by Role; POD will automatically be inserted here.
# << include status >>


############################################################
#
# The External Links widget
#
############################################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>

=head3 source_database

This method returns a data structure containing
the source database of the variation.

=over

=item PERL API

 $data = $model->source_database();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/source_database

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Q: How is this used? Is this used in conjunction with the various KO Consortium tags?
# CAN BE REPLACED WITH << xrefs >>
sub source_database {
    my ($self) = @_;

    my ($remote_url,$remote_text);
    if (my $source_db = $self ~~ 'Database') {
        my $name = $source_db->Name;
        my $id   = $self->object->Database(3);

        # Using the URL constructor in the database (for now)
        # TODO: Should probably pull these out and keep URLs in config
        my $url  = $source_db->URL_constructor;
        # Create a direct link to the external site

        if ($url && $id) {
            $name =~ s/_/ /g;
            $remote_url = sprintf($url,$id);
            $remote_text = "$name";
        }
    }

    return {
        description => 'remote source database, if known',
        data        => {
            remote_url => $remote_url,
            remote_text => $remote_text,
        }
    };
}






############################################################
#
# The Genetics Widget
#
############################################################

=head2 Genetics

=head3 gene_class

This method returns a data structure containing
the gene class that the gene has been assigned to, for
example "unc", "vab", or "egl".

=over

=item PERL API

 $data = $model->gene_class();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/gene_class

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub gene_class {
    my ($self) = @_;

    return {
        description => 'the class of the gene the variation falls in, if any',
        data        => $self->_pack_obj($self ~~ 'Gene_class'),
    };
}

=head3 corresponding_gene

This method returns a data structure containing
the gene that the variation is contained in, if any.

=over

=item PERL API

 $data = $model->corresponding_gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/corresponding_gene

B<Response example>

<div class="response-example"></div>

=back

=cut 

# This should return the CGC name, sequence name (if name), and WBGeneID...
sub corresponding_gene {
    my ($self) = @_;

    return {
        description => 'gene in which this variation is found (if any)',
        data        => $self->_pack_obj($self ~~ 'Gene'),
    };
}

=head3 reference_allele

This method returns a data structure containing
the reference allele for the corresponding gene
of the current variation.

=over

=item PERL API

 $data = $model->reference_allele();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/reference_allele

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub reference_allele {
    my ($self) = @_;

    my $allele = eval {$self->object->Gene->Reference_allele};
    return {
        description => 'the reference allele for the containing gene (if any)',
        data        => $allele && $self->_pack_obj($allele),
    };
}

=head3 other_alleles

This method returns a data structure containing
other alleles of the corresponding gene of the
variation.

=over

=item PERL API

 $data = $model->other_alleles();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/other_alleles

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub other_alleles {
    my ($self) = @_;

    my $name = $self ~~ 'name';
    my $data;
    foreach my $allele (eval {$self->Gene->Allele(-fill => 1)}) {
        next if $allele eq $name;

        my $packed_allele = $self->_pack_obj($allele);

        if ($allele->SNP) {
            push @{$data->{data}->{polymorphisms}}, $packed_allele;
        }
        elsif ($allele->Sequence || $allele->Flanking_sequences) {
            push @{$data->{data}->{sequenced_alleles}}, $packed_allele;
        }
        else {
            push @{$data->{data}->{sequenced_alleles}}, $packed_allele;
        }
    }

    return {
        description => 'other alleles of the containing gene (if known)',
        data        => $data,
    };
}

=head3 strains

This method returns a data structure containing
strains carrying the variation.

=over

=item PERL API

 $data = $model->strains();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/strains

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub strains {
    my $self   = shift;
    my $object = $self->object;    
    my @data;
    my %count;
    foreach ($object->Strain) {
	my @genes = $_->Gene;
	my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;
	
	my $packed = $self->_pack_obj($_);
	
	# All of the counts can go away if
	# we discard the venn diagram.
	push @{$count{total}},$packed;
	push @{$count{available_from_cgc}},$packed if $cgc;
	
	if (@genes == 1 && !$_->Transgene){
	    push @{$count{carrying_gene_alone}},$packed;
	    if ($cgc) {
		push @{$count{carrying_gene_alone_and_cgc}},$packed;
	    }	    
	} else {
	    push @{$count{others}},$packed;
	}       
	
	my $genotype = $_->Genotype;
	push @data, { strain   => $packed,
		      cgc      => $cgc ? 'yes' : 'no',
		      genotype => "$genotype",
	};
    }
    
    return { description => 'strains carrying gene',
	     data        => \@data,
	     count       => \%count };
}


=head3 rescued_by_transgene
    
This method returns a data structure containing
transgenes (if any) that rescue the mutant phenotype
of the variation.

=over

=item PERL API

 $data = $model->rescued_by_transgene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/rescued_by_transgene

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub rescued_by_transgene {
    my ($self) = @_;
    
    return {
        description => 'transgenes that rescue phenotype(s) caused by this variation',
        data        => $self->_pack_obj($self ~~ 'Rescued_by_Transgene'),
    };
}




############################################################
#
# The Isolation Widget
#
############################################################

=head2 Isolation

=cut

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

=head3 external_source

This method returns a data structure containing
the external source of the variation.

=over

=item PERL API

 $data = $model->external_source();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/external_source

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub external_source {
    my ($self) = @_;

    my $hash;
    my ($remote_url,$remote_text);
    foreach my $dbsnp (@{$self ~~ '@Database'}) {
        next unless $dbsnp eq 'dbSNP_ss';
        $remote_text = $dbsnp->right(2);
        my $url  = $dbsnp->URL_constructor;
        # Create a direct link to the external site

        if ($url && $remote_text) {
            # 	    (my $name = $dbsnp) =~ s/_/ /g;
            $hash->{$dbsnp} = {
                remote_url => sprintf($url, $remote_text),
                remote_text => "dbSNP: $remote_text",
            };
        }
    }

    return {
        description => 'dbSNP ss#, if known',
        data        => $hash,
    };
}



=head3 isolated_by_author

This method returns a data structure containing
the author that isolated the variation.

=over

=item PERL API

 $data = $model->isolated_by_author();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_by_author

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub isolated_by_author {
    my ($self) = @_;

    return {
        description => 'the author credited with generating the mutation',
        data        => $self->_pack_obj($self ~~ 'Author'),
    };
}

=head3 isolated_by

This method returns a data structure containing
the atuhor or person that isolated the variation.

=over

=item PERL API

 $data = $model->isolated_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_by

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub isolated_by {
    my ($self) = @_;

    return {
        description => 'the person credited with generating the mutation',
        data        => $self->_pack_obj($self ~~ 'Person'),
    };
}

=head3 date_isolated

This method returns a data structure containing
the date the variation was isolated, if known.

=over

=item PERL API

 $data = $model->date_isolated();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/date_isolated

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub date_isolated {
    my ($self) = @_;

    my $date = $self ~~ 'Date';
    return {
        description => 'date the mutation was isolated',
        data        => $date && "$date",
    };
}

=head3 mutagen

This method returns a data structure containing
the mutagen used to generate the variation, if known.

=over

=item PERL API

 $data = $model->mutagen();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/mutagen

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub mutagen {
    my ($self) = @_;

    my $mutagen = $self ~~ 'Mutagen';
    return {
        description => 'mutagen used to generate the variation',
        data        => $mutagen && "$mutagen",,
    };
}

=head3 isolated_via_forward_genetics

This method returns a data structure describing
if the mutation was isolated via forward genetics.

=over

=item PERL API

 $data = $model->isolated_via_forward_genetics();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_via_forward_genetics

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Q: What are the contents of this tag?
sub isolated_via_forward_genetics {
    my ($self) = @_;

    return {
        description => 'was the mutation isolated by forward genetics?',
        data        => $self ~~ 'Forward_genetics',
    };
}

=head3 isolated_via_reverse_genetics

This method returns a data structure describing
if the variation was isolated by reverse genetics.

=over

=item PERL API

 $data = $model->isolated_via_reverse_genetics();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_via_reverse_genetics

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Q: what are the contents of this tag?
sub isolated_via_reverse_genetics {
    my ($self) = @_;

    return {
        description => 'was the mutation isolated by reverse genetics?',
        data        => $self ~~ 'Reverse_genetics',
    };
}

=head3 transposon_excision

This method returns a data structure describing
if the variation was isolated by a transposon excision.

=over

=item PERL API

 $data = $model->transposon_excision();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/transposon_excision

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transposon_excision {
    my ($self) = @_;

    my $transposon = $self ~~ 'Transposon_excision';
    return {
        description => 'was the variation generated by a transposon excision event, and if so, of which family?',
        data        => $transposon && "$transposon",
    };
}

=head3 transposon_insertion

This method returns a data structure describing
if the variation was generated by a transposon insertion event.

=over

=item PERL API

 $data = $model->transposon_insertion();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/transposon_insertion

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transposon_insertion {
    my ($self) = @_;

    my $transposon = $self ~~ 'Transposon_insertion';
    return {
        description => 'was the variation generated by a transposon insertion event, and if so, of which family?',
        data        => $transposon && "$transposon",
    };
}



=head3 derived_from

This method returns a data structure containing
what variation the variation in question was derived from.

=over

=item PERL API

 $data = $model->derived_from();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/derived_from

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub derived_from {
    my ($self) = @_;
    
    return {
        description => 'variation from which this one was derived',
        data        => $self->_pack_obj($self ~~ 'Derived_from'),
    };
}



=head3 derivative

This method returns a data structure containing
variations derived from this variation.

=over

=item PERL API

 $data = $model->derivative();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/derivative

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub derivative {
    my ($self) = @_;

    my $derivatives = $self->_pack_objects($self ~~ '@Derivative');
    return {
        description => 'variations derived from this variation',
        data => %$derivatives ? $derivatives : undef,
    };
}




############################################################
#
# The Location Widget
#
############################################################

=head2 Location

=cut

# sub genomic_position {}
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_position >>

# sub genetic_position {}
# Supplied by Role; POD will automatically be inserted here.
# << include genetic_position >>

# sub genomic_image {}
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_image >>

sub _build_genomic_position {
    my ($self) = @_;

    my $adjustment = sub {
        my ($abs_start, $abs_stop) = @_;
        return $abs_stop - $abs_start < 100
             ? ($abs_start - 50, $abs_stop + 50)
             : ($abs_start, $abs_stop);

    };

    my @positions = $self->_genomic_position($self->_segments, $adjustment);
    return {
        description => 'The genomic location of the sequence',
        data        => @positions ? \@positions : undef,
    };
}

sub _build_tracks {
    my ($self) = @_;
    return {
        description => 'tracks displayed in GBrowse',
        data => [ $self->_parsed_species eq 'c_elegans'
                  ? qw(CG CANONICAL Allele TRANSPOSONS) : 'WBG' ],
    };
}

sub _build_genomic_image {
    my ($self) = @_;

    # TO DO: MOVE UNMAPPED_SPAN TO CONFIG
    my $UNMAPPED_SPAN = 10000;

    my $position;
    if (my $segment = $self->_segments->[0]) {
        my ($ref,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($segment);

        # Generate a link to the genome browser
        # This is hard-coded and needs to be cleaned up.
        # Is the segment smaller than 100? Let's adjust
        my ($low,$high);
        if ($abs_stop - $abs_start < 100) {
            $low  = $abs_start - 50;
            $high = $abs_stop  + 50;
        }
        else {
            $low  = $abs_start;
            $high = $abs_stop;
        }

        my $split  = $UNMAPPED_SPAN / 2;
        ($segment) = $self->gff_dsn->segment($ref,$low-$split,$low+$split);

        ($position) = $self->_genomic_position([$segment || ()]);
    }

    return {
        description => 'The genomic location of the sequence to be displayed by GBrowse',
        data        => $position,
    };
}

sub _build__segments {
    my ($self) = @_;
    my $obj    = $self->object;

    return [$self->gff_dsn->segment($obj->class => $obj)];
}


############################################################
#
# MOLECULAR_DETAILS
#
############################################################

=head3 sequencing_status

This method returns a data structure containing
the sequencing status of the variation.

=over

=item PERL API

 $data = $model->sequencing_status();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/sequencing_status

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub sequencing_status {
    my ($self) = @_;
    
    my $status = $self ~~ 'SeqStatus';
    return {
        description => 'sequencing status of the variation',
        data        => $status && "$status",
    };
}


=head3 nucleotide_change

This method returns a data structure containing
both the wild type and mutant variants of the 
variation, if known.

=over

=item PERL API

 $data = $model->nucleotide_change();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/nucleotide_change

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Returns a data structure containing
# wild type sequence - the wild type (or reference) sequence
# mutant sequence - the mutant sequence
# wild type label - the source (background) of the wild type sequence
# mutant label    - the source (background) of the mutation

sub nucleotide_change {
    my ($self) = @_;
    
    # Nucleotide change details (from ace)
    my $variations = $self->_compile_nucleotide_changes($self->object);
    return {
        description => 'raw nucleotide changes for this variation',
        data        => @$variations ? $variations : undef,
    };
}

=head3 flanking_sequences

This method returns a data structure containing
sequences immediately 5' and 3' of the variation,
if known.

=over

=item PERL API

 $data = $model->flanking_sequences();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/flanking_sequences

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub flanking_sequences {
    my ($self) = @_;
    my $object = $self->object;
    
    my $left_flank  = $object->Flanking_sequences(1);
    my $right_flank = $object->Flanking_sequences(2);
    
    return {
        description => 'sequences flanking the variation',
        data        => {
            left_flank  => $left_flank && "$left_flank",
            right_flank => $right_flank && "$right_flank",
        },
    };
}

=head3 cgh_deleted_probes

This method returns a data structure containing
deleted probes detected by comparative genome
hybridization (CGH).

=over

=item PERL API

 $data = $model->cgh_deleted_probes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/cgh_deleted_probes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub cgh_deleted_probes {
    my ($self) = @_;
    my $object = $self->object;
    
    my $left_flank  = $object->CGH_deleted_probes(1);
    my $right_flank = $object->CGH_deleted_probes(2);
    
    return {
        description => 'probes used for CGH of deletion alleles',
        data        => {
            left_flank  => $left_flank && "$left_flank",
            right_flank => $left_flank && "$right_flank",
        },
    };
}

=head3 context

This method returns a data structure containing
strings reconstructing the sequence of the variation
in genomic context (if known).

=over

=item PERL API

 $data = $model->context();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/context

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Show the variation in context.
sub context {
    my ($self) = @_;
    
    my $name   = $self ~~ 'Public_name';
    
    # Display a formatted string that shows the mutation in context
    my $flank = 250;
    my ($wt,$mut,$wt_full,$mut_full,$debug)  = $self->_build_sequence_strings;
    return {
        description => 'wildtype and mutant sequences in an expanded genomic context',
        data        => {
            wildtype_fragment => $wt,
            wildtype_full     => $wt_full,
            mutant_fragment   => $mut,
            mutant_full       => $mut_full,
            wildtype_header   => "> Wild type N2, with $flank bp flanks",
            mutant_header     => "> $name with $flank bp flanks"
        },
    };
}

=head3 deletion_verification

This method returns a data structure containing
whether or not a deletion allele has been verified.

=over

=item PERL API

 $data = $model->deletion_verification();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/deletion_verification

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub deletion_verification {
    my ($self) = @_;
    
    return {
        description => 'the method used to verify deletion alleles',
        data        => $self ~~ 'Deletion_verification',
    };
}

=head3 features_affected

This method returns a data structure containing
features affected by the variation.

=over

=item PERL API

 $data = $model->features_affected();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/features_affected

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Display the position of the variation within a number of features
# Foreach item that the variation is known to affect, display a table
# with variation coordinates relative to the feature
sub features_affected {
    my ($self) = @_;
    my $object = $self->object;
    
    # This is mostly constructed from Molecular_change hash associated with
    # tags in Affects, with the exception of Clone and Chromosome
    my $affects = {};
    
    # Clone and Chromosome are calculated, not provided in the DB.
    # Feature and Interactor are handled a bit differently.
    
    foreach my $type_affected ($object->Affects) {
        foreach my $item_affected ($type_affected->col) { # is a subtree
            my $affected_hash = $affects->{$type_affected}->{$item_affected} = $self->_pack_obj($item_affected);
	    
            # Genes ONLY have gene
            if ($type_affected eq 'Gene') {
                $affected_hash->{entry}++;
                next;
            }

            my ($protein_effects, $location_effects, $do_translation)
                = $self->_retrieve_molecular_changes($item_affected);

            $affected_hash->{protein_effects}  = $protein_effects if %$protein_effects;
            $affected_hash->{location_effects} = $location_effects if %$location_effects;

            # Display a conceptual translation, but only for Missense and
            # Nonsense alleles within exons
            if ($type_affected eq 'Predicted_CDS' && $do_translation) {
                # $do_translation implies $protein_effects
                if ($protein_effects->{Missense}) {
                    my ($wt_snippet,$mut_snippet,$wt_full,$mut_full)
                        = $self->_do_simple_conceptual_translation(
                            $item_affected,
                            $protein_effects->{Missense}
                          );
                    $affected_hash->{wildtype_conceptual_translation} = $wt_full;
                    $affected_hash->{mutant_conceptual_translation}   = $mut_full;
                }
                # what about the manual translation?
            }

            # Get the coordinates in absolute coordinates
            # the coordinates of the containing feature,
            # and the coordinates of the variation WITHIN the feature.
            @{$affected_hash}{qw(abs_start abs_stop fstart fstop start stop)}
                 = $self->_fetch_coords_in_feature($type_affected,$item_affected);
        }
    } # end of FOR loop

    # Clone and Chromosome are not provided in the DB - we calculate them here.
    foreach my $type_affected (qw(Clone Chromosome)) {
        my @affects_this = $type_affected eq 'Clone'      ? $object->Sequence
                         : $type_affected eq 'Chromosome' ? eval {($object->Sequence->Interpolated_map_position)[0]}
                         :                        ();

        foreach (@affects_this) {
            next unless $_;
            my $hash = $affects->{$type_affected}->{$_} = $self->_pack_obj($_);

            @{$hash}{qw(abs_start abs_stop fstart fstop start stop)}
                = $self->_fetch_coords_in_feature($type_affected,$_);
        }
    }

    return {
        description => 'genomic features affected by this variation',
        data        => %$affects ? $affects : undef,
    };
}

=head3 possibly_affects

This method returns a data structure containing
features that are possibly -- but haven't been 
demonstrated to -- be affected by the variation.

=over

=item PERL API

 $data = $model->possibly_affects();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/possibly_affects

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub possibly_affects {
    my ($self) = @_;

    return {
        description => 'genes that may be affected by the variation but have not been experimentally tested',
        data        => $self->_pack_obj($self ~~ 'Possibly_affects'),
    };
}

=head3 flanking_pcr_products

This method returns a data structure containing
pcr products that flank the variation.

=over

=item PERL API

 $data = $model->flanking_pcr_products();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/flanking_pcr_products

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub flanking_pcr_products {
    my ($self) = @_;

    my $packed = $self->_pack_objects($self ~~ '@PCR_product');
    return {
        description => 'PCR products that flank the variation',
        data        => %$packed ? $packed : undef,
    };
}

=head3 affects_splice_site

This method returns a data structure containing
description if the variation affects splice sites.

=over

=item PERL API

 $data = $model->affects_splice_site();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/affects_splice_site

B<Response example>

<div class="response-example"></div>

=back

=cut 

# TODO: Needs evidence
sub affects_splice_site {
    my ($self) = @_;

    my ($donor, $acceptor) = ($self ~~ 'Donor', $self ~~ 'Acceptor');
    return {
        description => 'Affects splice site',
        data        => {
            donor    => $donor && "$donor",
            acceptor => $acceptor && "$acceptor",
        },
    };
}

=head3 causes_frameshift

This method returns a data structure containing
describing if the variation causes a frameshift.

=over

=item PERL API

 $data = $model->causes_frameshift();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/causes_frameshift

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub causes_frameshift {
    my ($self) = @_;

    my $frameshift = $self ~~ 'Frameshift';
    return {
        description => 'A variation that alters the reading frame',
        data         => $frameshift && "$frameshift",
    };
}

=head3 detection_method

This method returns a data structure containing
available detection methods for the variation --
particularly for SNPs.

=over

=item PERL API

 $data = $model->detection_method();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/detection_method

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub detection_method {
    my ($self) = @_;

    my $detection_method = $self ~~ 'Detection_method';
    return {
        description => 'detection method for polymorphism, typically via sequencing or restriction digest.',
        data        => $detection_method && "$detection_method",
    };
}


############################################################
#
# POLYMORPHISM DETAILS (folder into Molecular Details widget)
#
############################################################

=head3 polymorphism_type

This method returns a data structure containing
the broad classification of the variation if it is
a polymorphism, for example (SNP|RFLP).

=over

=item PERL API

 $data = $model->polymorphism_type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/polymoprhism_type

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub polymorphism_type {
    my ($self) = @_;
    my $object = $self->object;

    # What type of polymorphism is this?
    my $type = $object->SNP && $object->RFLP ? 'SNP and RFLP'
             : $object->SNP                  ? 'SNP'
             : $object->Transposon_insertion ? $object->Transposon_insertion
                                               . ' transposon insertion'
             :                                 undef;

    return {
        description => 'the general class of this polymorphism',
        data        => $type,
    };
}

=head3 polymorphism_status

If the variation is a polymorphism, this method
will return a data structure containing it's status.

=over

=item PERL API

 $data = $model->polymorphism_status();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/polymorphism_status

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub polymorphism_status {
    my ($self) = @_;

    my $status = $self ~~ 'Confirmed_SNP' ? 'confirmed' : 'predicted';
    return {
        description => 'experimental status of this polymorphism',
        data        => $status,
    };
}

=head3 reference_strain

If the variation is a polymorphism, this method
will return the reference strain.

=over

=item PERL API

 $data = $model->reference_strain();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/reference_strain

B<Response example>

<div class="response-example"></div>

=back

=cut 

# For polymorphisms
sub reference_strain {
    my ($self) = @_;

    return {
        description => 'the reference strain for the polymorphism',
        data        => $self->_pack_obj($self ~~ 'Strain'),
    };
}

=head3 polymorphism_assays

For variations that are polymorphisms, this method
will return assays useful for its detection.

=over

=item PERL API

 $data = $model->polymorphism_assays();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/polymorphism_assays

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Details related to assaying polymorphisms
sub polymorphism_assays {
    my ($self) = @_;
    my $object = $self->object;

    my $data;

    my @ref_digests;
    foreach my $enz ($object->Reference_strain_digest(2)) {
        @ref_digests = map {[$enz, $_]} $enz->col;
    }

    my @poly_digests;
    foreach my $enz ($object->Polymorphic_strain_digest(2)) {
        @poly_digests = map {[$enz, $_]} $enz->col;
    }

    foreach my $pcr_product ($object->PCR_product) {
        # If this is an RFLP, extract digest conditions
        my $assay_table;
        my %pcr_data;

        if ($object->RFLP && @ref_digests) {
            my ($ref_digest,$ref_bands)   = @{shift @ref_digests};
            my ($poly_digest,$poly_bands) = @{shift @poly_digests};

            %pcr_data = (
                reference_strain_digest   => $ref_digest,
                reference_strain_bands    => $ref_bands,
                polymorphic_strain_digest => $poly_digest,
                polymorphic_strain_bands  => $poly_bands,

                assay_type                => 'rflp',
            );
        }
        else {
            %pcr_data = (assay_type => 'sequence');
        }

        my ($left_oligo,$right_oligo);
        if (my @oligos = $pcr_product->Oligo) {
            $left_oligo  = $oligos[0]->Sequence;
            $right_oligo = $oligos[1]->Sequence;
        }

        my $pcr_conditions = $pcr_product->Assay_conditions;

        # Fetch the sequence of the PCR_product
        my $sequence = $object->Sequence;

        my $dna;

        if (my $pcr_node = first {$_ eq $pcr_product} $sequence->PCR_product) {{
            my ($start, $stop) = $pcr_node->row or last;
            my $gffdb = $self->gff_dsn or last;
            my ($segment) = eval { $gffdb->segment(
                -name   => $sequence,
                -offset => $start,
                -length => ($stop-$start)
            ) } or last;

            $dna = $segment->dna;
	    }
	}
        $pcr_data{pcr_product} = $self->_pack_obj(
            $pcr_product, undef, # let _pack_obj resolve label
            left_oligo     => $left_oligo && "$left_oligo",
            right_oligo    => $right_oligo && "right_oligo",
            pcr_conditions => $pcr_conditions && "$pcr_conditions",
            dna            => $dna && "$dna",
        );

        $data->{$pcr_product} = \%pcr_data;
    }

    return {
        description => 'experimental assays for detecting this polymorphism',
        data        => $data,
    };
}

# OOOH!  Need to handle this.
#++ 					 'variation and motif image',p(motif_picture(1,$entry)));



############################################################
#
# The Phenotype Widget
#
############################################################

=head3 nature_of_variation

This method returns a data structure containing
the nature of the variation.

=over

=item PERL API

 $data = $model->nature_of_variation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/nature_of_variation

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub nature_of_variation {
    my ($self) = @_;
    
    my $nature = $self ~~ 'Nature_of_variation';
    return {
        description => 'nature of the variation',
        data        => $nature && "$nature",
    };
}

=head3 dominance

Describes if the variation is dominant or not.

=over

=item PERL API

 $data = $model->dominance();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/dominance

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Q: Model needs to be organized under a single Dominance tag
# Q: is this one or many?
sub dominance {
    my ($self) = @_;

    my $object = $self->object;
    my $dominance = $object->Recessive
                  || $object->Semi_dominant
                  || $object->Dominant
                  || eval{$object->Partially_penetrant}
                  || eval{$object->Completely_penetrant};
    # I don't see Partially_penetrant or Completely_penetrant in the model

    return {
        description => 'dominance of the variation',
        data        => $dominance && "$dominance",
    };
}

=head3 phenotype_remark

This method returns a data structure containing
a brief remark on the phenotype of the variation.

=over

=item PERL API

 $data = $model->phenotype_remark();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/phenotype_remark

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub phenotype_remark {
    my ($self) = @_;

    my $remark = $self ~~ 'Phenotype_remark';
    return {
        description => 'phenotype remark',
        data        => $remark && "$remark",
    };
}

=head3 temperature_sensitivity

This method returns a data structure containing
the temperature sensitivity of the variation, if known.

=over

=item PERL API

 $data = $model->temperature_sensitivity();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Variation public name or WBID (eg WBVar00143133)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/temperature_sensitivity

B<Response example>

<div class="response-example"></div>

=back

=cut 

# TODO: needs evidence
sub temperature_sensitivity {
    my ($self) = @_;
    my $object = $self->object;
    my $sensitivity = $object->Cold_sensitive || $object->Heat_sensitive;

    return {
        description => 'temperature sensitive',
        data        => $sensitivity && "$sensitivity",
    };
}

# sub phenotypes {}
# Supplied by Role; POD will automatically be inserted here.
# <<include phenotypes>>

# sub phenotypes_not_observed {}
# Supplied by Role; POD will automatically be inserted here.
# <<include phenotypes_not_observed>>


############################################################
#
# PRIVATE METHODS
#
############################################################

{ # begin _retrieve_molecular_changes block
my %associated_meta = ( # this can be used to identify protein effects
    Missense    => [qw(position description)],
    Silent      => [qw(description)],
    Frameshift  => [qw(description)],
    Nonsense    => [qw(subtype description)],
    Splice_site => [qw(subtype description)],
    );

sub _retrieve_molecular_changes {
    my ($self, $changed_item) = @_; # actually, changed_item is a subtree

    my $do_translation;

    my (%protein_effects, %location_effects);
    foreach my $change_type ($changed_item->col) {
        $do_translation++ if $change_type eq 'Missense' || $change_type eq 'Nonsense';

        my @raw_change_data = $change_type->row;
        shift @raw_change_data; # first one is the type

        my %change_data;
        my $keys = $associated_meta{$change_type} || [];
        @change_data{@$keys, 'evidence_type', 'evidence'}
	= map {"$_"} @raw_change_data;

        if ($associated_meta{$change_type}) { # only protein effects have extra data
            $protein_effects{$change_type} = \%change_data;
        }
        else {
            $location_effects{$change_type} = \%change_data;
        }
    }

    return (\%protein_effects, \%location_effects, $do_translation);
}
} # end of _retrieve_molecular_changes block


# What is the length of the mutation?
sub _compile_nucleotide_changes {
    my ($self,$object) = @_;
    my @types = $object->Type_of_mutation;
    my @variations;

    # Some variation objects have multiple types
    foreach my $type (@types) {
        my ($mut,$wt,$mut_label,$wt_label);

        # Simple insertion?
        #     wt sequence = empty
        # mutant sequence = name of transposon or the actual insertion sequence
        if ($type =~ /insertion/i) {
            $wt = '';

            # Is this a transposon insertion?
            # mutant sequence just the name of the transposon
            if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
                $mut = $object->Transposon_insertion;
                $mut ||= 'unknown' if $object->Method eq 'Transposon_insertion';
            }
            else {
                # Return the full sequence of the inertion.
                $mut = $type->right;
            }

        }
        elsif ($type =~ /deletion/i) {
            # Deletion.
            #     wt sequence = the deleted sequence
            # mutant sequence = empty
            $mut = '';

            # We need to extract the sequence from a GFF store.
            # Get a segment corresponding to the deletion sequence

            my $segment = $self->_segments->[0];
            if ($segment) {
                $wt  = $segment->dna;
            }

            # CGH tested deletions.
            $type = "definite deletion" if  ($object->CGH_deleted_probes(1));

            # Substitutions
            #     wt sequence = um, the wt sequence
            # mutant sequence = the mutant sequence
        }
        elsif ($type =~ /substitution/i) {
            my $change = $type->right;
            ($wt,$mut) = eval { $change->row };

            # Ack. Some of the alleles are still stored as A/G.
            unless ($wt && $mut) {
                $change =~ s/\[\]//g;
                ($wt,$mut) = split("/",$change);
            }
        }

        # Set wt and mutant labels
        if ($object->SNP(0) || $object->RFLP(0)) {
            $wt_label = 'bristol';
            $mut_label = $object->Strain; # CB4856, 4857, etc
        }
        else {
            $wt_label  = 'wild type';
            $mut_label = 'mutant';
        }

        push @variations, {
            type           => "$type",
            wildtype       => "$wt",
            mutant         => "$mut",
            wildtype_label => $wt_label,
            mutant_label   => $mut_label,
        };
    }
    return \@variations;
}


# Fetch the coordinates of the variation in a given feature
# Much in here could be generic
sub _fetch_coords_in_feature {
    my ($self,$tag,$entry) = @_;

    my $db = $self->gff_dsn;

    my $variation_segment = $self->_segments->[0] or return;

    # Kludge for chromosomes
    my $class = $tag eq 'Chromosome' ? 'Sequence' : $entry->class;
    # is it really okay to ignore multiple results and arbitarily use the first one?
    my ($containing_segment) = $db->segment(-name  => $entry, -class => $class) or return;
    # consider caching results?

    # Set the refseq of the variation to the containing segment
    $variation_segment->refseq($containing_segment);

    my ($chrom,$fabs_start,$fabs_stop,$fstart,$fstop) = $self->_seg2coords($containing_segment);
    my ($var_chrom,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($variation_segment);
    ($start,$stop) = ($stop,$start) if ($start > $stop);
    return ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop);
}

sub _do_simple_conceptual_translation {
    my ($self, $cds, $datahash) = @_;

    my ($pos, $formatted_aa_change) = @{$datahash}{'position', 'description' }
    or return;
    my $wt_protein = eval { $cds->Corresponding_protein->asPeptide }
    or return;

    my $object = $self->object;

    # De-FASTA
    $wt_protein =~ s/^>.*//;
    $wt_protein =~ s/\n//g;

    $formatted_aa_change =~ /(.*) to (.*)/;
    my $wt_aa  = $1;
    my $mut_aa = $2;

    # if ($type eq 'Nonsense') {
    #   $mut_aa = '*';
    # }

    # Substitute the mut_aa into the wildtype protein
    my $mut_protein = $wt_protein;
    my ($wt_aa_start, $wt_protein_fragment, $mut_protein_fragment);

    substr($mut_protein,($pos-1),1,$mut_aa);

    $wt_aa_start = $pos;

    # Create short strings of the proteins for display
    $wt_protein_fragment = ($pos - 19)
        . '...'
        . substr($wt_protein,$pos - 20,19)
        . ' '
        . '<b>' . substr($wt_protein,$pos-1,1) . '</b>'
        . ' '
        . substr($wt_protein,$pos,20)
        . '...'
        . ($pos + 19);
    $mut_protein_fragment = ($pos - 19)
        . '...'
        . substr($mut_protein,$pos - 20,19)
        . ' '
        . '<b>' . substr($mut_protein,$pos-1,1) . '</b>'
        . ' '
        . substr($mut_protein,$pos,20)
        .  '...'
        . ($pos + 19);

    my $wt_trans = "> $cds"
	. $self->_do_markup($wt_protein, $pos-1, $wt_aa, undef, 'is_peptide');
    my $mut_trans = "> $cds ($object: $formatted_aa_change)"
	. $self->_do_markup($mut_protein, $pos-1, $mut_aa, undef, 'is_peptide');

    return ($wt_protein_fragment, $mut_protein_fragment, $wt_trans, $mut_trans);
}


# Markup features relative to the CDS or to raw genomic features
sub _do_markup {
    my ($self,$seq,$var_start,$variation,$flank_length,$is_peptide) = @_;
    my $object = $self->object;

    # Here, variation might be a specially formatted string (ie '----' for a deletion)
    my @markup;
    my $markup = Bio::Graphics::Browser2::Markup->new;
    $markup->add_style('utr'  => 'FGCOLOR gray');
    $markup->add_style('cds0'  => 'BGCOLOR yellow');
    $markup->add_style('cds1'  => 'BGCOLOR orange');
    $markup->add_style('space' => ' ');
    $markup->add_style('substitution' => 'text-transform:uppercase; background-color: red;');
    $markup->add_style('deletion'     => 'background-color:red; text-transform:uppercase;');
    $markup->add_style('insertion'     => 'background-color:red; text-transform:uppercase;');
    $markup->add_style('deletion_with_insertion'  => 'background-color: red; text-transform:uppercase');
    if ($object->Type_of_mutation eq 'Insertion') {
        $markup->add_style('flank' => 'background-color:yellow;font-weight:bold;text-transform:uppercase');
    }
    else {
        $markup->add_style('flank' => 'background-color:yellow');
    }
    # The extra space is required here when used in non-pre-formatted text!
    $markup->add_style('newline',"<br> ");

    my $var_stop = length($variation) + $var_start;

    # Substitutions start and stop at the same position
    $var_start = ($var_stop - $var_start == 0) ? $var_start - 1 : $var_start;

    # Markup the variation as appropriate
    push (@markup,[lc($object->Type_of_mutation),$var_start,$var_stop]);

    # Add spacing for peptides
    if ($is_peptide) {
        for (my $i=0; $i < length $seq; $i += 10) {
            push @markup,[$i % 80 ? 'space' : 'newline',$i];
        }
    }
    else {
        for (my $i=80; $i < length $seq; $i += 80) {
            push @markup,['newline',$i];
        }
        #       push @markup,map {['newline',80*$_]} (1..length($seq)/80);
    }

    if ($flank_length) {
        push @markup,['flank',$var_start - $flank_length + 1,$var_start];
        push @markup,['flank',$var_stop,$var_stop + $flank_length];
    }

    $markup->markup(\$seq,\@markup);
    return $seq;
}

# Build short strings (wild type and mutant) flanking
# the position of the mutant sequence in support of the context() method.
# If a mutation sequence (insertion or deletion) exceeds
# INDEL_DISPLAY_LIMIT, a string will be inserted unless
# the --all option is supplied.
# Options:
# --all    Don't truncate long strings: return the full flank-mutant-flank
# --boldface Boldface the mutation
# --flank amount of flank to include. Defaults to SNIPPET_LENGTH
#
# Returns (wt(+), mut(+), wt(-), mut(-));
sub _build_sequence_strings {
    my ($self,@p) = @_;
    my ($with_markup,$flank);

    # Get a GFFdb handle - I'm not sure how to do this in the API.
    my $species = $self->_parsed_species;
    my $db_obj  = $self->gff_dsn($species); # Get a WormBase::API::Service::gff object
    my $db      = $db_obj->dbh;

    my $object     = $self->object;
    my $segment    = $self->_segments->[0];
    return unless $segment;

    my $sourceseq  = $segment->sourceseq;
    my ($chrom,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($segment);

    my $debug;

    # Coordinates are sometimes reported on the minus strand
    # We will report all sequence strings on the plus strand instead.
    my $strand = '+';
    if ($abs_start > $abs_stop) {
        ($abs_start,$abs_stop) = ($abs_stop,$abs_start);
        $strand = '-';          # Set $strand - used for tracking
    }

    # Fetch a segment that spans the mutation with the appropriate flank
    # on the plus strand

    # The amount of flanking sequence to recover should be configurable
    # Right now, it is hardcoded for 500 bp
    my $offset = 500;
    my ($full_segment) = $db->segment(-class => 'Sequence',
                                      -name  => $sourceseq,
                                      -start => $abs_start - $offset,
                                      -stop  => $abs_stop  + $offset);
    my $dna = $full_segment->dna;
    # MOVE INTO TEST
    # $debug .= "WT SNIPPET DNA FROM GFF: $dna" . br if DEBUG_ADVANCED;

    # Visit each variation and create a formatted string
    my ($wt_fragment,$mut_fragment,$wt_plus,$mut_plus);
    my $variations = $self->_compile_nucleotide_changes($object);

    foreach my $variation (@{$variations}) {
        my $type = $variation->{type};
        my $wt   = $variation->{wildtype};
        my $mut  = $variation->{mutant};
        my $extracted_wt;
        if ($type =~ /insertion/i) {
            $extracted_wt = '-';
        }
        else {
            my ($seg) = $db->segment(-class => 'Sequence',
                                     -name  => $sourceseq,
                                     -start => $abs_start,
                                     -stop  => $abs_stop);
            $extracted_wt = $seg->dna;
        }

        # Does the sequence we have extracted match that stored in the
        # database?  Stated another way, is the mutation reported on the
        # plus strand?

        # Insertions will have no sequence and I should not be able to
        # extract any either (We use logical or here to check for the
        # $strand flag. Sometimes insertions or deletions will have no
        # sequence.

        if ($wt eq $extracted_wt && $strand ne '-') {
            # Yes, it has.  Do nothing.
        }
        else {
            # MOVE INTO TEST
            # $debug .= "-----> TRANSCRIPT ON - strand; revcomping" if DEBUG_ADVANCED;

            # The variation and flanks have been reported on the minus strand
            # Reverse complement the mutant sequence
            $strand = '-';  # Set the $strand flag if not already set.
            unless ($mut =~ /transposon/i) {
                $mut = reverse $mut;
                $mut =~ tr/[acgt]/[tgca]/;

                $wt = reverse $wt;
                $wt =~ tr/[acgt]/[tgca]/;
            }
        }

        # Keep the full string of all variations on the plus strand
        $wt_plus  .= $wt;
        $mut_plus .= $mut;

        # What is the type of mutation? If deletion or insertion,
        # check the length of the partner, then format appropriately
        # TODO: The INDEL_DISPLAY_LIMIT is hard coded
        my $INDEL_DISPLAY_LIMIT = 100;
        if (length $mut > $INDEL_DISPLAY_LIMIT || length $wt > $INDEL_DISPLAY_LIMIT) {
            if ($type =~ /deletion/i) {
                my $target = length ($wt) . " bp " . lc($type);
                $wt_fragment  .= "[$target]";
                $mut_fragment .= '-' x (length ($target) + 2);
            }
            elsif ($type =~ /insertion/i) {
                my $target;
                if ($mut =~ /transposon/i) { # String representing transposon insertions
                    $target = $mut;
                }
                else {
                    $target = length ($mut) . " bp " . lc($type);
                }
                #  $mut_fragment .= '[' . a({-href=>$href,-target=>'_blank'},$target) . ']';
                $mut_fragment .= "[$target]";
                #  $wt_fragment  .= '-' x (length($mut_fragment) + 2);
                $wt_fragment  .= '-' x (length($mut_fragment));
            }
        }
        else {
            # We are less than 100 bp, go ahead and use it.
            $wt_fragment  .= ($wt  eq '-') ? '-' x length $mut  : $wt;
            $mut_fragment .= ($mut eq '-') ? '-' x length $wt : $mut;
        }
    }

    # Coordinates of the mutation within the segment
    my ($mutation_start,$mutation_length);
    if ($strand eq '-') {
        # This works for e205 substition (-)
        $mutation_start   = $offset;
        $mutation_length  = length($wt_plus);
    }
    else {
        # SETTING 1 - works for:
        #   ca16 indel(+)
        #   cxP622 insertion(+)
        $mutation_start  = $offset + 1;
        $mutation_length = length($wt_plus) - 1;

        # SETTING 2 - works for:
        #     tm728 (indel)
        #     ok431 (indel)
        $mutation_start  = $offset;
        $mutation_length = length($wt_plus) - 1;

        # SETTING 3 - works for:
        #     cn28 (unknown transposon insertion)
        #$mutation_start  = $offset + 2;
        #$mutation_length = length($wt_full) - 1;

        # SETTING 4 - works for:
        #      bm1 (indel)
        $mutation_start  = $offset;
        $mutation_length = length($wt_plus);
    }

    # TODO: Make the snippet length configurable.
    my $SNIPPET_LENGTH = 100;
    $flank ||= $SNIPPET_LENGTH;

    my $insert_length = (length $wt_fragment > length $mut_fragment) ? length $wt_fragment : length $mut_fragment;
    my $flank_length = int(($flank - $insert_length) / 2);

    # The amount of flank to fetch is based on the middle segment
    my $left_flank  = substr($dna,$mutation_start - $flank_length,$flank_length);
    my $right_flank = substr($dna,$mutation_start + $mutation_length,$flank_length);

    # MOVE INTO TEST
    #    if (DEBUG_ADVANCED) {
    #   #      print "right flank : $right_flank",br;
    #   $debug .= "WT PLUS STRAND .................. : $wt_plus"  . br;
    #   $debug .= "MUT PLUS STRAND ................. : $mut_plus" . br;
    #     }

    # Mark up the reported flanking sequences in the full sequence
    my ($reported_left_flank,$reported_right_flank) = ($object->Flanking_sequences(1),$object->Flanking_sequences(2));
    #    my $left_length = length($reported_left_flank);
    #    my $right_length = length($reported_right_flank);
    $reported_left_flank = (length $reported_left_flank > 25) ? substr($reported_left_flank,-25,25) :  $reported_left_flank;
    $reported_right_flank = (length $reported_right_flank > 25) ? substr($reported_right_flank,0,25) :  $reported_right_flank;

    # Create a full length mutant dna string so that I can mark it up.
    my $mut_dna =
        substr($dna,$mutation_start - 500,500)
        . $mut_plus
        . substr($dna,$mutation_start + $mutation_length,500);


    my $wt_full = $self->_do_markup($dna,$mutation_start,$wt_plus,length($reported_left_flank));
    my $mut_full = $self->_do_markup($mut_dna,$mutation_start,$mut_plus,length($reported_right_flank));

    # TO DO: This markup belongs as part of the view, not here.
    # Return the full sequence on the plus strand
    # if ($with_markup) {
    #     my $wt_seq = join(' ',lc($left_flank),span({-style=>'font-weight:bold'},uc($wt_fragment)),
    #                       lc($right_flank));
    #     my $mut_seq = join(' ',lc($left_flank),span({-style=>'font-weight:bold'},
    #                                                 uc($mut_fragment)),lc($right_flank));
    #     return ($wt_seq,$mut_seq,$wt_full,$mut_full,$debug);
    # }
    # else {
    my $wt_seq  = lc join('',$left_flank,$wt_plus,$right_flank);
    my $mut_seq = lc join('',$left_flank,$mut_plus,$right_flank);
    return ($wt_seq,$mut_seq,$wt_full,$mut_full,$debug);
    # }
}


__PACKAGE__->meta->make_immutable;

1;
