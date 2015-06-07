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
		my @data = map { $_->name } $tag->col;
		$address{lc($tag)} = \@data if @data;
	}

	return \%address;
    }
    );


has 'previous_address_data' => (
    is   => 'ro',
    isa  => 'Maybe[ArrayRef]',
    lazy => 1,
    default => sub {
            my $self = shift;
            my $object = $self->object;
            my @entries;
            foreach my $entry ($object->get('Old_address')) {
                my %address;
                $entry =~ m/^(.*)\s(\S*)$/g;
                $address{date_modified} = $1 && "$1";

                foreach my $tag ($entry->col) {
                    if ($tag =~ m/street|email|office/i) {
                        my @data = map { $_->name } $tag->col;
                        $address{lc($tag)} = \@data;
                    } else {
                        $address{lc($tag)} =  $tag->right->name;
                    }
                }
                push @entries,\%address
            }
            return @entries ? \@entries : undef;
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


#######################################
#
# INSTANCE METHODS
#
#######################################

#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# street_address { }
# This method returns a data structure containing the
# street address of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/street_address

sub street_address {
    my $self    = shift;
    my $address = $self->address_data;
    return { data        => $address->{street_address} || undef,
	     description => 'street address of the person'};
}


# country { }
# This method returns a data structure containing the
# country that the person lives in, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/country

sub country {
    my $self = shift;
    my $address = $self->address_data;
    my $data    = { description => 'country of residence of person, if known',
		    data        => $address->{country} && $address->{country}->[0] };
    return $data;
}

# institution { }
# This method returns a data structure containing the
# institution of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/institution

sub institution {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'the institutional affiliation of the person',
		 data        => $address->{institution} || undef };
    return $data;
}

# email { }
# This method returns a data structure containing the
# email addresses of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/email

sub email {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'email addresses of the person',
		 data        => $address->{email} || undef };
    return $data;
}

# lab_phone { }
# This method returns a data structure containing the
# lab phone number of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/lab_phone
sub lab_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'laboratory phone of the person',
		 data        => $address->{lab_phone} || undef };
    return $data;
}

# office_phone { }
# This method returns a data structure containing the
# office phone of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/office_phone

sub office_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'office phone of the person',
		 data        => $address->{office_phone} || undef };
    return $data;
}

# other_phone { }
# This method returns a data structure containing
# other phone numbers of the person.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/other_phone

sub other_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'other contact numbers for of the person',
		 data        => $address->{other_phone} || undef };
    return $data;
}

# fax { }
# This method returns a data structure containing the
# fax number of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/fax

sub fax {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'fax number(!) of the person',
		 data        => $address->{fax} || undef };
    return $data;
}


# web_page { }
# This method returns a data structure containing the
# web site of the person, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/web_page

sub web_page {
    my $self    = shift;
    my $web_address = $self->address_data->{web_page};
    my @urls =  grep { /HTTP:\/\//i } @$web_address if $web_address;

    my $data = { description => 'web address of the person',
		 data        => @urls ? \@urls : undef };
    return $data;
}

# previous_addresses { }
# This method returns a data structure containing the
# previous addresses of the person, if known, with keys
# of street address, country, institution, email, and date_modified.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/previous_addresses

sub previous_addresses {
    my $self      = shift;
    my $addresses = $self->previous_address_data;
    return { data        => $addresses || undef,
	     description => 'previous addresses of the person'};
}




#######################################
#
# The Laboratory Widget
#
#######################################

# laboratory { }
# Supplied by Role

# previous_laboratories { }
# This method returns a data structure containing
# previous laboratories of the person, as well as
# the current representative of that lab.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/previous_laboratories

sub previous_laboratories {
    my $self   = shift;
    my $object = $self->object;

    my @labs  = eval{$object->Old_laboratory};
    my @data;
    foreach (@labs) {
	my $representative = $_->Representative;
	my $rep = $self->_pack_obj($representative);
	push @data,[ $self->_pack_obj($_),$rep ];
    }

    my $data = { description => 'previous laboratory affiliations',
		 data        => (@data > 0) ? \@data : undef};
    return $data;
}


# strain_designation { }
# This method returns a data structure containing
# the strain designation of the current lab affiliation
# of the person.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/strain_designation

sub strain_designation {
    my $self   = shift;
    my $object = $self->object;

    my @labs   = eval{ $object->Laboratory };
    my @table  = (); # passed to data, table = array of hashes


    foreach my $i (0..$#labs){
		push( @table, {
			lab 	=> $self->_pack_obj($labs[$i], $labs[$i]->Mail),
			strain 	=> $self->_pack_obj($labs[$i])
		});
    }

    my $data = { description => 'strain designation of the affiliated lab',
		 data        => (scalar @table) ? \@table : undef };
    return $data;
}

# lab_info { }
# This method returns a data structure containing
# the allele and strain designations, and lab representative
# of each lab affiliation of the person.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/allele_designation

sub lab_info {
    my $self   = shift;
    my $object = $self->object;
    my @labs   = eval{$object->Laboratory};
    my @table  = (); # passed to data, table = array of hashes

	foreach my $lab (@labs){
		push( @table, {
			lab 	=> $self->_pack_obj($lab),
			strain 	=> $self->_pack_obj($lab),
			allele 	=> $lab->Allele_designation && $lab->Allele_designation->asString,
			rep		=> $self->_pack_obj($lab->Representative)
		});
	}

    my $data = { description => 'allele designation of the affiliated laboratory',
		 data        => (scalar @table) ? \@table : undef };
    return $data;

}

# eg: gene_classes
# This method returns a data structure containing
# gene classes assigned to the current lab affiliation
# of the person.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/gene_classes

sub gene_classes {
    my $self   = shift;
    my $object = $self->object;
    my @labs    = eval { $object->Laboratory };
    my @table  = (); # passed to data, table = array of hashes

 	foreach my $lab (@labs){
		push( @table, map {{
			lab 		=> $self->_pack_obj($lab),
			gene_class	=> $self->_pack_obj($_),
			desc		=> sprintf("%s",$_->Description)
		}} $lab->Gene_classes );
 	}

    my $data = {
		description => 'gene classes assigned to laboratory',
		data        => (scalar @table) ? \@table : undef
	};
    return $data;
}





#######################################
#
# The Tracking widget
#
#######################################

# possibly_publishes_as { }
# This method returns a data structure containing
# other names that the person might possibly publishh under.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/possibly_publishes_as

sub possibly_publishes_as {
    my $self   = shift;
    my $object = $self->object;

    my @names = map { "$_" } $object->Possibly_publishes_as;
    my $data = { description => 'other names that the person might publish under',
		 data        => @names? \@names : undef };
    return $data;
}


# status { }
# Supplied by Role

# last_verified { }
# This method returns a data structure containing
# the date the information about this person was
# last verified.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/last_verified

sub last_verified {
    my $self      = shift;
    my $object    = $self->object;
    my $timestamp = eval{$object->Last_verified};
    my @date = split /\ /, $timestamp;
    my $date = join " ", @date[0 .. 2];
    my $data = { data        => $date ? "$date" : undef,
		 description => 'date curated information last verified',
    };
    return $data;
}



#######################################
#
# The Lineage Widget
#
#######################################

# supervised { }
# This method will return a data structure of people supervised
# by the query person.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/supervised

sub supervised {
    my $self = shift;
    my $lineage = $self->_get_lineage_data('Supervised');
    my $data    = { description => 'people supervised by this person',
		    data        => $lineage };
    return $data;
}

# supervised_by { }
# This method will return a data structure containing
# people that this person has been supervised by.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/supervised_by

sub supervised_by {
    my $self    = shift;
    my $lineage = $self->_get_lineage_data('Supervised_by');
    my $data    = { description => 'people who supervised this person',
		    data        => $lineage };
    return $data;
}

# worked_with { }
# This method will return a data structure containing
# people that this person has worked or collaborated with.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/person/WBPerson242/worked_with

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
# # Probably don't need to be packed, just displayed as strings
sub aka {
   my $self = shift;
   my $object = $self->object;
   my @aka = map { "$_" } grep { "$_" ne $self->name->{data}{label} } $object->Also_known_as;
   my $data = { description => 'known aliases',
		        data        => @aka ? \@aka : undef };
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

    my @relationship = eval{$object->$tag};

    my @data;
    foreach my $relation (@relationship) {
        my $name = $relation->Standard_name;

        my @levels;
        my @duration;
        foreach ($relation->col){
            my ($level, $start, $end) = $_->row;
            push @levels, "$_";
            push @duration, $self->_format_duration($start, $end);
        }

        push @data, {
            'name'       => $self->_pack_obj($relation, $name && "$name"),
            'level'      => @levels ? \@levels : undef,
            'duration'   => @duration ? \@duration : undef
        };
    }
    return @data ? \@data : undef;
}

sub _format_duration {
    my ($self, $start, $end) = @_;
	my @end_date;

	if ($end && !($end =~ m/present/i)) {
	    @end_date = split /\ /,$end;
	}

	my @start_date = split /\ /,$start if $start;

	my $duration = ($start_date[2] || "") .  " - " . ($end_date[2] || "");
    return $duration;
}


__PACKAGE__->meta->make_immutable;

1;
