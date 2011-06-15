package WormBase::API::Object::Person;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Person

=head1 SYNPOSIS

Model for the Ace ?Person class.

=head1 URL

http://wormbase.org/resources/person

=cut

has 'address_data' => (
    is   => 'ro',
    isa  => 'HashRef',	
    lazy => 1,
    default => sub {	
	my $self = shift;
	my $object = $self->object;
	my %address;
	
	foreach my $tag ($object->Address) {
	    if ($tag =~ m/street|email|office/i) {		
		my @data = map { $_->name } $tag->col;
		$address{lc($tag)} = \@data;
	    } else {
		$address{lc($tag)} =  $tag->right->name;
	    }
	}
	return \%address;
    }
    );

has 'publication_data' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
    	
	my $self   = shift;
	my $object = $self->object;
	my %data;       
	
	foreach my $paper ($object->Paper) {
	    my @authors = $paper->Author;
	    my $brief_citation = $paper->Brief_citation;
	    
	    my $date = $paper->Publication_date; 
	    my ($year, $disc) = split /\-/,$date;	   

	    my $type = $paper->Meeting_abstract ? 'Meeting_abstract' : 'Paper';
	    

	    push @{$data{$type}{$year}},
	    { brief_citation => "$brief_citation",
	      object         => $self->_pack_obj($paper,"$brief_citation")
	    };	    
	}	
	return \%data;	
    }
    
);

#######################################
#
# CLASS METHODS
#
#######################################

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut



#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 street_address

This method returns a data structure containing the 
street address of the person, if known.

=over

=item PERL API

 $data = $model->street_address();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/street_address

B<Response example>

<div class="response-example"></div>

=back

=cut

sub street_address {
    my $self    = shift;
    my $address = $self->address_data;
    return { data        => $address->{street_address} || undef,
	     description => 'street address of the person'}; 
}


=head3 country

This method returns a data structure containing the 
country that the person lives in, if known.

=over

=item PERL API

 $data = $model->country();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/country

<div class="response-example"></div>

=back

=cut

sub country {    
    my $self = shift;
    my $address = $self->address_data;
    my $data    = { description => 'country of residence of person, if known',
		    data        => $address->{country} || undef };
    return $data;
}

=head3 institution
    
This method returns a data structure containing the 
institution of the person, if known.

=over

=item PERL API

 $data = $model->institution();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/institution

B<Response example>

<div class="response-example"></div>

=back

=cut

sub institution {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'the institutional affiliation of the person',
		 data        => $address->{institution} || undef };
    return $data;
}

=head3 email

This method returns a data structure containing the 
email addresses of the person, if known.

=over

=item PERL API

 $data = $model->email();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/email

B<Response example>

<div class="response-example"></div>

=back

=cut

sub email {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'email addresses of the person',
		 data        => $address->{email} || undef };
    return $data;
}

=head3 lab_phone
    
This method returns a data structure containing the 
lab phone number of the person, if known.

=over

=item PERL API

 $data = $model->lab_phone();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/lab_phone

B<Response example>

<div class="response-example"></div>

=back

=cut

sub lab_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'laboratory phone of the person',
		 data        => $address->{lab_phone} || undef };
    return $data;
}

=head3 office_phone

This method returns a data structure containing the 
office phone of the person, if known.

=over

=item PERL API

 $data = $model->office_phone();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/office_phone

B<Response example>

<div class="response-example"></div>

=back

=cut

sub office_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'office phone of the person',
		 data        => $address->{office_phone} || undef };
    return $data;
}

=head3 other_phone

This method returns a data structure containing
other phone numbers of the person.

=over

=item PERL API

 $data = $model->street_other_phone();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/other_phone

B<Response example>

<div class="response-example"></div>

=back


=cut

sub other_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'other contact numbers for of the person',
		 data        => $address->{other_phone} || undef };
    return $data;
}

=head3 fax

This method returns a data structure containing the 
fax number of the person, if known.

=over

=item PERL API

 $data = $model->fax();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request examplr>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/fax

B<Response example>

<div class="response-example"></div>

=back

=cut

sub fax {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'fax number(!) of the person',
		 data        => $address->{fax} || undef };
    return $data;   
}


=head3 web_page

This method returns a data structure containing the 
web site of the person, if known.

=over

=item PERL API

 $data = $model->web_page();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/web_page

B<Response example>

<div class="response-example"></div>

=back


=cut

sub web_page {
    my $self    = shift;
    my $address = $self->address_data;
    my $url = $address->{web_page};
    $url =~ s/HTTP\:\/\///;
    
    my $data = { description => 'web address of the person',
		 data        => $url || undef };
    return $data;   
}




#######################################
#
# The Laboratory Widget
#
#######################################

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

=head3 previous_laboratories

This method returns a data structure containing
previous laboratories of the person, as well as
the current representative of that lab.

=over

=item PERL API

 $data = $model->previous_laboratories();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/previous_laboratories

B<Response example>

<div class="response-example"></div>

=back

=cut

sub previous_laboratories {
    my $self   = shift;
    my $object = $self->object;
    
    my @labs  = $object->Old_laboratory;
    my @data;
    foreach (@labs) {
	my $representative = $_->Representative;
	my $name = $representative->Standard_name; 
	my $rep = $self->_pack_obj($representative,$name);
	push @data,[ $self->_pack_obj($_),$rep ];
    }
       
    my $data = { description => 'previous laboratory affiliations',
		 data        => (@data > 0) ? \@data : undef};
    return $data;		     
}

=head3 strain_designation

This method returns a data structure containing
the strain designation of the current lab affiliation
of the person.

=over

=item PERL API

 $data = $model->strain_designation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/strain_designation

B<Response example>

<div class="response-example"></div>

=back

=cut

sub strain_designation {
    my $self   = shift;
    my $object = $self->object;
       
    my $lab   = $object->Laboratory;
    $lab = $self->_pack_obj($lab) if $lab;
       
    my $data = { description => 'strain designation of the affiliated lab',
		 data        => $lab || undef };
    return $data;		     
}

=head3 allele_designation

This method returns a data structure containing
the allele designation of the current lab affiliation
of the person.

=over

=item PERL API

 $data = $model->allele_designation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/allele_designation

B<Response example>

<div class="response-example"></div>

=back

=cut

sub allele_designation {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;
    my $allele_designation = ($lab) ? $lab->Allele_designation->name : undef;
    my $data = { description => 'allele designation of the affiliated laboratory',
		 data        => $allele_designation };
    return $data;
}

=head3 lab_representative

This method returns a data structure containing
the current lab representative of the affiliated lab.

=over

=item PERL API

 $data = $model->lab_representative();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/lab_representative

B<Response example>

<div class="response-example"></div>

=back

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

=head3 gene_classes

This method returns a data structure containing
gene classes assigned to the current lab affiliation
of the person.

=over

=item PERL API

 $data->gene_classes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/gene_classes

B<Response example>

<div class="response-example"></div>

=back

=cut

sub gene_classes {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;

    my @gene_classes = $lab ? $lab->Gene_classes : undef;
    @gene_classes = map { $self->_pack_obj($_) } @gene_classes;
    
    my $data = { description => 'gene classes assigned to laboratory',
		 data        => @gene_classes ? \@gene_classes : undef};
    return $data;
}





#######################################
#
# The Tracking widget
#
#######################################

=head3 possibly_publishes_as

This method returns a data structure containing
other names that the person might possibly publishh under.

=over

=item PERL API

 $data->possibly_publishes_as();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/possibly_publishes_as

B<Response example>

<div class="response-example"></div>

=back

=cut

sub possibly_publishes_as {
    my $self   = shift;
    my $object = $self->object;
    
    my @names = map { "$_" } $object->Possibly_publishes_as;
    my $data = { description => 'other names that the person might publish under',
		 data        => \@names };
    return $data;
}


# sub status { }
# Supplied by Role; POD will automatically be inserted here.
# << include status >>

=head3 last_verified

This method returns a data structure containing
the date the information about this person was
last verified.

=over

=item PERL API

 $data->last_verified();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/last_verified

B<Response example>

<div class="response-example"></div>

=back

=cut

sub last_verified {
    my $self      = shift;
    my $object    = $self->object;
    my $timestamp = $object->Last_verified;
    my @date = split /\ /, $timestamp;
    my $date = join " ", @date[0 .. 2];
    my $data = { data        => "$date",
		 description => 'date curated information last verified',
    };
    return $data;
}



#######################################
#
# The Lineage Widget
#
#######################################

=head3 supervised

This method will return a data structure of people supervised 
by the query person.

=over

=item PERL API

 $data = $model->supervised();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/supervised

B<Response example>

<div class="response-example"></div>

=back

=cut

sub supervised {    
    my $self = shift;
    my $lineage = $self->_get_lineage_data('Supervised');
    my $data    = { description => 'people supervised by this person',
		    data        => $lineage };
    return $data;
}

=head3 supervised_by

This method will return a data structure containing
people that this person has been supervised by.

=over

=item PERL API

 $data = $model->supervised_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/supervised_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub supervised_by {
    my $self    = shift;
    my $lineage = $self->_get_lineage_data('Supervised_by');       
    my $data    = { description => 'people who supervised this person',
		    data        => $lineage };
    return $data;    
}

=head3 worked_with

This method will return a data structure containing
people that this person has worked or collaborated with.

=over

=item PERL API

 $data = $model->worked_with();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

WBPerson ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/worked_with

B<Response example>

<div class="response-example"></div>

=back

=cut

sub worked_with {
    my $self = shift;
    my $lineage = $self->_get_lineage_data('Worked_with');       
    my $data    = { description => 'people with whom this person worked',
		    data        => $lineage };
    return $data;    
} 
   




#######################################
#
# The Publications widget
#   This is a special instance of references
#
#######################################
sub publications {
    my $self   = shift;
    my $object = $self->object;
    my $publication = $self->publication_data;
    my $data        = $publication->{'Paper'};
    
    return { description => 'Publications by this person',
	     data        => $data };    
}


sub meeting_abstracts {
    my $self = shift;
    my $object = $self->object;

    my $publication = $self->publication_data;
    my $data        = $publication->{'Meeting_abstract'};
    
    return { description => 'Publications by this person',
	     data        => $data };    
}




#######################################
#
# Name variations at finer granularity
# Provided for external API users; not displayed on Person Summary
#
#######################################
# Can probably deprecate all of these methods.
#sub first_name {
#    my $self = shift;
#    my $object     = $self->object;
#    my $first_name = $object->First_name;    
#    my $data = { description => 'first name of the person',
#		 data        => "$first_name" || undef };
#    return $data;
#}
#
#sub last_name {
#    my $self = shift;
#    my $object = $self->object;
#    my $last_name = $object->Last_name;    
#    my $data = { description => 'last name of the person',
#		 data        => "$last_name" || undef };
#    return $data;
#}
#
#sub standard_name {
#    my $self = shift;
#    my $object = $self->object;
#    my $standard_name = $object->Standard_name;    
#    my $data = { description => '"standard" name of the person',
#		 data        => "$standard_name" || undef };
#    return $data;
#}    
#
#sub full_name {
#    my $self = shift;
#    my $object    = $self->object;
#    my $full_name = $object->Full_name;    
#    my $data = { description => 'full name of the person',
#		 data        => "$full_name" || undef };
#    return $data;
#}
#
## Probably don't need to be packed, just displayed as strings
#sub aka {
#    my $self = shift;
#    my $object = $self->object;
#    my @aka = $object->Also_known_as;    
#    @aka = map { $self->_pack_obj($_) } @aka;
#    my $data = { description => 'aliases of the person',
#		 data        => \@aka || undef };
#    return $data;
#}





######################
#
# Private methods
#
######################
sub _get_lineage_data {
    my $self   = shift;
    my $tag    = shift;
    my $object = $self->object;
    
    my @relationship = $object->$tag;
    my @data;
    foreach my $relation (@relationship) {	
	my $name = $relation->Standard_name;
	my ($level, $start, $end) = $relation->right->row;
	my @end_date;
	
	if (!($end =~ m/present/i)) {
	    @end_date = split /\ /,$end; 
	}
	
	my @start_date = split /\ /,$start; 
	
	my $duration = "$start_date[2]\ \-\ $end_date[2]"; 
	
	push @data, {
	    'name'       => $self->_pack_obj($relation,$name),
	    'level'      => "$level",
	    'start_date' => "$start",
	    'end_date'   => "$end",
	    'duration'   => "$duration"
	};
    }	
    return @data ? \@data : undef;
}


__PACKAGE__->meta->make_immutable;

1;

