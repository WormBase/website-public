package WormBase::API::Role::Object;

use Moose::Role;
use File::Path 'mkpath';

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
    my ($self,$objects) = @_;
    my %data;
    foreach (@$objects) {
      $data{"$_"} = $self->_pack_obj($_);
    }
    return \%data;
}

sub _pack_obj {
    my ($self,$object,$label,%args) = @_;
    return unless defined $object;
    $label =  eval {$object->Public_name} || "$object" unless $label;
    my %data = ( id => "$object",
              label => "$label",
              class => $object->class,
    );
    @data{ keys %args } = values %args if(%args);
    return \%data;
}

sub parsed_species {
  my ($self,$object) = @_;
  $object ||= $self->object;
  my $genus_species = $object->Species;
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
	warn "Inside _check_data_content";
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
	elsif ($ref eq 'SCALAR') {
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
             ": Object (class: " . $data->class . ", value: $data) returned.";
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

1;
