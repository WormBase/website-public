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

=head1 METHODS

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


####### publication data ########

has 'publication_hr' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
    	
	my $self = shift;
	my $object = $self->object;
	my %data_pack;
	
	#### data pull and packaging
	
	my @papers = $object->Paper;
	
	foreach my $paper (@papers) {
	    my $paper_id = $paper;
		my @authors = $paper->Author;
		my $brief_citation = $paper->Brief_citation;
		my $type = 'Paper';
		
		
		my $publication_date = $paper->Publication_date; 
		my ($publication_year, $disc) = split /\-/,$publication_date;
		
		my $meeting_abstract;
		$meeting_abstract = $paper->Meeting_abstract;
		
		if ($meeting_abstract) {
		
			$type = 'Meeting_abstact';
		}
		
		my %publication_info = (
			'label' => "$brief_citation",
			'class' => 'Paper',
			'id' => "$paper_id"
		);
		
		if ($data_pack{$type}{$publication_year}) {
			
			my $pub_ar = $data_pack{$type}{$publication_year};
			push @$pub_ar, \%publication_info;
		}
		else {
		
			$data_pack{$type}{$publication_year} = [\%publication_info];
		}	
	}
	
	####

	return \%data_pack;
    
    }

);

=head1 Methods

=cut


#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=head3 name

This method will return a data structure of the name
of the person.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/name

=head5 Response example

 { "name"        :   
   "class"       : "person",
   "uri":"http://api.wormbase.org/page/person/WBPerson242"}
   { "data"    : { "class" : "Person",
                   "label" : "Anne Hart",
                   "id"    : "WBPerson242"
                 },
    "description" : "full (standard) name of the person"},
   }
 }

=cut			 

sub name {
    my $self   = shift;
    my $object = $self->object;
    my $name   = $object->name;
    my $data   = { description => 'full (standard) name of the person',
		   data        => $self->_pack_obj($object,$object->Standard_name)
    };
    return $data;
}

=head3 id

This method returns a data structure containing the 
internal WormBase ID of the person.

=head4 PERL API

 $data = $model->id();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/id

=head5 Response example

 { "name"   : "WBPerson242",
   "class"  : "person",
   "uri"    : "http://todd.wormbase.org/page/person/WBPerson242", 
   "id"     : { "data"        : "WBPerson242", 
                "description" : "the WormBase ID of the person"},
 }

=cut

sub id {
    my $self   = shift;
    my $object = $self->object;
    my $data   = {  description => 'the WormBase ID of the person',
		    data        =>  $object->name };
    return $data;
}


=head3 street_address

This method returns a data structure containing the 
street address of the person, if known.

=head4 PERL API

 $data = $model->street_address();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/street_address

=head5 Response example

 { "name"           : "WBPerson242",
   "class"          : "person",
   "uri"            : "http://todd.wormbase.org/page/person/WBPerson242"}                               
   "street_address" : { "data" : [ "Department of Neuroscience",
                                   "Brown University",
                                   "185 Meeting Street, SFH458",
                                   "Mailbox GL-N",
                                   "Providence, RI 02912"
                                 ],
                         "description" : "street address of the person"
                      },
 }

=cut

sub street_address {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { data        => $address->{street_address} || undef,
		 description => 'street address of the person'}; 
    return $data;
}


=head3 country

This method returns a data structure containing the 
country that the person lives in, if known.

=head4 PERL API

 $data = $model->country();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/country

=head5 Response example

 { "name"    : "WBPerson242",
   "class"   : "person",    
   "uri"     : "http://todd.wormbase.org/page/person/WBPerson242"}     
   "country" : { "data" : "United States of America",
                 "description" : "country of residence of the person, if known"
               },
 }

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

=head4 PERL API

 $data = $model->institution();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/institution

=head5 Response example

 { "name"           : "WBPerson242",
   "class"          : "person",
   "uri"            : "http://todd.wormbase.org/page/person/WBPerson242"}                               
   "institution"    : { "data" : "Brown University, Providence RI, USA",
                        "description" : "the institutional affiliation of the person",
                      }, 
 }

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

=head4 PERL API

 $data = $model->email();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/email

=head5 Response example

 { "name"           : "WBPerson242",
   "class"          : "person",
   "uri"            : "http://todd.wormbase.org/page/person/WBPerson242"}
   "email" : { "data" : [ "myemail@yahoo.com",
                          "myotheremail@gmail.com" ],
              "description" : "email addresses of the person, if known",
   },
 }

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

=head4 PERL API

 $data = $model->lab_phone();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/lab_phone

=head5 Response example

 { "name"       : "WBPerson242",
   "class"      : "person",
   "uri"        : "http://todd.wormbase.org/page/person/WBPerson242"}
   "lab_phone"  : { "data" : "1-123-456-7890",
                    "description" : "laboratory phone of the person",
                  },
 }

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

=head4 PERL API

 $data = $model->office_phone();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/office_phone

=head5 Response example

 { "name"         : "WBPerson242",
   "class"        : "person",
   "uri"          : "http://todd.wormbase.org/page/person/WBPerson242"}
   "office_phone" : { "data" : "1-345-678-9876"
                      "description" : "office phone number of the person, if known",
   },
 }

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

=head4 PERL API

 $data = $model->street_other_phone();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/other_phone

=head5 Response example

 { "name"        : "WBPerson242",
   "class"       : "person",
   "uri"         : "http://todd.wormbase.org/page/person/WBPerson242"}
   "other_phone" : { "data"        : "1-234-567-9876"
                     "description" : "other phone numbers of the person },
   },
 }

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

=head4 PERL API

 $data = $model->fax();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/fax

=head5 Response example

 { "name"      : "WBPerson242",
   "class"     : "person",
   "uri"       : "http://todd.wormbase.org/page/person/WBPerson242"}
   "fax"       : { "data" : "1-234-444-4455",
                   "description" : "fax number of the person, if known",
   },
 }

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

=head4 PERL API

 $data = $model->web_page();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/web_page

=head5 Response example

 { "name"        : "WBPerson242",
   "class"       : "person",
   "uri"         : "http://todd.wormbase.org/page/person/WBPerson242"}
   "web_page"    : { "data"        : "www.myawesomelabwebsite.org"
                     "description" : "web site of the person, if known",
   },
 }

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

# laboratory() is provided by Object.pm. Documentation
# duplicated here for completeness of API

=head3 laboratory

This method returns a data structure containing
the lab affilition of the the person.

=head4 PERL API

 $data = $model->laboratory();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/laboratory

=head5 Response example

<div class="response-example"></div>

=cut

=head3 previous_laboratories

This method returns a data structure containing
previous laboratories of the person, as well as
the current representative of that lab.

=head4 PERL API

 $data = $model->previous_laboratories();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/previous_laboratories

=head5 Response example

<div class="response-example"></div>

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

=head4 PERL API

 $data = $model->strain_designation();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/strain_designation

=head5 Response example

<div class="response-example"></div>

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

=head4 PERL API

 $data = $model->allele_designation();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/allele_designation

=head5 Response example

<div class="response-example"></div>

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

=head4 PERL API

 $data = $model->lab_representative();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/lab_representative

=head5 Response example

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

=head3 gene_classes

This method returns a data structure containing
gene classes assigned to the current lab affiliation
of the person.

=head4 PERL API

 $data->gene_classes();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/gene_classes

=head5 Response example

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





#######################################
#
# The Tracking widget
#
#######################################

=head3 possibly_publishes_as

This method returns a data structure containing
other names that the person might possibly publishh under.

=head4 PERL API

 $data->possibly_publishes_as();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/possibly_publishes_as

=head5 Response example

<div class="response-example"></div>

=cut

sub possibly_publishes_as {
    my $self = shift;
    my $object = $self->object;
    
    my @names = map { "$_" } $object->Possibly_publishes_as;
    my $data = { description => 'other names that the person might publish under',
		 data        => \@names };
    return $data;
}

=head3 status

This method returns a data structure containing
the current curation status of this person.

=head4 PERL API

 $data = $model->status();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/status

=head5 Response example

<div class="response-example"></div>

=cut

sub status {
    my $self   = shift;
    my $object = $self->object;
    my $status = $object->Status;
    my $data   = { data        => "$status",
		   description => 'current status of curation of this person',
    };
    return $data;
}


=head3 last_verified

This method returns a data structure containing
the date the information about this person was
last verified.

=head4 PERL API

 $data->last_verified();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/last_verified

=head5 Response example

<div class="response-example"></div>

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

=head4 PERL API

 $data = $model->supervised();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/supervised

=head5 Response example

 { "name"        : "WBPerson242",
   "class"       : "person",
   "description" : "people supervised by this person"},
   "uri"         : "http://todd.wormbase.org/page/person/WBPerson242"
   "supervised"  : { "data": [{
                                "name": {"class": "Person",
                                         "label": "Emily Bates",
                                         "id"   : "WBPerson1652"},
                                "level": "Phd | Lab visitor | Grad",
                                "start_date" : "01 JAN 1998 00:00:00",
                                "end_date"   : "01 JAN 1999 00:00:00",
                                "duration":"1998-1999",
		 	      }],
 }

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

=head4 PERL API

 $data = $model->supervised_by();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/supervised_by

=head5 Response example

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

=head4 PERL API

 $data = $model->worked_with();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

WBPerson ID

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/worked_with

=head5 Response example

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
#
# Likely all to go away; will still need support for the API
#
#######################################
sub papers {
    my $self = shift;
    my %data;
    my $description = 'Papers by the person';
    my $publication_hg = $self->publication_hr;
    my $data_pack = $publication_hg->{'Paper'};
    
    $data{'data'} = $data_pack;
    $data{'description'} = $description;
    
    return \%data;
    
}


sub meeting_abstracts {
    my $self = shift;
    my %data;
    my $description = 'Meeting presentations by the person';
    my $publication_hg = $self->publication_hr;
    my $data_pack = $publication_hg->{'Meeting_abstact'};
    
    $data{'data'} = $data_pack;
    $data{'description'} = $description;
    
    return \%data;
}
sub papers_old {
    
    my $self = shift;
    my $object = $self->object;
    my %data;
    my $desc = 'notes';
    my %data_pack;
    
    #### data pull and packaging
    
    my @papers = $object->Paper;
    
    foreach my $paper (@papers) {
	
	
	my $paper_id = $paper;
	my @authors = $paper->Author;
	my $brief_citation = $paper->Brief_citation;
	my $type = 'Paper';
	
	
	my $publication_date = $paper->Publication_date; 
	my ($publication_year, $disc) = split /\-/,$publication_date;
	
	my $meeting_abstract;
	$meeting_abstract = $paper->Meeting_abstract;
	if ($meeting_abstract) {
	    
	    $type = 'Meeting_abstact';
	}
	
	my %publication_info = (
	    'label' => "$brief_citation",
	    'class' => 'Paper',
	    'id' => "$paper_id"
	    );
	
	if ($data_pack{$type}{$publication_year}) {
	    
	    my $pub_ar = $data_pack{$type}{$publication_year};
	    push @$pub_ar, \%publication_info;
	}
	else {
	    
	    $data_pack{$type}{$publication_year} = [\%publication_info];
	}
	
    }
    
    ####
    
    $data{'data'} = \%data_pack;
    $data{'description'} = $desc;
    return \%data;
}




#######################################
#
# Name variations at finer granularity
# Provided for external API users; not displayed on Person Summary
#
#######################################
sub first_name {
    my $self = shift;
    my $object     = $self->object;
    my $first_name = $object->First_name;    
    my $data = { description => 'first name of the person',
		 data        => "$first_name" || undef };
    return $data;
}

sub last_name {
    my $self = shift;
    my $object = $self->object;
    my $last_name = $object->Last_name;    
    my $data = { description => 'last name of the person',
		 data        => "$last_name" || undef };
    return $data;
}

sub standard_name {
    my $self = shift;
    my $object = $self->object;
    my $standard_name = $object->Standard_name;    
    my $data = { description => '"standard" name of the person',
		 data        => "$standard_name" || undef };
    return $data;
}    

sub full_name {
    my $self = shift;
    my $object    = $self->object;
    my $full_name = $object->Full_name;    
    my $data = { description => 'full name of the person',
		 data        => "$full_name" || undef };
    return $data;
}

# Probably don't need to be packed, just displayed as strings
sub aka {
    my $self = shift;
    my $object = $self->object;
    my @aka = $object->Also_known_as;    
    @aka = map { $self->_pack_obj($_) } @aka;
    my $data = { description => 'aliases of the person',
		 data        => \@aka || undef };
    return $data;
}





######################
#
# Private methods
#
######################
sub _get_lineage_data {
    my $self   = shift;
    my $tag    = shift;
    my $object = $self->object;
    my @data_pack;
    
    my @relationship = $object->$tag;
    
    foreach my $relation (@relationship) {	
	my $name = $relation->Standard_name;
	my ($level, $start, $end) = $relation->right->row;
	my @end_date;
	
	if (!($end =~ m/present/i)) {
	    @end_date = split /\ /,$end; 
	}
	
	my @start_date = split /\ /,$start; 
	
	my $duration = "$start_date[2]\ \-\ $end_date[2]"; 
	
	push @data_pack, {
	    'name'       => $self->_pack_obj($relation,$name),
	    'level'      => "$level",
	    'start_date' => "$start",
	    'end_date'   => "$end",
	    'duration'   => "$duration"
	};
    }	
    return \@data_pack;
}


1;
