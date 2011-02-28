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

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget 
#
#######################################6

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


=head3 affiliation

This method returns a data structure containing
the affiliation of the lab.

=over

=item PERL API

 $data = $model->affiliation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/affiliation

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub affiliation {
    my $self   = shift;
    my $object = $self->object;
    my ($institute)    = $object->Mail;
    return { description => 'institute or affiliation of the laboratory',
	     data        => "$institute" || undef };
}



=head3 representatives

This method returns a data structure containing
the representatives of the lab.

=over

=item PERL API

 $data = $model->representatives();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/representatives

B<Response example>

<div class="response-example"></div>

=back

=back

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

=head3 phone

This method returns a data structure containing
the phone number of the laboratory.

=over

=item PERL API

 $data = $model->phone();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/phone

B<Response example>

<div class="response-example"></div>

=back

=back

=cut


sub phone {
    my $self   = shift;
    my $object = $self->object;
    my $phone  = $object->Phone;
    my $data   = { description => 'primary phone number for the lab',
		   data        => "$phone" || undef };
    return $data;
}

=head3 fax

This method returns a data structure containing
the fax number of the laboratory.

=over

=item PERL API

 $data = $model->fax();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/fax

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub fax {
    my $self   = shift;
    my $object = $self->object;
    my $fax    = $object->Fax;
    my $data   = { description => 'primary fax number for the lab',
		   data        => "$fax" || undef };
    return $data;
}

=head3 strain_designation

This method returns a data structure containing
an email address for the laboratory.

=over

=item PERL API

 $data = $model->email();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/email

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub email {
    my $self   = shift;
    my $object = $self->object;
    my $email  = $object->E_mail;
    my $data   = { description => 'primary email number for the lab',
		   data        => "$email" || undef };
    return $data;
}

=head3 website

This method returns a data structure containing
the website of the laboratory.

=over

=item PERL API

 $data = $model->website();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/website

B<Response example>

<div class="response-example"></div>

=back

=back

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

=head3 strain_designation

This method returns a data structure containing
the strain designation of the laboratory.

=over

=item PERL API

 $data = $model->strain_designation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/strain_designation

B<Response example>

<div class="response-example"></div>

=back

=back

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


=head3 allele_designation
    
This method returns a data structure containing
the allele designation of the laboratory.

=over

=item PERL API

 $data = $model->allele_designation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/allele_designation

B<Response example>

<div class="response-example"></div>

=back

=back

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

=head2 Laboratory Members

=head3 current_members

This method returns a data structure containing
the current members of the laboratory.

=over

=item PERL API

 $data = $model->members();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/current_members

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub current_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members($object,'Registered_lab_members');

    my $rep = 

    return { description => 'current members of the laboratory',
	     data        => $data };
}
 
=head3 former_members

This method returns a data structure containing
the current members of the laboratory.

=over

=item PERL API

 $data = $model->members();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/former_members

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub former_members {
    my $self = shift;
    my $object = $self->object;
    my $data   = $self->_get_members($object,'Past_lab_members');
    return { description => 'former members of the laboratory',
	     data        => $data };
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

    my @data_pack;

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
    
    my %data = ('name'       => $self->_pack_obj($member,$name),
		'level'      => "$level",
		'start_date' => "$start",
		'end_date'   => "$end",
		'duration'   => "$duration",
	);
    return \%data;
}



#######################################
#
# The Gene Classes widget
#
#######################################

=head2 Gene Classes

=head3 gene_classes

This method returns a data structure containing
gene classes assigned to the laboratory.

=over

=item PERL API

 $data->gene_classes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/gene_classes

B<Response example>

<div class="response-example"></div>

=back

=back

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

=head2 Alleles

=head3 alleles

This method returns a data structure containing
alleles generated by the laboratory.

=over

=item PERL API

 $data = $model->alleles();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/alleles

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub alleles {
    my $self   = shift;
    my $object = $self->object;

    my @alleles = $object->Alleles;
    my @data;
    foreach (@alleles) {
	my $gene = $_->Gene;
	my $type = $_->Type_of_mutation;
	push @data,{ allele    => $self->_pack_obj($_,$_->Public_name),
		     gene      => $gene ? $self->_pack_obj($gene,$gene->Public_name) : undef,
		     type      => "$type",
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

=head2 Strains

=head3 strains

This method returns a data structure containing
strains generated by the laboratory.

=over

=item PERL API

 $data = $model->strains();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A laboratory ID (eg EG)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/laboratory/EG/strains

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

sub strains {
    my $self   = shift;
    my $object = $self->object;
    my $dbh    = $self->ace_dsn->dbh;
    my @strains = $dbh->fetch(-query=>qq{find Strain "$object*"});
    
    my @data;
    foreach (@strains) {
	my $genotype = $_->Genotype;
	push @data,{ strain => $self->_pack_obj($_),
		     genotype => "$genotype" };
    }
    return { description => 'strains generated by the laboratory',
	     data        => @data ? \@data : undef,
    };
}



1; 
