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

http://wormbase.org/resource/laboratory

=head1 TODO

=head1 METHODS

=cut


#######################################
#
# The Overview widget 
#
#######################################

=head2 name

This method will return a data structure of the 
name and ID of the requested laboratory.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/name

=head4 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}


=head2 lab_representative

This method returns a data structure containing
the current lab representative of the affiliated lab.

=head3 PERL API

 $data = $model->lab_representative();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

WBPerson ID

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/lab_representative

=head4 Response example

<div class="response-example"></div>

=cut

sub lab_representative {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;
    
    my $rep;
    if ($lab) { 
	my $representative = $lab->Representative;
	my $name = $representative->Standard_name; 
	$rep = $self->_pack_obj($representative,$name);
    }
    
    my $data = { description => 'official representative of the laboratory',
		 data        => $rep || undef };
    return $data;
}

sub representatives {

      my $self = shift;
      my $lab = $self->object;
      my %data;
      my $desc = 'notes';
      my %data_pack;

      #### data pull and packaging
    
      my @representatives = $lab->Representative;

   	foreach my $rep (@representatives) {
		my $name = $rep->Standard_name;
		my $laboratory = $rep->Laboratory;
		my @a   = $rep->Address(2);
		foreach (@a) {
	  		$_ = $_->right if $_->right;  # AtDB damnation
		}

		my $email = $rep->get('Email' => 1);
		$email = eval{$email->right if $email->right;};

		$data_pack{$rep} = {
	      'ace_id' => $rep,
	      'name' => $name,
	      'laboratory' => $laboratory,
	      'class' => 'Person',
	      'address' => \@a,
	      'email' => $email
	  	};

	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub phone {
    my $self   = shift;
    my $object = $self->object;
    my $phone  = $object->Phone;
    my $data   = { description => 'primary phone number for the lab',
		   data        => "$phone" : undef };
    return $data;
}

sub fax {
    my $self   = shift;
    my $object = $self->object;
    my $fax    = $object->Fax;
    my $data   = { description => 'primary fax number for the lab',
		   data        => "$fax" : undef };
    return $data;
}

sub email {
    my $self   = shift;
    my $object = $self->object;
    my $email  = $object->Email;
    my $data   = { description => 'primary email number for the lab',
		   data        => "$email" : undef };
    return $data;
}

sub website {
    my $self   = shift;
    my $object = $self->object;
    my $url    = $object->URL;
    my ($protocol, $url) = split '://', $url;
    my $data   = { description => 'website of the lab',
		   data        => "url" : undef };
    return $data;
}







#######################################
#
# The Members widget
#
#######################################

=head2 current_members

This method returns a data structure containing
the current members of the laboratory.

=head3 PERL API

 $data = $model->members();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A laboratory ID (eg EG)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/current_members

=head4 Response example

<div class="response-example"></div>

=cut

sub current_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members('Registered_lab_members');
    return { description => 'current members of the laboratory',
	     data        => @data ? \@data : undef };
}
 
sub former_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members('Past_lab_members');
    return { description => 'former members of the laboratory',
	     data        => @$data ? $data : undef };
}
   
sub _get_members {
    my ($self,$tag) = @_;
	
    my @members = $object->$tag;
    my @data;
    foreach my $member (@members) {
	my $name = $member->Standard_name;
	push @data,$self->pack_obj($member,$name);
    }
    return \@data;
}



#######################################
#
# The Genes widget
#
#######################################

=head2 strain_designation

This method returns a data structure containing
the strain designation of the laboratory.

=head3 PERL API

 $data = $model->strain_designation();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

WBPerson ID

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/strain_designation

=head4 Response example

<div class="response-example"></div>

=cut

sub strain_designation {
    my $self   = shift;
    my $object = $self->object;
       
    my $lab   = $object->Laboratory;
    $lab = $self->_pack_obj($lab) if $lab;
       
    my $data = { description => 'strain designation of the laboratory',
		 data        => $lab || undef };
    return $data;		     
}

=head2 allele_designation

This method returns a data structure containing
the allele designation of the laboratory.

=head3 PERL API

 $data = $model->allele_designation();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

WBPerson ID

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/allele_designation

=head4 Response example

<div class="response-example"></div>

=cut

sub allele_designation {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;
    my $allele_designation = ($lab) ? $lab->Allele_designation->name : undef;
    my $data = { description => 'allele designation of the laboratory',
		 data        => $allele_designation };
    return $data;
}



=head2 gene_classes

This method returns a data structure containing
gene classes assigned to the laboratory.

=head3 PERL API

 $data->gene_classes();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

WBPerson ID

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/gene_classes

=head4 Response example

<div class="response-example"></div>

=cut


sub gene_classes {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;

    my @gene_classes = $lab ? $lab->Gene_classes : undef;
    @gene_classes = map { $self->_pack_obj($_) } @gene_classes;
    
    my $data = { description => 'gene classes assigned to laboratory',
		 data        => \@gene_classes };
    return $data;
}


=head2 alleles

This method returns a data structure containing
alleles generated by the laboratory.

=head3 PERL API

 $data->alleles();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A laboratory ID (eg EG)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/alleles

=head4 Response example

<div class="response-example"></div>

=cut


sub alleles {
    my $self   = shift;
    my $object = $self->object;

    my @alleles = $object->Alleles;
    my @data;
    foreach (@alleles) {
	my $gene = $_->Corresponding_gene;  # Correct?
	push @data,{ name => $self->_pack_obj($_,$_->Public_name),
		     gene => $gene ? $self->_pack_obj($gene,$gene->Public_name) : undef,
	};
    }
    return { description => 'alleles generated by the laboratory',
	     data        => @data ? \@data : undef,
    };
}







##########
## details - mostly deprecated
##########

sub details {

	my $self = shift;
	my $lab = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my ($institution,@address)    = $lab->Address(2);

	%data_pack = (

	  'name' => "$lab",
	  'instituion' => $institution,
	  );


}



1; 
