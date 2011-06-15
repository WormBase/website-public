package WormBase::Web::Controller::UserGuide;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use FindBin qw/$Bin/;


##############################################################
#
#   Docs
# 
##############################################################

__PACKAGE__->config->{libroot} = "$Bin/../../lib/WormBase/API";


#opendir (DIR,"$libroot/Object") || die "Couldn't open the lib dir for processing";

# Userguide could conceivably contain other things besides just documentation.
sub docs :Path('/userguide') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{template} = 'userguide/index.tt2';
}




# The index of the API
sub api :Path('/userguide/api') : Args(0) {
    my ($self,$c) = @_;
    
    # Get a list of available classes.
    my $dir = '/usr/local/wormbase/website/tharris/lib/WormBase/API/Object';
    opendir(DIR,$dir) or $c->log->debug("Couldn't open $dir");
    my @classes = grep { !/^\./ && !/\.orig/ && !/^\#/ && !/~$/} readdir(DIR);
    
    $c->stash->{classes}  = \@classes;
    $c->stash->{template} = 'userguide/api/index.tt2';
}


# API for a given class
sub api_class_documentation :Path('/userguide/api') : Args(1) {
    my($self,$c,$class) = @_;

    # Hardcoded
    $class = ucfirst($class);
    open (LIB,"/usr/local/wormbase/website/tharris/lib/WormBase/API/Object/$class.pm") || $c->log->debug("Couldn't open the current library file");
    
    my $pod = $self->_get_pod($c);
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
    
    # Delete the tmpfile
#    system("rm -f /var/tmp/pod.tmp");
    $c->stash->{class}    = ucfirst($class);
    $c->stash->{pod}      = $html;
    $c->stash->{template} = 'userguide/api/class_documentation.tt2';
}



# Parse code snippets from Role/Object.pm
sub _get_pod {
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
    $c->log->debug("here aI am with %pod");
    return \%pod;
}


1;
