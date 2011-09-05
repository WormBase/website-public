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

# Here's the dynamic way of doing this, usingwidgets maintained in the DB.

#sub userguide :Path('/userguide') :Args(0)   {
#    my ($self,$c) = @_;
#    $c->stash->{section} = 'resources';
#    $c->stash->{template} = 'userguide/report.tt2';
#    my $page = $c->model('Schema::Page')->find({url=>"/about"});
#    my @widgets = $page->static_widgets if $page;
#    $c->stash->{static_widgets} = \@widgets if (@widgets);
#}


#sub userguide : Chained('/') PathPart('userguide') CaptureArgs(0) {
sub userguide : Chained('/') Path('/userguide') :Args(0) {
    my ($self,$c,$args) = @_;
    $c->stash->{section}  = 'resource';
    $c->stash->{category} = 'index';
    $c->stash->{template} = 'userguide/index.tt2';   # Overridden by chained actions
}

# /userguide/developers|users|educators
sub category_index : Chained('/') PathPart('userguide') :Args(1)   {
    my ($self,$c,$category) = @_;
    $c->stash->{category} = $category;
    $c->stash->{template} = "userguide/$category/index.tt2";
}

# At the expense of maintainability, we could 
# do this all in one fell swoop like this, too.
#sub subcategories : Chained('/') PathPart('userguide') :Args   {
#    my ($self,$c,@args) = @_;
#
#    $c->stash->{section} = 'userguide';
#        
#    my ($category,$subcategory,$page) = @args;
#
#    # Get a list of available classes.
#    if ($subcategory eq 'api') {  # /userguide/developers/api
#	my $dir = "$ENV{APP_ROOT}/$ENV{APP}/lib/WormBase/API/Object";
#	opendir(DIR,$dir) or $c->log->debug("Couldn't open $dir");
#	my @classes = grep { !/^\./ && !/\.orig/ && !/^\#/ && !/~$/} readdir(DIR);
#    	$c->stash->{classes}  = \@classes;
#    }
#
#    $c->stash->{template} = 'userguide/' . join('/',@args) . '/index.tt2';
#}




##############################################################
#
#   For Users
# 
##############################################################



##############################################################
#
#   For Educators
# 
##############################################################




##############################################################
#
#   Developer resources
# 
##############################################################


# The index of the API. Just lists classes.
#sub api_index :Path('/userguide/developers/api') : Args(0) {
# /userguide/developers/api|query_languagues|webdev
sub developer_docs : Chained('userguide') Path('developers') Args(1)   {
    my ($self,$c,$subcategory) = @_;

    $c->stash->{category}    = 'developers';
    $c->stash->{subcategory} = $subcategory;
    
    # Get a list of available classes.
    # The API index includes a list of available classes.
    if ($subcategory eq 'api') {
	my $dir = "$ENV{APP_ROOT}/$ENV{APP}/lib/WormBase/API/Object";
	opendir(DIR,$dir) or $c->log->debug("Couldn't open $dir");
	my @classes = grep { !/^\./ && !/\.orig/ && !/^\#/ && !/~$/} readdir(DIR);
	
	$c->stash->{classes}  = \@classes;
    }

    $c->stash->{class}    = $subcategory;
    $c->stash->{template} = "userguide/developers/$subcategory/index.tt2";
}


# API for a given class
# /userguide/developer/api
sub api_class_docs : Chained('developer_docs') Path('api') Args(1) {
#sub api_class : Chained('api_index') Path('/userguide/developers/api') : Args(1) {
    my($self,$c,$class) = @_;
    
    $class = ucfirst($class);
    open (LIB,"$ENV{APP_ROOT}/$ENV{APP}/lib/WormBase/API/Object/$class.pm") || $c->log->debug("Couldn't open the current library file");
    
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
    $c->stash->{template} = 'userguide/developers/api/class_documentation.tt2';
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
    return \%pod;
}



1;
