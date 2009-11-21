package WormBase::Web::View::Template::Plugin::URL;

use strict;
use CGI qw/:standard/;
use Template::Plugin;
#use lib '/usr/local/wormbase/cgi-perl/lib/WormBase/Util';

# Yikes! Why am I saving the context for every request?
sub load {
  my ($class,$context,@params) = @_;
  my $self = bless {
		    _CONTEXT => $context,
		    _PARAMS  => \@params,
		   },$class;
#  my $stash = $context->stash;
  return $self;
}

sub new {
  my ($self,$context) = @_;
  return $self;
}


#######################################################
# URL mapping
# This could entirely be a TT macro.
#######################################################

sub object_link {
  my ($self,$object,$text) = @_;
  my $inner_object = $object->object;
  my $href = $self->object_href($inner_object);
  
  # Customize the link text
  if ($inner_object->class eq 'Person') {
      $text = $inner_object->Full_name;
  } else {
      $text ||= $inner_object->name;
  }
  
  return a({-href=>$href},$text);
}

# Return the HREF for a given object
sub object_href {
    my ($self,$object) = @_;
    
    my $href = $self->class2url($object);
    return $href;
}




# Turn an object or item into a link
# TODO: This should also take into account special classes that need to be linked in a certain way.
# For example: We should always plan to link genes as Public_name (sequence_name)
# Linking should also accept an optional parameter, evidence.  This will control
# whether or not a bit of evidence exists for this item.
sub Link {
    my ($self,$hash,$text,$tooltip) = @_;
    return unless $hash;
    
    
    # Hash is actually a hash.
    # It is -- most likely -- a WB::API::Object
    # Turn this into a link using object_link
    if ((eval { $hash->class} && !defined $hash->{action})
	|| eval { $hash =~ /WormBase::API/ } ) {      
	return $self->object_link($hash,$text);
    }
    
    my $item = $hash->{item};
    $text ||= $hash->{text} || $hash->{item};
    my $href = $self->href($hash);
    
    if (defined $hash->{href_params}) {
	my %href_params = $hash->{href_params};
	return a({-href=>$href,-name=>$item,%href_params},
		 $text);
    } else {
	return a({-href=>$href,-name=>$item},$text);
    }
}

# Return an unlinked href for a given object, string, or
# or external resource
sub href {
  my ($self,$hash) = @_;
  my ($action,$item,$href);

  # A link to an external resource, characterized 
  # by a "resource" parameter.
  if ($hash->{resource}) {

    my $resource = $hash->{resource};
    my $type = $hash->{type};
    $type ||= 'base';  # The home page for this resource

    my $context = $self->{_CONTEXT};
    my $stash   = $context->stash;
    $href       = $stash->{site}->{external_urls}->{$resource}->{$type};
  } else {

    # Linking a string to an action, or an object to an
    # action different from its default.
    # Parse parameters
    if (eval { $hash->class }) {
      $item   = $hash;
      $action = $item->class;
    } else {
      $item   = $hash->{item};
      $action = $hash->{action} || eval { $item->class };
    }
  }

  # Fetch the base URL for object and string linking
  $href ||= $self->class2url($item,$action);

  # Allow users to pass a scalar or array
  if (defined $hash->{url_params}) {
    my @url_params = (ref $hash->{url_params} =~ /ARRAY/) ? @{$hash->url_params} : $hash->{url_params};

    # We've been passed url paramaters. sprintf to the rescue.
    my @params_clean = map { CGI::escape($_) } @url_params;
    return sprintf($href,@params_clean);
  } else {
    return $href;
  }
}



# THIS IS OUT OF DATE AND NEEDS TO BE FIXED
sub class2url {
    my ($self,$name,$class) = @_;
    $class ||= $name->class if ref($name) and $name->can('class');
    
    my $name_clean  = CGI::escape($name);
    my $class_clean   = CGI::escape($class);
    my $params = "class=$class_clean;name=$name_clean";
    
    my $context = $self->{_CONTEXT};  # ? Ace holdover?
    my $stash   = $context->stash;
    
    my $target_action = $stash->{site}->{class2action}->{lc($class)};
    my $action        = $target_action->{action};
    return $action unless $params;
    return ($action . '?' . $params) if $params;
}

1;
