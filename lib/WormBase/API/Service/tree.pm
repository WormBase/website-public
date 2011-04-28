package WormBase::API::Service::tree;

use Moose;

with 'WormBase::API::Role::Object'; 

use Ace 1.51;
use CGI 2.42 qw/:standard :html3 escape/;
use CGI::Carp qw/fatalsToBrowser/;
#use Ace::Browser::AceSubs qw(:DEFAULT Style);
use Ace::Browser::TreeSubs;


use constant MAXEXPAND => 10;
use constant CLOSEDCOLOR => "#909090";
use constant OPENCOLOR   => "#FF0000";

use vars qw/$request_name $request_class $view $dsn @expand @squash/;

sub index {
    my ($self) = @_;
    my $data = {};
    return $data;
}

sub run {
    my ($self,$param) = @_;
    $request_name  = $param->{'name'};
    $request_class = $param->{'class'};
    $view       = $param->{'view'};
    @squash     = $param->{'squash'};
    @expand     = $param->{'expand'};

    # This is a kludge to handle our linking scheme.
    # Normally, we have /species/class/object
    # But for index pages we have
    #      /species/class
    # To rectify, I use "all" as a placeholder so
    # that class indexes and class reports work the same way.
    if ($request_name eq 'all') {
	$request_name  = '?' . ucfirst $request_class;
	$request_class = 'Model';
    }
    $request_name =~ s/^#/?/ if $request_class eq 'Model';
    
    $dsn  = $self->ace_dsn->dbh;
    my ($object) = $dsn->fetch(-class => $request_class,
			       -name  => $request_name,
			       -fill  => 1) if $request_class && $request_name;
    
    my ($tree,$msg);
    if ($object) {
	$tree = $self->generate_tree($param,$object);
	$msg    = "No additional information about $request_name available in the database" unless $tree;
    } else {
	$msg = "$request_class:$request_name could not be found in the database.";
    }


    return { object => { class => $request_class,
			 name  => $request_name,
	     },
	     view   => $view,
	     tree   => $tree,
	     msg    => $msg || undef,
    };
}

sub generate_tree {
    my ($self,$cgi,$obj) = @_;
    my @data;
    if ($obj) {
	my ($n,$c) = (CGI::escape($request_name),CGI::escape($obj->class));
	#local(%PAPERS) = ();
	my $myimage = ($request_class =~ /^Picture/ ? $obj->Pick_me_to_call->right->right : 'No_Image') ;
        @data =  $obj->asHTML(\&to_href);
    } 
    return \@data;
}


sub to_href {
    my $obj = shift;
    
    if ($obj->class eq 'txt') {
	return $obj =~ /\n/ ? pre(escapeHTML($obj)) : escapeHTML($obj);
    }

    if ($obj->class=~/dna|peptide/) {
	my $dna = "$obj";
	$dna=~s/(\w{50})/$1\n/g;
	return (pre({-class=>$obj->class},$dna),0);
    }
    
    if ($obj->class eq 'Text') {
	return escapeHTML($obj->name);
#	return GenBankLink(escapeHTML($obj->name));
    }
    
    unless ($obj->isObject or $obj->isTag) {
	$obj = escapeHTML($obj);
	$obj =~s/\\n/<BR>/g;
	return ($obj,0);
    }
    
    # if we get here, we're dealing with an object or tag
    my $name  = $obj->name;
    my $class = $obj->class;

    # Which tags/fields should we squash/expand?
    my %squash = map { $_ => 1; } grep(defined $_ && $_ ne '',@squash);
    my %expand = map { $_ => 1; } grep(defined $_ && $_ ne '',@expand);
    
    my %PAPERS;

    my ($n,$c) = (CGI::escape($name),CGI::escape($obj->class));
    my ($pn,$pc) = (CGI::escape($request_name),CGI::escape($request_class));
    my $cnt = $obj->col;
    

    # special case for papers -- display their titles rather than their IDs
    my ($title);
    if ($obj->class eq 'Paper' and $PAPERS{$name}) {
	$title = $PAPERS{$name}->Title->at if $PAPERS{$name}->Title;
    }
    
    # set up %PAPERS in one fell swoop
    if ($obj->isTag and $name=~/^(Paper|Reference|Quoted_in)$/ and (!$squash{$name} or $cnt <= MAXEXPAND)) {
	my @papers = $dsn->find(-query=>qq{$request_class IS "$request_name" ; >$name},
			       -fill=>1);
	foreach (@papers) {
	    $PAPERS{"$_"} = $_;
	}
    }
    
    # here's a hack case for external images
    if ($obj->isTag && $name eq 'Pick_me_to_call' && $obj->right(2)=~/\.(jpg|jpeg|gif)$/i) {
	return (td({-colspan=>2},img({-src=>AceImageHackURL($obj->right(2))})),1,1);
    }


    $title ||= $name;
    $view ||= '';
    if ($cnt > 1) {
	# Really, really big arbitrary expansion. Sloppy.
	my $MAXEXPAND = ($view eq 'expand') ? 100000 : MAXEXPAND;
	if ($view eq 'collapse' || !$obj->isObject && $squash{$name} || ($cnt > $MAXEXPAND && !$expand{$name})) {
	    my $to_squash = join('&squash=',map { CGI::escape($_) } grep $name ne $_,keys %squash);
	    my $to_expand = join('&expand=',map { CGI::escape($_) } (keys %expand,$name));
#	    return (a({-href=>url(-relative=>1,-path_info=>1) 
	    return (a({-href=>"/tools/tree/run" 
			   . "?name=$pn&class=$pc"
			   . ($to_squash ? ";squash=$to_squash" : '') 
			   . ($to_expand ? ";expand=$to_expand" : '')
			   . "#$name",
			   -name=>"$name",
			   -target=>"_self"},
		      b(font({-color=>CLOSEDCOLOR},"$title ($cnt)"))),
		    1);
	} elsif (!$obj->isObject) {
	    my $to_squash = join('&squash=',map { CGI::escape($_) } (keys %squash,$name));
	    my $to_expand = join('&expand=',map { CGI::escape($_) } grep $name ne $_,keys %expand);
	    return (a({-href=>"/tools/tree/run" 
#	    return (a({-href=>url(-relative=>1,-path_info=>1,-query=>1) 
			   . "?name=$pn&class=$pc"
			   . ($to_squash ? "&squash=$to_squash" : '') 
			   . ($to_expand ? "&expand=$to_expand" : '')
			   . "#$name",
			   -name=>"$name",
			   -target=>"_self"},
		      b(font({-color=>OPENCOLOR},"$title"))),
		    0);
	}
    }
    
    return i($title) if $obj->isComment;
    
    if ($obj->isObject) {
	return (a({-href=>url(-relative=>1,-path_info=>1) 
		       . "?name=$name;class=$class"},$title), 0);
    }
    
    if ($obj->isTag) {
	return ("<B>$title</B>",0);
    }
  # shouldn't ever get here.
}

 
sub error {
  return 0;
}

sub message {
  return 0;
}


1;
