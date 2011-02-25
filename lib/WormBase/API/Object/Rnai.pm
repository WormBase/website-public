package WormBase::API::Object::Rnai;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


################
## IDENTIFICATION
################

=head3 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Transgene ID (gmIs13)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head5 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}

sub id {
	my ($self) = @_;
	my $object = $self->object;

	return {
		description => 'notes',
		data => {
			id => "$object",
			label => "$object",
			class => 'RNAi',
		},
	};
}

sub laboratory {
	my ($self) = @_;

	return {
		description => 'notes',
		data => $self->_pack_obj($self ~~ 'Laboratory'),
	};
}

sub targets {
	my ($self) = @_;
	my %data;

	my $targets_hr = _classify_targets($self->object);

	foreach my $target_type ('Primary targets','Secondary targets') {
		my $genes = eval { $targets_hr->{$target_type}};
		$data{$target_type} = $genes; # are the key,value pair important? otherwise omit...
  	}

	return {
		description => 'notes',
		data => %data || undef,
	};
}

sub identification {
	my ($self) = @_;
    my $exp = $self->object;

	my $targets_hr = _classify_targets($exp);
	my @reagents = $exp->PCR_product;
	my $sequence = $exp->Sequence_info->right;
	my $assay = ($exp->PCR_product) ? 'PCR product' : 'Sequence';

	my %targets;
	foreach my $target_type ('Primary targets','Secondary targets') {
		$targets{$target_type} = eval {$targets_hr->{$target_type}};
  	}


	return {
		description => 'notes',
		data		=> {
			ace_id	 => $exp,
			class	 => 'RNAi',
			targets	 => \%targets,
			reagents => \@reagents,
			sequence => $sequence,
			assay	 => $assay,
		},
	};
}

## development notes

sub history_name {
	my ($self) = @_;

	return {
		description => 'notes',
		data => $self ~~ 'History_name' || $self->object,
	};
}

################
## SOURCE
################


# Provided by Object.pm, pod retained for documentation

=head3 remarks

This method will return a data structure containing
curator remarks about the transgene.

=head4 PERL API

 $data = $model->remarks();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Transgene (eg gmIs13)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/remarks

=head5 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }




#### test

sub laboratories {
	my ($self) = @_;
	my $labs = $self ~~ '@Laboratory';

	return {
		description => 'notes',
		data => @$labs ? $labs : undef,
	};
}

sub laboratory_details { # TODO ???
	my ($self) = @_;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	#	my $exp = shift;
	#  	my ($experiment_link,$experiment_url,$link_location);
	#  	# experiment URL also used to construct links to movies
	#  	my $history_name = $exp->History_name;
	#  	if ($exp->Laboratory eq 'KK' || $exp->Laboratory eq 'PF') {
	#    
	#    	($experiment_link = $history_name) =~ s/^KK://;
	#    	$experiment_url = Configuration->Rnaidb.$experiment_link;
	#    	$experiment_link = a({-href=>$experiment_url},$history_name);
	#    	$link_location = a({-href=>'http://www.rnai.org/'},'RNAiDB');
	#  	} elsif ($exp->Laboratory eq 'TH'){
	#    
	#    	# Links to PhenoBank are stored as remarks
	#    	my @remark = map {escapeHTML($_)} $exp->Remark;
	#    	($experiment_link) = "[" 
	#      	. join('; ',map { a({-href=>$_},/GeneID=(.*)&/) } grep { /phenobank/ } @remark) . ']';
	#    	$link_location = a({-href=>Configuration->Phenobank},'PhenoBank');
	#  	}
	#
	#  	my @remark = map {escapeHTML($_)} $exp->Remark;
	#  	@remark = grep { !/phenobank/ } @remark;
	#
	#  	SubSection('Laboratory',map { ObjectLink($_) } $exp->Laboratory);
	#
	#  	SubSection("Further details available at $link_location",$experiment_link);
	#
	#  	if (my @refs = $exp->Reference) {
	#    
	#    	SubSection('Reference',format_references(-references=>\@refs,-format=>'long',-pubmed_link=>'image',
	#				     -suppress_years=>1));
	#  	} else {
	#  	
	#    	my $author = join(' ',map { ObjectLink($_) } $exp->Author);
	#    
	#    	SubSection('Authors',$author);
	#    	my $date = $exp->Date;
	#    	$date =~ s/ 00:00:00$//;
	#    
	#    	SubSection('Publication date',$date);
	#  }
	#  
	#  SubSection('Remarks',@remark);

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

################
## EXPERIMENTAL CONDITIONS
################

# Supplied by Object.pm as taxonomy()
# After verifiying, safe to remove.
#sub species {
#	my ($self) = @_;
#
#	return {
#		description => 'notes',
#		data		=> $self->_pack_obj($self ~~ 'Species', $self ~~ 'Common_name'),
#	};
#}

sub genotype {
	my ($self) = @_;

	return {
		description => 'notes',
		data		=> $self ~~ 'Genotype',
	};
}

sub strain {
	my ($self) = @_;

	return {
		description => 'notes',
		data		=> $self->_pack_obj($self ~~ 'Strain'),
	};
}

sub interactions {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_)} @{$self ~~ '@Interaction'};

	return {
		description => 'notes',
		data => @data ? \@data : undef,
	};
}

sub treatment {
	my ($self) = @_;

	return {
		description => 'notes',
		data => $self ~~ 'Treatment',
	};
}

sub life_stage {
	my ($self) = @_;

    return {
		description => 'notes',
		data => $self->_pack_obj($self ~~ 'Life_stage'),
	};
}

sub delivered_by {
	my ($self) = @_;
	return {
		description => 'notes',
		data => $self ~~ 'Delivered_by',
	};
}

#sub experimental_conditions {
#
#	my ($self) = @_;
#    my $exp = $self->object;
#	my %data;
#	my $desc = 'notes';
#	my %data_pack;
#
#	#### data pull and packaging
#
#	my $species = $exp->Species;
#	my $genotype = $exp->Genotype;
#	my $strain = $exp->Strain;
#	my $treatment = $exp->Treatment;
#	my $life_stage = $exp->Life_stage;
#	my $delivered_by = $exp->Delivered_by;
#	
#	my $interaction = $exp->Interaction;
#	my $interactor = eval{$interaction->Interactor;};
#	
#	%data_pack = (
#					'species' => $species,
#					'genotype' => $genotype,
#					'strain' => $strain,
#					'treatment' => $treatment,
#					'life_stage' => $life_stage,
#					'delivered_by' => $delivered_by,
#					'interaction' => $interaction,
#					'interactor' => $interactor
#					);
#	####
#
#	$data{'data'} = \%data_pack;
#	$data{'description'} = $desc;
#	return \%data;
#}

###############
## PHENOTYPES
###############

sub phenotypes {
	my ($self) = @_;

	my @data = map {$self->_pack_obj($_, scalar $_->Primary_name)}
	               @{$self ~~ '@Phenotype'};

	return {
		description => 'notes',
		data => @data ? \@data : undef,
	};
}


sub phenotype_nots {
	my ($self) = @_;

	my @data = map {$self->_pack_obj($_, scalar $_->Primary_name)}
	               @{$self ~~ '@Phenotype_not_observed'};

	return {
		description => 'notes',
		data => @data ? \@data : undef,
	};
}



###############
## MOVIES AND IMAGES
###############

sub movies { # TODO ???
	my ($self) = @_;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	## work with XS to get precise details of data needed for images

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


###############
## GENOMIC ENVIRONS
###############


sub genomic_environs { # TODO ???
	my ($self) = @_;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	## work with XS to get precise details of data needed for images

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



###############
## NOTES
###############

sub display_notes {
	my ($self) = @_;

	my $data = 'Primary targets

	Primary targets have sequence identity to the RNAi probe of at least
	95% over a stretch of at least 100 nucleotides, identified using a
	combination of BLAST and BLAT algorithms.  These are usually the
	intended target genes of an RNAi experiment.

	Secondary targets

	Secondary targets have between 80 and 94.99% sequence identity over a
	stretch of at least 200 nucleotides to the RNAi probe. Targets (and
	overlapping genes) that satisfy these criteria may or may not be
	susceptible to an RNAi effect with the given probe and represent
	secondary (unintended) genomic targets of an RNAi experiment.';

	return {
		description => 'notes',
		data => $data,
	};
}

###############
## INTERNAL
###############

sub _classify_targets {
  	my $exp = shift;
  	my %seen;
  	my %categories;

	my @genes = grep { !$seen{$_->Molecular_name}++ } $exp->Gene;
  	push @genes, grep { !$seen{$_}++ } $exp->Predicted_gene;

  	foreach my $gene (@genes) {
    	my @types = $gene->col;

    	foreach (@types) {
			my ($remark) = $_->col;
			my $status = ($remark =~ /primary/) ? 'Primary targets' : 'Secondary targets';
			push @{$categories{$status}},$gene;
    	}
  	}

	return \%categories;
}


1;
