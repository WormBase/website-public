package WormBase::API::Role::Object;

use Moose::Role;
use File::Path 'mkpath';

# I should have an abstract method for id():
# provided with a class and a name, return the internal ID, if different.

# TODO:
# Reconcile all the various versions of genomic_environs and genomic_picture
# Test interpolated_genetic_position
# Add in support for genomic position
# Synonym (other_name?)
# common name: Short_name || common_name || Public_name
# Database and DB_Info parsing
# Phenotypes observed/not_observed

has 'MAX_DISPLAY_NUM' => (
      is => 'ro',
      default => 10,
    );

has 'object' => (
    is  => 'rw',
    isa => 'Ace::Object',
    );

has 'dsn' => (
    is  => 'ro',
    isa => 'HashRef',
    required => 1,
    );

has 'log' => (
    is => 'ro',
    );

has 'tmp_base' => (
    is => 'ro',
    );
 
has 'pre_compile' => (
    is => 'ro',
    );

#######################################################
#
# Generic methods
#
#######################################################


################
#  Names
################

=head3 name

This method will return a data structure of the 
name and ID of the requested object.

=over

=item PERL API

 $data = $model->name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/name

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Template: [% name %]

has 'name'     => (
    is         => 'ro',
    default    => sub {
        my $self   = shift;
        my $object = $self->object;
        my $class  = $object->class;
        my $tag    = $self->_common_name_tag($object->class);

        my $label  = $tag ? $object->$tag : $object->name;

        return {
            description => "The name and WormBase internal ID of a $class object",
            data        =>  $self->_pack_obj($object,$label),
        };
    }
);



=head3 common_name

This method will return a data structure containing
the common (public) name of the object. Almost totally
redundant with name().

=over

=item PERL API

 $data = $model->common_name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and an object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/common_name

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% common_name %]

has 'common_name' => (
    is   => 'ro',
    lazy_build => 1,
    );

sub _build_common_name {
    my $self   = shift;
    my $object = $self->object;
    my $tag    = $self->_common_name_tag($object->class);
    
    my $label  = $tag ? $object->$tag : $object->name;
    return { description => 'the common name of the object which may be the object name',
	     data        => $self->_pack_obj($object,$label),
    };
}


=head3 other_names

This method will return a data structure containing
other names that have been used to refer to the object.

=over

=item PERL API

 $data = $model->other_names();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and an object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/other_names

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% other_names %]

has 'other_names' => (
    is         => 'ro',
    lazy_build => 1,
    );


sub _build_other_names {
    my $self = shift;
    my $object = $self->object;
    my @names = $object->Other_name;
    
    # We will just stringify other names; no sense in linking them.
    @names = map { "$_" } @names;
    return { description => "other names that have been used to refer to $object",
	     data        => @names ? \@names : undef };
}

=head3 description
    
This method will return a data structure containing
a brief description of the object.
    
=over

=item PERL API
    
  $data = $model->description();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/description

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Template: [% description %]

has 'description'  => (
    is         => 'ro',
    lazy_build => 1,
    );

sub _build_description { 
    my $self    = shift;
    my $object  = $self->object;
    my $class   = $object->class;
    my $tag;
    if ($class eq 'Sequence') {
	$tag = 'Title';
    } else {
	$tag = 'Description';
    }
    my $description = $object->$tag;
    return { description  => "description of the $class $object",
	     data         => "$description" || undef,
    };
	     
#    my $data = { description => "description of the $class $object",
#		 data        => { description => $description ,
#				  evidence    => { check=>$self->check_empty($description),
#						   tag=>"Description",
#				  },
#		 }
#    };
#   return $data;

}




=head3 expression_patterns

This method will return a data structure containing
a list of expresion patterns associated with the object.

=over

=item PERL API

 $data = $model->expression_patterns();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/expression_patterns

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% expression_patterns %]

has 'expression_patterns'  => (
    is         => 'ro',
    lazy_build => 1,
    );

sub _build_expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my $class  = $object->class;
    my @data;
    
    foreach ($object->Expr_pattern) {	
	my $author  = $_->Author || '';
	my @patterns = $_->Pattern || $_->Subcellular_localization || $_->Remark;
	push @data, {
	    expression_pattern => $self->_pack_obj($_),
	    description        => @patterns ? join("<br />",@patterns) : undef,
	    author             => "$author"  || undef,
	};
    }
    return { description => "expression patterns associated with the $class:$object",
	     data        => @data ? \@data : undef };
}



=head3 genetic_position

This method returns a data structure containing
the genetic position of the requested object, if known.

=over

=item PERL API

 $data = $model->genetic_position();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/genetic_position

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% genetic_position %]

has 'genetic_position' => (
    is    => 'ro',
    lazy_build => 1
    );


sub _build_genetic_position {
  my ($self) = @_;
  my $object = $self->object;
  my $class  = $object->class;
  my ($chromosome,$position,$error,$method);

  # CDSs and Sequence are only interpolated
  if ($class eq 'CDS' || $class eq 'Sequence') {
      if ($object->Interpolated_map_position) {
	  ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
	  $method = 'interpolated';
      } else {
	  # Try fetching from the gene
	  if (my $gene = $object->Gene) {
	      $chromosome = $gene->get(Map=>1);
	      $position   = $gene->get(Map=>3);
	      $method = 'interpolated';
	  }
      }
  } else {
      ($chromosome,undef,$position,undef,$error) = eval{$object->Map(1)->row};
      $method = 'experimentally determined' if $chromosome;
  }

  # Nothing yet? Trying fetching interpolated position.
  unless ($chromosome) {
      if ($object->Interpolated_map_position) {
	  ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
	  $method = 'interpolated';
      }
  }

  my $label;
  if ($position) {
      $label= sprintf("$chromosome:%2.2f +/- %2.3f cM",$position,$error || 0);      
  } else {
      $label = $chromosome;
  }
  
  return { description => "the genetic position of the $class:$object",
	   data        => { chromosome => "$chromosome",
			    position    => "$position",
			    error       => "$error",
			    formatted   => "$label",
			    method      => "$method",
	   },
  };
}


######## NOT IN USE AND LIKELY NO LONGER NEEDED


=head3 genetic_position_interpolated

This method returns a data structure containing
the genetic position of the requested object, if known.

=over

=item PERL API

 $data = $model->genetic_position_interpolated();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/genetic_position_interpolated

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% interpolated_genetic_position %]

has 'genetic_position_interpolated' => (
    is => 'ro',
    lazy_build => 1
    );


sub _build_genetic_position_interpolated {
  my ($self) = @_;
  my $object = $self->object;
  my ($chrom,$pos,$error);
  for my $cds ($object->Corresponding_CDS) {
    ($chrom,$pos,$error) = $self->_get_interpolated_position($cds);
    last if $chrom;
  }
  return { description => 'the interpolated genetic position of the object',
	   data        => { chromosome         => "$chrom",
			    position            => "$pos",
			    formatted_position => sprintf("%s:%2.2f",$chrom,$pos)
	   },
  }
}

# get the interpolated position of a sequence on the genetic map
# returns ($chromosome, $position,$error)
# position is in genetic map coordinates
# This MIGHT also be the actual experimental position
sub _get_interpolated_position {
  my ($self,$object) = @_;
  $object ||= $self->object;
  if ($object){
    if ($object->class eq 'CDS') {
      # Is it a query
      # wquery/genelist.def:Tag Locus_genomic_seq
      # wquery/new_wormpep.def:Tag Locus_genomic_seq
      # wquery/wormpep.table.def:Tag Locus_genomic_seq
      # wquery/wormpepCE_DNA_Locus_OtherName.def:Tag Locus_genomic_seq
      
      # Fetch the interpolated map position if it exists...
      # if (my $m = $object->get('Interpolated_map_position')) {
      if (my $m = eval {$object->get('Interpolated_map_position') }) {
	#my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
	my ($chromosome,$position) = $m->right->row;
	return ($chromosome,$position) if $chromosome;
      } elsif (my $l = $object->Gene) {
	return $self->_get_interpolated_position($l);
      }
    } elsif ($object->class eq 'Sequence') {
      #my ($chromosome,$position,$error) = $obj->Interpolated_map_position(1)->row;
      my $chromosome = $object->get(Interpolated_map_position=>1);
      my $position   = $object->get(Interpolated_map_position=>2);
      return ($chromosome,$position) if $chromosome;
    } else {
      my $chromosome = $object->get(Map=>1);
      my $position   = $object->get(Map=>3);
      return ($chromosome,$position) if $chromosome;
      if (my $m = $object->get('Interpolated_map_position')) {	     
	my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row unless $position;
	($chromosome,$position) = $m->right->row unless $position;
	return ($chromosome,$position,$error) if $chromosome;
      }
    }
  }
  return;
}


=head3 laboratory

This method returns a data structure containing
the lab affiliation or origin of the requested object,
as well as the current lab representative.

=over

=item PERL API

 $data = $model->laboratory();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/laboratory

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% laboratory %]

has 'laboratory' => (
    is           => 'ro',
    lazy_build   => 1,
    );

# laboratory: Whenever a cross-ref to lab is needed.
# Returns the lab as well as the current representative.
# Used in: Person, Gene_class, Transgene
# template: shared/fields/laboratory.tt2
sub _build_laboratory {
    my $self   = shift;
    my $object = $self->object;
    my $class  = $object->class;

    # Ugh. Model inconsistencies.
    my $tag;
    if ($class eq 'Gene_class') {
	$tag = 'Designating_laboratory';
    } elsif ($class eq 'Pcr_olig' || $class eq 'Sequence') {
	$tag = 'From_laboratory';
    } elsif ($class eq 'Transgene' || $class eq 'Strain' || $class eq 'Antibody') {
	$tag = 'Location';
    } else {
	$tag = 'Laboratory';
    }
    my $lab = $object->$tag;
    my %data;
    $data{laboratory} = $self->_pack_obj($lab);
    if ($lab) {
	my $representative = $lab->Representative;
	my $name = $representative->Standard_name; 
	my $rep = $self->_pack_obj($representative,$name);
	$data{representative} = $rep if $rep;
    }
    
    my $data = { description => "the laboratory where the $class was isolated, created, or named",
		 data        => \%data };
    return $data;		     
}

=head3 method

This method will return a data structure containing
the method used to describe or determine the object.

=over

=item PERL API

 $data = $model->method();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/method

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Template: [% method %]

has 'method'   => (
    is         => 'ro',
    lazy_build => 1,
    );

# The method used to describe the object
sub _build_method {
    my $self = shift;
    my $object = $self->object;
    my $class  = $object->class;
    
    my $method = $self->Method;
    return {
	description => "the method used to describe the $class",
	data        => $method ? "$method" : undef,
    };
}

=head3 remarks

This method will return a data structure containing
curator remarks about the requested object.

=over

=item PERL API

 $data = $model->remarks();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/remarks

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Template: [% remarks %]

has 'remarks'  => (
    is         => 'ro',
    lazy_build => 1,
    );


sub _build_remarks {
    my $self    = shift;
    my $object  = $self->object;
#    my @remarks = grep defined, map { $object->$_ } qw/Remark/;
    my @remarks = $object->Remark;
    my $class = $object->class;

    # Need to add in evidence handling.
    my @evidence = map { $_->col } @remarks;

    # TODO: handling of Evidence nodes
    return {
        description  => "curatorial remarks for the $class",
        data         => @remarks ? \@remarks : undef,
    };
}


=head3 summary

This method will return a data structure containing
a brief summary of the requested object.

=over

=item PERL API

 $data = $model->summary();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/summary

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

# Template: [% summary %]

has 'summary'  => (
    is         => 'ro',
    lazy_build => 1,
    );

sub _build_summary {
    my $self   = shift;
    my $object = $self->object;
    my $class  = $object->class;
    my $summary = $object->Summary;
    return { description => "a brief summary of the $class:$object",
	     data        => "$summary" || undef };
}



=head3 status

This method will return a data structure containing
the current status of the object.

=over

=item PERL API

 $data = $model->status();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/status

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Template: [% status %]

has 'status'   => (
    is         => 'ro',
    lazy_build => 1,
    );


sub _build_status {
    my $self    = shift;
    my $object  = $self->object;
    my $status  = $object->Status;
    my $class   = $object->class;
    my $data    = { description  => "current status of the $class:$object",
		    data         => "$status",
    };
    return $data;
}

=head3 taxonomy

This method will return a data structure containing
the genus and species of the requested object.

=over

=item PERL API

 $data = $model->taxonomy();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/taxonomy

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Template: [% taxonomy %]

has 'taxonomy' => (
    is         => 'ro',
    lazy_build => 1,
    );

# Parse out species "from a Genus species" string.
sub _build_taxonomy {
    my ($self,$genus_species) = @_;

    # We may have already been passed a string to parse
    unless ($genus_species) {
	my $object = $self->object;
	$genus_species = $object->Species;
    }
    my ($genus,$species) = $genus_species =~ /(.*) (.*)/;
    my $data = { description => 'the genus and species of the current object',
		 data        => { genus   => $genus,
				  species => $species,
		 }
    };
    return $data;
}











# Get the tag which stores the best common name of the object
# Model varieagation.
sub _common_name_tag {
    my ($self,$class) = @_;
    if ($class eq 'Person') {
	return 'Standard_name';
    } elsif ($class eq 'Gene') {
	return 'Public_name';
    }
}




sub mysql_dsn {
    my $self    = shift;
    my $source = shift;
    return $self->dsn->{"mysql_".$source}; 
}

sub gff_dsn {
    my $self    = shift;
    my $species = shift || $self->parsed_species ;
    $self->log->debug("geting gff database species $species");
    return $self->dsn->{"gff_".$species} || $self->dsn->{"gff_c_elegans"} ; 
}

sub ace_dsn{
    my $self    = shift;
    return $self->dsn->{"acedb"}; 
}
# Set up our temporary directory (typically outside of our application)
sub tmp_dir {
    my $self     = shift;
    my @sub_dirs = @_;
    my $path = File::Spec->catfile($self->tmp_base,@sub_dirs);

    mkpath($path,0,0777) unless -d $path;    
    return $path;
};

sub tmp_image_dir {
    my $self  = shift;

    # 2010.08.18: hostname no longer required in URI; tmp images stored in NFS mount
    # Include the hostname for images. Necessary for proxying and apache configuration.
#    my $host = `hostname`;
#    chomp $host;
#    $host ||= 'local';
#    my $path = $self->tmp_dir('media/images',$host,@_);

    my $path = $self->tmp_dir('media/images',@_);
    return $path;
}

# Create a URI to a temporary image.
# Routing will be handled by Static::Simple in development
# and apache in production.
sub tmp_image_uri {
    my ($self,$path_and_file) = @_;
    
#    # append the hostname so that I can correctly direct traffic through the proxy
#    my $host = `hostname`;
#    chomp $host;
#    $host ||= 'local';
    
    my $tmp_base = $self->tmp_base;
    
    # Purge the temp base from the path_and_file    
    # pre-NFS: eg /tmp/wormbase/images/wb-web1/00/00/00/filename.jpg -> images/wb-web1/00/00/00/filename.jpg
    # eg /tmp/wormbase/images/00/00/00/filename.jpg -> images/00/00/00/filename.jpg
    $path_and_file =~ s/$tmp_base//;
    
    # URI (pre-NFS): /images/wb-web1/00/00/00...
    # URI: /images/00/00/00...
    my $uri = '/' . $path_and_file;
    return $uri;    
}

sub tmp_acedata_dir {
    my $self  = shift;
    return $self->tmp_dir('acedata',@_);
}

sub _pack_objects {
    my ($self, $objects) = @_;
    return { map { $_ => $self->_pack_obj($_) } @$objects };
}

sub _pack_obj {
    my ($self, $object, $label, %args) = @_;
    return unless defined $object;
    $label =  eval {$object->Public_name} || "$object" unless $label;
    return {
        id => "$object",
        label => "$label",
        class => $object->class,
        %args,
    };
}

sub parsed_species {
  my ($self,$object) = @_;
  $object ||= $self->object;
  my $genus_species = eval {$object->Species} or return 'c_elegans';
  my ($species) = $genus_species =~ /.* (.*)/;
  return lc(substr($genus_species,0,1)) . "_$species";
}

sub bestname {
  my ($self,$gene) = @_;
  return unless $gene && $gene->class eq 'Gene';
  my $name = $gene->Public_name ||
      $gene->CGC_name || $gene->Molecular_name || eval { $gene->Corresponding_CDS->Corresponding_protein } || $gene;
  return $name;
}

# Description: checks data returned by extenral model for standards
#              compliance and fixes the data if necessary and possible
#              WARNING: modifies data directly if passed data is reference
# Usage: if (my ($fixed, @problems) = $self->check_data($data)) { ... }
# Returns: () if all is well, otherwise array with fixed data and
#          description(s) of compliance problem(s).
sub check_data {
	my ($self, $data) = @_;
	my @compliance_problems;

	if (ref($data) ne 'HASH') { # no data pack
		$data = {
			description => 'No description available',
			data => $data,
		};
		push @compliance_problems,
		     'Did not return in hashref datapack with description and data entry.';
	}

	if (!$data->{description}) { # no description
		$data->{description} = 'No description available';
		push @compliance_problems, 'No description entry in datapack.';
	}

	if (! exists $data->{data}) { # no data entry
		$data->{data} = undef;
		push @compliance_problems, 'No data entry in datapack.';
	}
	elsif (my ($tmp, @problems) = $self->_check_data_content($data->{data})) {
		$data->{data} = $tmp;
		push @compliance_problems, @problems;
	}

	return @compliance_problems ? ($data, @compliance_problems) : ();
}

# Description: helper to recursively checks the content of data for standards
#              compliance and fixes the data if necessary and possible
# Usage: FOR INTERNAL USE.
#        if(my ($tmp) = $self->_check_data_content($datum)) { ... }
# Returns: if all is well, (). otherwise, 2-array with fixed data and
#          description(s) of compliance problem(s).
sub _check_data_content {
	my ($self, $data, @keys) = @_;
	my $ref = ref($data) || return ();

	my @compliance_problems;
	my ($tmp, @problems);

	if ($ref eq 'ARRAY') {
		foreach (@$data) {
			if (($tmp, @problems) = $self->_check_data_content($_, @keys)) {
				$_ = $tmp;
				push @compliance_problems, @problems;
			}
		}
		unless (@$data) {
			push @compliance_problems,
			     join('->', @keys) . ': Empty arrayref returned; should be undef.';
		}
	}
	elsif ($ref eq 'HASH') {
		foreach my $key (keys %$data) {
			if (($tmp, @problems) = $self->_check_data_content($data->{$key},
															   @keys, $key)) {
				$data->{$key} = $tmp;
				push @compliance_problems, @problems;
			}
		}
		unless (%$data) {
			push @compliance_problems,
			     join('->', @keys) . ': Empty hashref returned; should be undef.'
		}
	}
	elsif ($ref eq 'SCALAR' || $ref eq 'REF') {
		# make sure scalar ref doesn't refer to something bad
		if (($tmp, @problems) = $self->_check_data_content($$data, @keys)) {
			$data = $tmp;
			push @compliance_problems, @problems;
		}
		else {
			$data = $$data; # doesn't refer to anything bad -- just dereference it.
			push @compliance_problems,
			     join('->', @keys) . ': Scalar reference returned; should be scalar.';
		}

	}
	elsif (eval {$data->isa('Ace::Object')}) {
		push @compliance_problems, join('->', @keys) .
		     ": Ace::Object (class: " . $data->class . ", name: $data) returned.";
		$data = $data->name; # or perhaps they wanted a _pack_obj... we'll never know
	}
	else { # don't know what the data is, but try to stringify it...
		push @compliance_problems, join('->', @keys) .
             ": Object (class: " . ref($data) . ", value: $data) returned.";
		$data = "$data";
	}

	return @compliance_problems ? ($data, @compliance_problems) : ();
}

#generic method for getting genomic pictures
#it requires the object calling this method having a segments attribute which is an array ref storing the gff sequences
#it also requires the object having a type attribute which is also an array ref storing the tracks to display
sub genomic_picture {
    my ($self,$ref,$start,$stop);
    my $position;
    if (@_ == 4) {
      $self = shift;
      $position = $self->hunter_url(@_);
    }

    # or with a sequence object
    else {
      $self = shift ;
      my $segment = $self->pic_segment or return;
      $position = $self->hunter_url($segment);
    }

    return unless $position;
    my $species = $self->parsed_species;
    my $type = @{$self->tracks} ? join(";", map { "t=".$_ } @{$self->tracks}) : ""; 
    $self->log->debug("tracks:" ,$type);
    my $gbrowse_img = "$species/?name=$position;$type";
    my $id = "$species/?name=$position";
    my $data = { description => 'The Inline Image of the sequence',
		 data        => {  class => 'genomic_location',
				   label => $gbrowse_img,
				   id	=> $id,
				},
    };  
    return $data;    
}

sub hunter_url {
  my ($self,$ref,$start,$stop);
  my $flag= 1;
  # can call with three args (ref,start,stop)
  if (@_ == 4) {
    ($self,$ref,$start,$stop) = @_;
      $flag=0;
  }

  # or with a sequence object
  else {
    my ($self,$seq_obj) = @_ or return;
    $seq_obj->absolute(1); 
    $start      = $seq_obj->abs_start;
    $stop       = $seq_obj->abs_stop;
    $ref        = $seq_obj->abs_ref;
  }

  $ref =~ s/^CHROMOSOME_//;
  if(defined $start) {
      my $length = abs($stop - $start)+1;
      $start = int($start - 0.05*$length) if $length < 500;
      $stop  = int($stop  + 0.05*$length) if $length < 500;
      ($start,$stop) = ($stop,$start) if ($flag && $start > $stop);
      $ref .= ":$start..$stop";
  }
  return $ref;
}








############################################################
#
# Generic Object methods
#
############################################################





1;
