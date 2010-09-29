package WormBase::API::Role::Object;

use Moose::Role;
use File::Path 'mkpath';

has 'MAX_DISPLAY_NUM' => (
      is => 'ro',
      default => 10,
    );

has 'object' => (
    is  => 'ro',
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


sub gff_dsn {
    my $self    = shift;
    my $species = shift || $self->parsed_species;
    return $self->dsn->{"gff_".$species}; 
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
    $label = "$object" unless $label;
     
    my %data = ( id => "$object",
              label => $label,
              class => $object->class,
    );
    @data{ keys %args } = values %args if(%args);
    return \%data;
}


sub bestname {
  my ($self,$gene) = @_;
  return unless $gene && $gene->class eq 'Gene';
  my $name = $gene->Public_name ||
      $gene->CGC_name || $gene->Molecular_name || eval { $gene->Corresponding_CDS->Corresponding_protein } || $gene;
  return $name;
}

1;
