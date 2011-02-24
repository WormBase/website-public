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



=head2 affiliation

This method returns a data structure containing
the affiliation of the lab.

=head3 PERL API

 $data = $model->affiliation();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/affiliation

=head4 Response example

<div class="response-example"></div>

=cut

sub affiliation {
    my $self   = shift;
    my $object = $self->object;
    my ($institute,@address)    = $object->Address(2);
    return { description => 'institute or affiliation of the laboratory',
	     data        => "$institute" || undef };
}



=head2 representatives

This method returns a data structure containing
the representatives of the lab.

=head3 PERL API

 $data = $model->representatives();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/representatives

=head4 Response example

<div class="response-example"></div>

=cut

sub representatives {
    my $self   = shift;
    my $object = $self->object;
        
    my @data;
    my @reps = $object->Representative;
    foreach (@reps) {
	push @data,$self->_pack_obj($_,$_->Standard_name);
    }
    
    my $data = { description => 'official representatives of the laboratory',
		 data        => @data ? \@data : undef };
    return $data;
}

=head2 phone

This method returns a data structure containing
the phone number of the laboratory.

=head3 PERL API

 $data = $model->phone();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/phone

=head4 Response example

<div class="response-example"></div>

=cut


sub phone {
    my $self   = shift;
    my $object = $self->object;
    my $phone  = $object->Phone;
    my $data   = { description => 'primary phone number for the lab',
		   data        => "$phone" || undef };
    return $data;
}

=head2 fax

This method returns a data structure containing
the fax number of the laboratory.

=head3 PERL API

 $data = $model->fax();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/fax

=head4 Response example

<div class="response-example"></div>

=cut

sub fax {
    my $self   = shift;
    my $object = $self->object;
    my $fax    = $object->Fax;
    my $data   = { description => 'primary fax number for the lab',
		   data        => "$fax" || undef };
    return $data;
}

=head2 strain_designation

This method returns a data structure containing
an email address for the laboratory.

=head3 PERL API

 $data = $model->email();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/email

=head4 Response example

<div class="response-example"></div>

=cut

sub email {
    my $self   = shift;
    my $object = $self->object;
    my $email  = $object->Email;
    my $data   = { description => 'primary email number for the lab',
		   data        => "$email" || undef };
    return $data;
}

=head2 website

This method returns a data structure containing
the website of the laboratory.

=head3 PERL API

 $data = $model->website();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/website

=head4 Response example

<div class="response-example"></div>

=cut

sub website {
    my $self   = shift;
    my $object = $self->object;
    my $url    = $object->URL;
    my ($protocol, $url) = split '://', $url;
    my $data   = { description => 'website of the lab',
		   data        => "$url" || undef };
    return $data;
}

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
    my $name = $object->name;
             
    my $data = { description => 'strain designation of the laboratory',
#		 data        => $self->_pack_obj($object) };
		 data        => "$name" };
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
    my $allele_designation = $object->Allele_designation->name;
    my $data = { description => 'allele designation of the laboratory',
		 data        => "$allele_designation" };
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
    my $data   = $self->_get_members($object,'Registered_lab_members');
    return { description => 'current members of the laboratory',
	     data        => $data };
}
 
sub former_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members($object,'Past_lab_members');
    return { description => 'former members of the laboratory',
	     data        => $data };
}
   
sub _get_members {
    my ($self,$object,$tag) = @_;
    
    my @members = $object->$tag;
    my %data;

# Should also try to discern the relationship
# but necessarily convoluted.
#    my $rep = $object->Representative;
    foreach my $member (@members) {
	my $name = $member->Standard_name;
	$data{$member->Last_name} = $self->_pack_obj($member,$name);
    }
    return \%data;
}




#######################################
#
# The Gene Classes widget
#
#######################################

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

    my @data;
    my @gene_classes = $object->Gene_classes;
    foreach (@gene_classes) {
	my $description = $_->Description;
	push @data,{ gene_class => $self->_pack_obj($_),
		     description => "$description" };
    }
    my $data = { description => 'gene classes assigned to laboratory',
		 data        => @data ? \@data : undef };
    return $data;
}

#######################################
#
# The Alleles widget
#
#######################################


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
	my $gene = $_->Gene;
	push @data,{ allele => $self->_pack_obj($_,$_->Public_name),
		     gene   => $gene ? $self->_pack_obj($gene,$gene->Public_name) : undef,
	};
    }
    return { description => 'alleles generated by the laboratory',
	     data        => @data ? \@data : undef,
    };
}


1; 
