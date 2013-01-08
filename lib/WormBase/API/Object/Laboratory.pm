package WormBase::API::Object::Laboratory;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Laboratory

=head1 SYNPOSIS

Model for the Ace ?Laboratory class.

=head1 URL

http://wormbase.org/resources/laboratory

=cut


#######################################
#
# CLASS METHODS
#
#######################################

# all_labs { }
# This method returns a data structure containing
# all laboratories registered with WormBase.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/all/all_labs

{ # temporary fix. see Gene_class for comment on class methods
    my $all_labs;

    sub all_labs {
        my $self   = shift;

        return $all_labs ||= {
            description => 'all labs registered with WormBase and the Caenorhabditis Genetics Center',
            data        => [
                map {
                    my $url = $_->URL ; # raw_fetch candidate
                    if (defined $url) {
                        (my $tmp = lc $url) =~ s{^(?!http://)}{http://};
                        $url = $tmp;
                    }

                    {
                        lab                => $self->_pack_obj($_),
                        representative     => $self->_pack_obj(scalar $_->Representative)
			    // $_->name,
			    email              => map { "$_" } scalar eval { $_->E_mail->name },
			    allele_designation => $_->Allele_designation ? map { "$_" } $_->Allele_designation : '',
			    url                => "$url",
			    affiliation        => map { "$_" } scalar eval { ($_->Mail)[0] },
                    };
                } $self->ace_dsn->dbh->fetch(-query => "find Laboratory")
            ],
        };
    }
}




#######################################
#
# INSTANCE METHODS
#
#######################################

#######################################
#
# The Overview widget 
#
#######################################6

# name { }
# Supplied by Role

# affiliation { }
# This method returns a data structure containing
# the affiliation of the lab.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/affiliation

sub affiliation {
    my $self   = shift;
    my $object = $self->object;
    my ($institute)    = $object->Mail;
    return { description => 'institute or affiliation of the laboratory',
	     data        => "$institute" || undef };
}

# representatives { }
# This method returns a data structure containing
# the representatives of the lab.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/representatives

sub representatives {
    my $self   = shift;
    my $object = $self->object;
    
    my @data;
    my @reps = $object->Representative;
    foreach (@reps) {
	my $name = $_->Standard_name;
	push @data,$self->_pack_obj($_, "$name");
    }
    
    return { description => 'official representatives of the laboratory',
		 data    => @data ? \@data : undef };
}

# phone { }
# This method returns a data structure containing
# the phone number of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/phone

sub phone {
    my $self   = shift;
    my $object = $self->object;
    my $phone  = $object->Phone;
    return { description => 'primary phone number for the lab',
	     data        => "$phone" || undef };
}

# fax { }
# This method returns a data structure containing
# the fax number of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/fax

sub fax {
    my $self   = shift;
    my $object = $self->object;
    my $fax    = $object->Fax;
    return { description => 'primary fax number for the lab',
	     data        => "$fax" || undef };
}

# email { }
# This method returns a data structure containing
# an email address for the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/email

sub email {
    my $self   = shift;
    my $object = $self->object;
    my $email  = $object->E_mail;
    return { description => 'primary email address for the lab',
	     data        => "$email" || undef };
}

# website { }
# This method returns a data structure containing
# the website of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/website

sub website {
    my ($self) = @_;
    my ($scheme, $url) = split '://', $self ~~ 'URL', 2;
    return { description => 'website of the lab',
	     data        => $url };
}

# strain_designation { }
# This method returns a data structure containing
# the strain designation of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/strain_designation

sub strain_designation {
    my $self   = shift;
    my $object = $self->object;
    my $name = $object->name;
             
    return { description => 'strain designation of the laboratory',
	     data        => "$name" || undef };
}


# allele_designation { }
# This method returns a data structure containing
# the allele designation of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/allele_designation

sub allele_designation {
    my $self   = shift;
    my $object = $self->object;
    my $allele_designation = $object->Allele_designation->name if $object->Allele_designation;
    return { description => 'allele designation of the laboratory',
	     data        => $allele_designation && "$allele_designation" };
}



#######################################
#
# The Members widget
#
#######################################

# current_members { }
# This method returns a data structure containing
# the current members of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/current_members

sub current_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members($object,'Registered_lab_members');

    return { description => 'current members of the laboratory',
	     data        => @$data ? $data : undef };
}
 

# former_members { }
# This method returns a data structure containing
# the current members of the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/former_members

sub former_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members($object,'Past_lab_members');
    return { description => 'former members of the laboratory',
	     data        => @$data ? $data : undef };
}

sub _get_members {
    my ($self,$object,$tag) = @_;
    
    my @data;
    my @members = $object->$tag;
    foreach my $member (@members) {
	my $lineage_info = $self->_get_lineage_data($member);
	push @data,$lineage_info;
    }
    return \@data;
}


sub _get_lineage_data {
    my ($self,$member) = @_;
    my $object = $self->object;
   
    
    my %relationships = map { $_ => $_ } ($member->Supervised,$member->Supervised_by,$member->Worked_with);

    my $rep    = $object->Representative;
    my $relationship = $relationships{$rep};
    my ($level,$start,$end,$duration);
    if ($relationship) {
	($level, $start, $end) = $relationship->right->row;       

	my @end_date;
	if ($end !~ m/present/i) {	    
	    @end_date = split /\ /,$end; 
	    $end = $end_date[2];
	}
	
	my @start_date = split /\ /,$start; 
	$start = $start_date[2];
	
	$duration = "$start_date[2]\ \-\ $end_date[2]"; 
    }
    my $name = $member->Standard_name;
    
    return { 'name'       => $self->_pack_obj($member,$name && "$name"),
	     'level'      => $level && "$level",
	     'start_date' => $start && "$start",
	     'end_date'   => $end && "$end",
	     'duration'   => $duration && "$duration" };
}



#######################################
#
# The Gene Classes widget
#
#######################################

# gene_classes { }
# This method returns a data structure containing
# gene classes assigned to the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/gene_classes

sub gene_classes {
    my $self   = shift;
    my $object = $self->object;

    my @data;
    my @gene_classes = $object->Gene_classes;
    foreach (@gene_classes) {
	my $description = $_->Description;
	push @data,{ gene_class => $self->_pack_obj($_),
		     description => $description && "$description" };
    }
    return { description => 'gene classes assigned to laboratory',
		 data    => @data ? \@data : undef };
}

#######################################
#
# The Alleles widget
#
#######################################

# alleles { }
# This method returns a data structure containing
# alleles generated by the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/alleles

sub alleles {
    my $self   = shift;
    my $object = $self->object;
    my @alleles = $object->Alleles;
    my @data;
    foreach (@alleles) {
	my $gene = $_->Gene;
	my $type = $_->Type_of_mutation;
	my $allele_name = $_->Public_name;
	my $gene_name = $gene->Public_name;
	push @data,{ allele    => $self->_pack_obj($_, $allele_name && "$allele_name"),
		     gene      => $self->_pack_obj($gene, $gene_name && "$gene_name"),
		     type      => $type && "$type",
		     sequenced => ($_->Flanking_sequences) ? 'yes' : 'no', 
	};
    }
    return { description => 'alleles generated by the laboratory',
	     data        => @data ? \@data : undef,
    };
}



#######################################
#
# The Strains widget
#
#######################################

# strains { }
# This method returns a data structure containing
# strains generated by the laboratory.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/strains

sub strains {
    my $self   = shift;
    my $object = $self->object;
    my $dbh    = $self->ace_dsn->dbh;
    my @strains = $dbh->fetch(-query=>qq{find Strain "$object*"});
    
    my @data;
    foreach (@strains) {
	my $genotype = $_->Genotype;
	push @data,{ strain => $self->_pack_obj($_),
		     genotype => $genotype && "$genotype" };
    }
    return { description => 'strains generated by the laboratory',
	     data        => @data ? \@data : undef,
    };
}



__PACKAGE__->meta->make_immutable;

1;

