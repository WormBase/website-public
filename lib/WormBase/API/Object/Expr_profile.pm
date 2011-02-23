package WormBase::API::Object::Expr_profile;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has 'ao_template' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->pull;
    	return $ao_object;
  	}
);


#######

sub template {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

### mainly for text data; and single layer hash ###

sub template_simple {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Tag;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

#####################
# DEVELOPMENT NOTES #
#####################

# see data pull in subs print_profile, mountain, hunter, lookup_gene 
# reference -- work with XS.

########

sub pcr_data {

	my $self = shift;
    my $profile = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $dbgff = $self->gff_dsn('c_elegans');
	my $db = $self->ace_dsn();


  	# Since expression profiles aren't attached to anything meaninful
  	# use the coordinates of PCR_products. Blech.
  
  	my $primer = $profile->PCR_product;
 	 my $seq = $dbgff->segment($primer);
  	$seq->absolute(1) if ($seq);
  
  	my $chromosome    = $seq->refseq if $seq;
  	my ($start,$stop) = ($seq->start,$seq->end) if $seq;

  	my $expr_map = $profile->Expr_map(-filled=>1);
  	my ($x_coord,$y_coord,$mountain) = ($expr_map->X_coord,$expr_map->Y_coord,$expr_map->Mountain);
  	my $radius =  4;


	%data_pack = (
					"primer" => $primer,
					"seq" => $seq,
					"chromosome" => $chromosome,
					"start" => $start,
					"stop" => $stop,
					"x_coord" => $x_coord,
					"y_coord" => $y_coord,
					"mountain" => $mountain,
					"radius" => $radius
					);
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub profiles {

	my $self = shift;
    my $profile = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $dbgff = $self->gff_dsn('c_elegans');
	my $db = $self->ace_dsn();

  if ($profile->class eq 'Gene') {
  
  	# I cannot fetch genes from the GFF if they are of the Gene class
    # (They aren't in the GFF)...
    # This makes it impossible to associate genes with profiles
  
  	my $s;
    eval{$s = $dbgff->segment($profile);};
    my @p;

    eval{@p = map {$_->info} $s->features('experimental_result_region:Expr_profile') if $s;};    
    $profile = $p[0];
    undef $profile unless @p;  # used as a flag that we fetched an appropriate object
    @p = map {$db->fetch(-class=>'Expr_profile',-name=>$_->name) } @p;

	foreach my $p (@p) {
	
		$data_pack{$p} = (
						
							'data_element' => $p
						);
	}
  }

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub pcr_product {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	my $pcr_product = $object->PCR_product;

	$data_pack = {
					'ace_id' => $pcr_product,
					'class' => 'PCR_product'
					};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub expr_map {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my $expr_map = $object->Expr_map;
	
	%data_pack = (
				'ace_id' => $expr_map,
				'class' => 'Expr_map'
				);
	
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


# Add to wormbase.conf: remarks; supplied by Object.pm
# remarks() provided by Object.pm. We retain here for completeness of the API documentation.

=head2 remarks

This method will return a data structure containing
curatorial remarks for the gene class.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/remarks

=head4 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }

sub method {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Method;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub rnai {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @rnais = $object->RNAi_result;
	
	foreach my $rnai (@rnais) {
	
		$data_pack{$rnai} = {
							'ace_id' => $rnai,
							'class' => 'RNAi'
							};
	}


	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

1;
