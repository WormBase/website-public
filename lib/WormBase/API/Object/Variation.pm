package WormBase::API::Object::Variation;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


############################################################
#
# The Overview widget
#
############################################################
sub name {
    my $self = shift;
    my $ace  = $self->object;
    my $data = { description => 'The object name of the variation',
		 data        => $ace->name
    };
    return $data;
}

sub common_name {
    my $self = shift;
    my $object = $self->object;
    my $name = $object->Public_name;
    my $data = { description => 'The public name of the variation',
		 data        => $name,
    };
    return $data;
}

sub cgc_name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The Caenorhabditis Genetics Center (CGC) name for the gene',
		 data        => $object->CGC_name,
    };
    return $data;
}

sub other_names {
    my $self   = shift;
    my $object = $self->object;
    my @others = $object->Other_name;
    my %others;
    foreach (@others) {
	$others{$_->name} = 'Variation';
    }
    my $data   = { description => 'other possible names for the variation',
		   data        => \%others
    };
    return $data;
}

# What broad type of allele is this?
sub variation_type {
    my $self = shift;
    my $object = $self->object;
    my $type;
    if ($object->KO_consortium_allele(0)) {
	$type = "Knockout Consortium allele";
    } elsif ($object->SNP(0) && $object->RFLP(0)) {
	$type = 'polymorphism; RFLP';
	$type .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";       
    } elsif ($object->SNP(0) && !$object->RFLP(0)) {
	$type  = 'polymorphism';
	$type .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";
    } elsif ($object->Natural_variant) {
	$type = 'natural variant';
    } else {
	$type = 'allele';
    }
    my $data = { description => 'the general type of the variation',
		 data        => $type
    };
    return $data;
}

sub remarks {
    my $self    = shift;
    my $object  = $self->object;
    my @remarks = $var->Remark;
    my $data    = { description  => 'curator remarks for the variation',
		    data         => \@remarks,
		    has_evidence => 1,
			
    };
    return $data;
}


############################################################
#
# The Molecular Details widget
#
############################################################
sub type_of_mutation {
    my $self   = shift;
    my $object = $self->object;
    my $type   = $object->Type_of_mutation;

    if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
	$type = 'transposon insertion';
    }

    my $data = { description => 'the type of mutation and its molecular change',
		 data        => "$type",				  
    };
    return $data;
}    
   
sub nucleotide_change {
    my $self   = shift;
    my $object = $self->shift;

    # Nucleotide change details (from ace)
    my $variations = $self->_fetch_sequence_from_ace($object);
    my $data = { description => 'raw nucleotide changes for this variation',
		 data        => $variations,
    };

    
}
   



############################################################
#
# PRIVATE METHODS
#
############################################################

# What is the length of the mutation?
# (Previously, this was done from the GFF itself.  This is better).

# Stringify does not belong here  (should be part of build string)
# need to concatenate multiple mutations
sub _fetch_sequence_from_ace {
    my ($self,$var,$stringify) = @_;
    my @types = eval { $var->Type_of_mutation };
    my @variations;
    
    # Some variation objects have multiple types
    foreach my $type (@types) {
	my ($mut,$wt,$mut_label,$wt_label);

	# Simple insertion?
	#     wt sequence = null
	# mutant sequence = name of transposon or the actual full sequence 
	if ($type =~ /insertion/i) {

	    # Is this a transposon insertion?
	    # mutant sequence just the name of the transposon
	    if ($var->Transposon_insertion || $var->Method eq 'Transposon_insertion') {
		$mut = $var->Transposon_insertion;
		$mut ||= 'unknown' if $var->Method eq 'Transposon_insertion';
	    } else {
		# Return the full sequence of the deletion.
		# It will be up to the template to truncate.
		$mut = $type->right;
	    }

	} elsif ($type =~ /deletion/i) {
	# Deletion.
	#     wt sequence = the deleted sequence
	# mutant sequence = null

	# For most alleles, the sequence is stored in Ace.
        # For others, we either need to fetch it from GFF or just display the coords.
	
	    # Here's how to fetch the sequence of the deletion from a GFF database
	    # (It is actually stored in the DB for some alleles)
#	    my $segment = $self->variation_segment;
#	    if ($segment) {
#		my ($chrom,$start,$stop) = $self->coordinates($segment);
#		$wt = $segment->dna;
#		if (length($wt) > INDEL_DISPLAY_LIMIT && $stringify) {
#		    $wt  = length ($wt) . ' bp deletion';
#		}
#		$mut = '-';
#	    }

	    # CGH tested deletions.	    
	    $type = "definite deletion" if  ($var->CGH_deleted_probes(1));


	# Substitutions
        #     wt sequence = um, the wt sequence
	# mutant sequence = the mutant sequence
	} elsif ($type =~ /substitution/i) {
	    my $change = $type->right;
	    ($wt,$mut) = eval { $change->row };

	    # Ack. Some of the alleles are still stored as A/G.
	    unless ($wt && $mut) {
		$change =~ s/\[\]//g;
		($wt,$mut) = split("/",$change);
	    }
	}


	# Set wt and mutant labels
	if ($var->SNP(0) || $var->RFLP(0)) {
	    $wt_label = 'bristol';
	    $mut_label = $var->Strain;  # CB4856, 4857, etc
	} else {
	    $wt_label = 'wild type';
	    $mut_label = 'mutant';
	}
	
	push @variations,{ type => $type,
			   wildtype => $wt,
			   mutant   => $mut,
			   wildtype_label => $wt_label,
			   mutant_label   => $mut_label,
	};	
    }
    return \@variations;
}


sub flanking_sequences {
    my $self = shift;
    my $object = $self->object;
    my ($left_flank,$right_flank);
    my $left_flank  = $var->Flanking_sequences(1);
    my $right_flank = $var->Flanking_sequences(2);
    my $data = { description => 'probes used for CGH of deletion alleles',
		 data        => { left_flank => $left_flank,
				  right_flank => $right_flank,
		 },
    };
    return $data;    
}


sub cgh_deleted_probes {
    my $self  = shift;
    my $object = $self->object;

    my ($left_flank,$right_flank);    
    $left_flank  = $var->CGH_deleted_probes(1);
    $right_flank = $var->CGH_deleted_probes(2);       

    my $data = { description => 'probes used for CGH of deletion alleles',
		 data        => { left_flank => $left_flank,
				  right_flank => $right_flank,
		 },
    };
    return $data;
}


# NOT DONE!
sub nucleotide_context {

=pod

    # Display a formatted string that shows the mutation in context
    my $flank = 250;
    my ($wt,$mut,$wt_full,$mut_full,$debug)  = $data->build_sequence_strings(-with_markup => 1);

    $wt_full = "> Wild type N2, with $flank bp flanks<br>$wt_full";
    $mut_full = "> $var with $flank bp flanks<br>$mut_full";

    SubSection('Context',
	       span({-style=>SEQ_STYLE},'...' . $wt . '... -- Wild type' . br .
		    '...' . $mut . '... -- ' . i($var) 
		    . br . br .i('Note: Sequence is reported on the plus strand.')
		    . br
		    . toggle_one({on=>0},'full_sequence','expanded context',p($wt_full),p($mut_full)))
	       ) if ($wt && $mut);

=cut


}

sub deletion_verification {
    my $self = shift;
    my $object = $self->object;
    
    my $data = { description => 'the method used to verify deletion alleles',
		 data        => $object->Deletion_verification,
    };
		     


sub features_affected {
    my $self   = shift;
    my $object = $self->object;


}



1;
