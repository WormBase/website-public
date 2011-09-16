package WormBase::Web::Controller::UserGuide;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use FindBin qw/$Bin/;

__PACKAGE__->config->{libroot} = "$Bin/../../lib/WormBase/API";

##############################################################
#
#   The WormBase User Guide. Yay!
# 
##############################################################

# Supports any level of testing and dynamic/statics widgets.
sub userguide : Chained('/') PathPart('userguide') :Args   {
    my ($self,$c,@args) = @_;

    $c->stash->{section} = 'resources'; 
       
    my $path = join('/',@args);
    $c->log->warn("path is $path");
    $c->log->warn("args are " . join(",",@args));
    $c->stash->{template} = "userguide/$path/index.tt2";


    # Kludge for documentation on individual classes.
    # I don't want to have to create individual directories for
    # these on the filesystem.
    if ($path =~ m{api-rest/class/(.*)}) {
	$c->stash->{class} = $1;
	$c->stash->{template} = "userguide/developers/api-rest/class_documentation_index.tt2";
    }
}

# Called by the REST action when the widget loads.
sub _get_pod {
    my ($self,$c,$class) = @_;
    $class = ucfirst($class);
    open (LIB,"$ENV{APP_ROOT}/$ENV{APP}/lib/WormBase/API/Object/$class.pm") || $c->log->debug("Couldn't open the current library file");    

    my $pod = $self->_get_superclass_pod($c);
    my @code;
    while (<LIB>) {	
	if ($_ =~ /^\#\ \<\<\ include\ (.*)\ \>\>/) {
	    # Get the corresponding pod
	    push @code,"\n\n\n";
	    push @code,eval { @{$pod->{$1}} };
	    push @code,"\n\n";
	}
	push @code,$_;
    }
    close LIB;
    
    # Write code to temp file
    open (TMP,">/var/tmp/pod.tmp");
    print TMP join('',@code);
    close TMP;
    
    # Now turn it into POD...
    my ($title) = ucfirst($class);
    my $html = `/usr/bin/pod2html --title='WormBase API: $title' /var/tmp/pod.tmp`;
    $c->stash->{pod}      = $html;
}


# Parse code snippets from Role/Object.pm
sub _get_superclass_pod {
    my ($self,$c) = @_;

    open (LIB2,"/usr/local/wormbase/website/tharris/lib/WormBase/API/Role/Object.pm")
	or $c->log->debug("Couldn't open the Role file for fetching boilerplate POD");
    my %pod;
    my $in_stanza;
    while (<LIB2>) {
	if ($_ =~ /^=head3\s(.*)/) {
	    $in_stanza = 1;
	}
	push @{$pod{$1}},$_ if $in_stanza;
	
	if ($in_stanza && $_ =~ /^=cut/) {
	    $in_stanza = undef;
	}    
    }
    close LIB2;    
    return \%pod;
}



1;
