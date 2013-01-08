package WormBase::API::Object::Gene_class;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Gene_class

=head1 SYNPOSIS

Model for the Ace ?Gene_class class.

=head1 URL

http://wormbase.org/species/gene_class

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# Class-level methods
#
#######################################

# all_gene_classes { }
# This method will return a data structure containing
# all gene classes.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/all/all_gene_classes


{ # temporary fix. this should actually be cached for the entire class.
  # better yet, this should be designated as a class method, signaled at the
  # controller level for caching
    my $gene_classes;

    sub all_gene_classes {
        my $self   = shift;

        return $gene_classes ||= {
            description => 'a summary of all gene classes',
            data => [
                map {
                    gene_class  => $self->_pack_obj($_),
                    laboratory  => $self->_pack_obj(scalar $_->Designating_laboratory),
                    description => scalar eval { $_->Description->name },
                    phenotype   => scalar eval { $_->Phenotype->name },
                    genes       => scalar ( () = $_->Genes ),
                }, $self->ace_dsn->dbh->fetch(-query => "find Gene_class")
            ],
        };
    }
}

#######################################
#
# Object-level methods
#
#######################################

########################################
# The Overview widget 
#
#######################################

# name { }
# Supplied by Role

# other_names { }
# Supplied by Role

# description { }
# Supplied by Role

# laboratory { }
# Supplied by Role

# phenotype { }
# This method will return a data structure containing
# a string describing the general phenotype of genes
# placed in this gene class.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/phenotype

sub phenotype {
    my $self = shift;
    my $object    = $self->object;
    my $phenotype = $object->Phenotype;
    my $data      = { description => 'general phenotype of genes placed in this gene class',
		      data        => "$phenotype" || undef };
    return $data;
}

# remarks {}
# Supplied by Role


#######################################
#
# The Current Genes widget 
#
#######################################

# current_genes { }
# This method will return a data structure containing
# all genes assigned to the class, organized by species.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/current_genes

sub current_genes {
    my $self   = shift;
    my $object = $self->object; 
    
    my %data;
    foreach my $gene ($object->Genes) {
	
	my $species = $gene->Species;
	
	my $sequence_name = $gene->Sequence_name;
# 	my $locus_name    = $gene->Public_name;
# 	my $name = ($locus_name ne $sequence_name) ? "$locus_name ($locus_name)" : "$locus_name";
	
	# Some redundancy in the data structure here while
	# we decide how to format this data.
	push @{$data{$species}},
	{ species  => $self->_split_genus_species($species),
	  locus    => $self->_pack_obj($gene),
	  sequence => $self->_pack_obj($sequence_name),
	};		     
    }
    return { description => 'genes assigned to the gene class, organized by species',
	     data        => scalar keys %data ? \%data : undef };
}

#######################################
#
# The Previous Genes widget 
#
#######################################

# former_genes { }
# This method will return a data structure containing
# genes that used to belong to the current gene class
# but have been reassigned to another class, or that
# have been reassigned a new gene name within the same
# class.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/former_genes

sub former_genes {
    my $self   = shift;
    my $object = $self->object;
        
    my %data;
    foreach my $old_gene ($object->Old_member) {
	my $gene = $old_gene->Other_name_for || $old_gene->Public_name_for;
	next unless $gene;
	my $stashed = $self->_stash_former_member($gene,$old_gene,'reassigned to new class');
	
	my $species = $gene->Species;
	push @{$data{$species}},$stashed;
    }
    
    return { description => 'genes formerly in the class that have been reassigned to a new class',
		 data        => scalar keys %data ? \%data : undef };    
}


# reassigned_genes { }
# This method will return a data structure containing
# genes that have been reassigned within the gene class.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/reassigned_genes

sub reassigned_genes {
    my $self   = shift;
    my $object = $self->object;
    my $dbh = $self->ace_dsn->dbh;
    
    my @genes = eval {$dbh->fetch(-query=>qq{find Gene where Other_name="$object*"})};
    my %data;
    foreach my $gene (@genes) {
	my $species = $gene->Species;
	
	# Only keep them if their current locus name matches the object name
	# We're looking for genes that have been reassigned
	my $public_name = $gene->Public_name;
	my @other_names =  grep { /$public_name/ } $gene->Other_name;
	foreach (@other_names) {
	    my $stashed = $self->_stash_former_member($gene,$_);
	    push @{$data{$species}},$stashed;
	}
    }
    return { description => 'genes that have been reassigned a new name in the same class',
	      data        => scalar keys %data ? \%data : undef };    
}


##############################
#
# Internal methods
#
##############################
sub _stash_former_member {
    my ($self,$gene,$old_gene,$reason) = @_;
    return unless $gene;

    my $sequence_name = $gene->Sequence_name;
    my $locus_name    = $gene->Public_name;
    my %data = ( species     => $self->_pack_obj($gene->Species),
		 former_name => $old_gene && "$old_gene",
		 new_name    => $self->_pack_obj($gene,"$locus_name"),
		 sequence    => $self->_pack_obj($sequence_name),
		 reason      => $reason && "$reason");
    return \%data;
}

__PACKAGE__->meta->make_immutable;

1;

