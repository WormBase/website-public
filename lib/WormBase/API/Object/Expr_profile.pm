package WormBase::API::Object::Expr_profile;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Expr_profile

=head1 SYNPOSIS

Model for the Ace ?Expr_profile class.

=head1 URL

http://wormbase.org/species/expr_profile

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget 
#
#######################################

=head2 Overview

=cut

# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


sub pcr_data {

	my $self = shift;
    my $profile = $self->object;
	my $dbgff = $self->gff_dsn('c_elegans');
	my $db = $self->ace_dsn();

  	my $primer = $profile->PCR_product;
 	 my $seq = $dbgff->segment($primer);
  	$seq->absolute(1) if ($seq);
  
  	my $chromosome    = $seq->refseq if $seq;
  	my ($start,$stop) = ($seq->start,$seq->end) if $seq;

  	my $expr_map = $profile->Expr_map(-filled=>1);
  	my ($x_coord,$y_coord,$mountain) = ($expr_map->X_coord,$expr_map->Y_coord,$expr_map->Mountain);
  	my $radius =  4;
	my %data_pack;

	my $data_pack = {
		primer => $primer,
		seq => $seq,
		chromosome => $chromosome,
		start => $start,
		stop => $stop,
		x_coord => $x_coord,
		y_coord => $y_coord,
		mountain => $mountain,
		radius => $radius
	};
	return {
		'data'=> $data_pack,
		'description' => 'pcr data on the expression profile'
	};
}

sub profiles {
	my $self = shift;
    my $profile = $self->object;
	my $data_pack;
	my $dbgff = $self->gff_dsn('c_elegans');
	my $db = $self->ace_dsn();

  	if ($profile->class eq 'Gene') {
  		my $s;
    	eval{$s = $dbgff->segment($profile);};
    	my @p;
    	eval{@p = map {$_->info} $s->features('experimental_result_region:Expr_profile') if $s;};    
    	$profile = $p[0];
    	undef $profile unless @p;  # used as a flag that we fetched an appropriate object
    	@p = map {$db->fetch(-class=>'Expr_profile',-name=>$_->name) } @p;

		foreach my $p (@p) {
			$data_pack = $self->_pack_obj($p);
		}
  	}
	return {
		'data'=> $data_pack,
		'description' => 'expression profiles for set of genes'
	};
}

sub pcr_product {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->PCR_product;
	my $data_pack = $self->_pack_obj($tag_object);
	return {
		'data'=> $data_pack,
		'description' => ''
	};
}

sub expr_map {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Expr_map;
	my $data_pack = $self->_pack_obj($tag_object);
	return {
		'data'=> $data_pack,
		'description' => ''
		};
}


# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>


sub rnai {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->RNAi_result;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => ''
	};
}

1;
