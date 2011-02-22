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
# Usage: $obj->check_data($obj->$field)
# Returns: undef if all is well, otherwise fixed data (hashref)
sub check_data {
	my ($self, $data) = @_;
	my $is_non_compliant = 0;

	if (ref($data) ne 'HASH') { # no data pack
		$data = {
			description => 'No description available',
			data => $data,
		};
		$is_non_compliant ||= 1;
	}

	if (!$data->{description}) { # no description
		$data->{description} = 'No description available';
		$is_non_compliant ||= 1;
	}

	if (! exists $data->{data}) { # no data entry
		$data->{data} = undef;
		$is_non_compliant ||= 1;
	}
	else { # fix data type here
		my $ref = ref $data->{data};
		if ($ref && $ref ne 'ARRAY' && $ref ne 'HASH') {
			# data entry is not scalar, arrayref, or hashref...
			if ($ref eq 'SCALAR') {
				$data->{data} = ${$data->{data}}; # deref scalar ref
			}
			elsif (eval {$data->{data}->isa('Ace::Object')}) {
				$data->{data} = $data->{data}->name; # stringify Ace::Object
			}
			$is_non_compliant ||= 1;
		}
	}

	return $data if $is_non_compliant;
	return;
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
