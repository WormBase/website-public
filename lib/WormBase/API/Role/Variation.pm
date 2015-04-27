package WormBase::API::Role::Variation;

use Moose::Role;

#######################################################
#
# Attributes
#
#######################################################

#######################################################
#
# Generic methods, shared across Gene, Strain classes
#
#######################################################


############################################################
#
# Private Methods
#
############################################################

# Private method: glean some information about a variation.
sub _process_variation {
    my ( $self, $variation, $get_gene ) = @_;

    my $type = join (', ', map {$_=~s/_/ /g;$_} grep{ $_=~/^(?!Natural_variant)/; } $variation->Variation_type ) || 'unknown';

    my $molecular_change =  $variation->Type_of_mutation || "Not curated" ;

    my $phen_count = $self->_get_count($variation, 'Phenotype');

    my %effects;
    my %locations;
    my (@aa_change,@aa_position, @composite_change,@isoform);
    foreach my $type_affected ( $variation->Affects ) {
        foreach my $item_affected ( $type_affected->col ) {    # is a subtree
          foreach my $val ($item_affected->col){
	      my ($original,$result);

	      my ($aa_cha,$aa_pos);
	      
              if ($val =~ /utr|intron|exon/i) { $locations{$val}++; }

              else {
		  $effects{$val}++;

		  if ($val =~ /missense/i) {
		      # Not specified for every allele.
		      ($aa_pos,$aa_cha) = eval { $val->right->row };
		      if ($aa_cha) {
			  $aa_cha =~ /(.*)\sto\s(.*)/;
			  $original = $1;
			  $result   = $2;
			  $aa_cha = "$original -> $result";
		      }
		  }  elsif ($val =~ /nonsense/i) {
		      # "Position" here really one of Amber_UAG, Ochre, etc.
		      my ($type,$change_string) = eval { $val->right->row; };

		      # Parse out the original AA and position of the change.
		      $change_string   =~ /(.*)\sto\s.*\((.*)\).*/;
		      $original = $1;
		      $aa_pos   = $2 ? $2 : $type;

		      # Strip the position from the change.
		      $aa_cha =~ s/\($aa_pos\)//;
		      
		      $type =~ /(.*)_.*/;
		      $result = $1;
		  }
		  my $composite_change = "$original$aa_pos$result" if ($original && $aa_pos && $result);
		  push(@aa_change, $aa_cha)   if $aa_cha;  # Old legacy format; save for now for fear of breaking something!
		  push(@aa_position, $aa_pos) if $aa_pos;  # 
		  push(@composite_change,$composite_change) if $composite_change;
		  push(@isoform, $self->_pack_obj($item_affected)) if $aa_pos;
	      }
	  }
	}
    }
    
    $type = "transposon insertion" if $variation->Transposon_insertion;
    my @effect = keys %effects;
    my @location = keys %locations;
    
    my $method_name = $variation->Method;
    my $method_remark = $method_name->Remark || "" if $method_name;
    
    my $gene = $self->_pack_obj($variation->Gene) if $get_gene;
    my @strains = map { $self->_pack_obj($_) } $variation->Strain;
    
    # Make string user friendly to read and add tooltip with description:
    if ($method_name) {
	$method_name = "$method_name";
	$method_name =~ s/_/ /g;
	$method_name = "<a class=\"longtext\" tip=\"$method_remark\">$method_name</a>";
    }
    my %data = (
	variation        => $self->_pack_obj($variation),
	type             => $type && "$type",
	method_name      => $method_name,
	gene             => $gene,
	molecular_change => $molecular_change && "$molecular_change",
	aa_change        => @aa_change ? join('<br />', @aa_change) : undef,
	aa_position      => @aa_position ? join('<br />', @aa_position) : undef,
	composite_change => @composite_change ? join('<br />',@composite_change) : undef,
	isoform          => @isoform ? \@isoform : undef,
	effects          => @effect ? \@effect : undef,
	phen_count       => "$phen_count",
	strain           => @strains ? \@strains : undef,
	locations    => @location ? join(', ', map {$_=~s/_/ /g;$_} @location) : undef,
	);
    return \%data;
}


1;
