package WormBase::Web::Controller::About;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
#use FindBin qw/$Bin/;

#__PACKAGE__->config->{libroot} = "$Bin/../../lib/WormBase/API";

##############################################################
#
#   Simple abut pages.
#
##############################################################

sub about :Path('/about') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{section} = 'resources';
    $c->stash->{template} = 'about/report.tt2';
    $self->_setup_page($c);
}

# Allow anything under /about to have an arbitrary number of path parts.
# Helpful for organizing things like documentation.
sub about_documentation :Path('/about') :Args   {
    my ($self,$c,@path_parts) = @_;
    $self->_setup_page($c);
    $c->stash->{section} = $self->_get_section(@path_parts);
    $c->stash->{path_parts} = \@path_parts;
    $c->stash->{template} = 'about/report.tt2';
}

sub _get_section {
    my ($self, @path_parts) = @_;
    my $section;
    my $submit_data_path = 'userguide/submit_data';
    if (join('/', @path_parts) =~ /\Q$submit_data_path\E/){
        $section = 'submit_data';
    }else{
        $section = 'resources';
    }
    return $section;
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
    print TMP @code;
    close TMP;

    # Now turn it into POD...
    my ($title) = ucfirst($class);
    my $html = `/usr/bin/pod2html --title='WormBase API: $title' /var/tmp/pod.tmp`;
    $c->stash->{pod}      = $html;
}


# Parse code snippets from Role/Object.pm
sub _get_superclass_pod {
    my ($self,$c) = @_;

    open (LIB2,"$ENV{APP_ROOT}/$ENV{APP}/lib/WormBase/API/Role/Object.pm")
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
