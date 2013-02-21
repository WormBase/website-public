package WormBase::API::Service::epic;

use Moose;
with 'WormBase::API::Role::Object';

use strict;
use vars qw/$DB $request_name $request_class $request_tool $click $map_start $map_stop/;

use Ace 1.51;
use File::Path;
use CGI 2.42 qw/:standard escape Map Area Layer *p *TR *td *table/;
#use CGI::Carp;
#use Ace::Browser::AceSubs qw(:DEFAULT Style);
use Ace::Browser::GeneSubs 'NCBI';
#use ElegansSubs qw(:DEFAULT Bestname FetchGene);

# these constants should be moved into configuration file
use constant DISABLED => 0;
use constant WIDTH    => 1024;
use constant HEIGHT   =>  768;
use constant UP_ICON   => '/ico/a_up.gif';
use constant DOWN_ICON => '/ico/a_down.gif';
use constant ZOOMIN_ICON => '/ico/a_zoomin.gif';
use constant ZOOMOUT_ICON => '/ico/a_zoomout.gif';

use namespace::autoclean -except => 'meta';

has 'image_dir' => (
     is => 'ro',
    lazy => 1,
    default => sub {
	return shift->tmp_image_dir('epic');
    }
);


sub index {
    my ($self, $c, $param) = @_;
    my $data = {
	tool => $param->{'tool'},
    };
    return $data;
}

sub run {
    my ($self, $c, $param) = @_;
    $request_name = $param->{'name'};
    $request_class = $param->{'class'};
    $request_tool = $param->{'tool'};
    $click = $param->{'click'};
    $map_start = $param->{'map_start'};
    $map_stop  = $param->{'map_stop'};

    my ($objname, $objclass) = ($request_name, $request_class);

    my ($obj, $bestname, $img, $map, $panel, $msg);

    $DB  = $self->ace_dsn->dbh;

    if ($request_class =~ /gene/i) {
	my $api    = $c->model('WormBaseAPI');
	$request_name =~ s/-/_/g;	
	my $object = $api->xapian->_get_tag_info($c, $request_name, lc($request_class) ,1);
	$request_name = $object->{name}->{id};
    }

    if ($request_name && $request_class) { $obj = $DB->fetch(-class => $request_class, -name  => $request_name, -fill => 1) }

    if ($obj && $request_tool eq 'gmap') {
	if($request_class =~ /^gene|rearrangement$/i){
	    my ($tag) = $request_class =~ /gene/i ? $obj->Map_info : grep {"$_" eq 'Map'} $obj->tags;
	    my @row = $tag->row if $tag;
	    if($row[0] eq 'Map') {
		my $chromosome = $row[1] if @row;
		if($chromosome) {
		    my $type = $row[2];
		    if ("$type" eq 'Position'){
			my $position = $row[3] || 0;
			$map_start = $position - 0.3;
			$map_stop = $position + 0.3;
		    } elsif ("$type" eq 'Ends') {
			my ($left, $right) = $type->col;
			$map_start = $left->at . '' if $left;
			$map_stop = $right->at . '' if $right;
		    }
		    $request_class = 'Map';
		    $request_name = "$chromosome";
		    $obj = $obj->Map;
		}
	    } else {
		$msg = 1;
	    }
	} elsif ($request_class ne 'Map') {
	    $msg = 1; # should set off unless check for the call to display_object below
	}
    }

    if (lc($request_class) eq 'sequence' && $request_name =~ /SUPERLINK|CHROMOSOME/) {
	$msg = "This sequence is too large to display. Try a shorter segment.";
    } elsif ($obj) {
	($img, $map, $panel) = $self->display_object($param,$obj) unless $msg;
	my $msgtype = $request_tool eq 'epic' ? 'graphical' : 'genetic map';
	$msg = "No $msgtype information about $objname available in the database" unless $img;
    } else {
	$msg = "$objclass:$objname could not be found in the database. Please verify that the WormBase ID specified was correct.";
    }

    return { object => { class => $objclass,
			  name  => $objname, },
	      img   => $img,
	      img_map   => $map,
	      img_panel => $panel,
	      msg    => $msg || undef,
	      tool => $request_tool,
    };
}

sub display_object {
    my ($self, $param, $obj) = @_;
    my $has_coords = defined $map_start && defined $map_stop && $map_start =~ /^-?\d+(?:\.\d+)?$/ && $map_stop =~ /^-?\d+(?:\.\d+)?$/ && $map_start < $map_stop;

    my $panel = build_map_navigation_panel($obj,$param,$has_coords) if $request_class =~ /Map/i;

    my $safe_name = $request_name;
    $safe_name=~tr/[a-zA-Z0-9._\-]/_/c;
    my $db = $DB->title;
    $db=~s!^/!!;
    my $path = join('/',$db,$request_class);

    $safe_name .= "." . $click if $click;
    $safe_name .= ".start=$map_start,stop=$map_stop" if $has_coords;
    $safe_name .= ".gif";
    my $image_file = $self->image_dir . '/' . $safe_name;
    my $image_path = $self->tmp_image_uri($image_file);

    # get the parameters for the image generation
    my @clicks =  map { [ split('-',$_) ] } split(',',$click) if $click;

    my $debug;

    my @params = (-clicks=>\@clicks);
    if ($request_class =~ /Map/) {
	push(@params,(-dimensions=>[WIDTH,HEIGHT]));
	push(@params,(-coords=>[$map_start,$map_stop])) if $has_coords;
    }

    # warn "asGif($debug)\n";
    # Clones are being displayed using TREE even though PMAP is the default
    #  if ($obj && $obj->class eq 'Clone') {
    # push(@param,(-display=>'PMAP'));
    #  }
    my ($gif,$boxes) = $obj ? $obj->asGif(@params) : ();
    $gif =~ s/^\0//;

    my ($img, $map);
    if($gif){
	unless (-e $image_file && -M $image_file < 0) {
	    local(*F);
	    open (F,">$image_file") || error("Can't open image file $image_file for writing: $!\n");
	    print F $gif;
	    close F;
	}
	my $u = "/tools/$request_tool/run?name=$request_name;class=$request_class";
	$u .= $click ? "&click=$click," : '&click=';

	$img = img({-src   => $image_path,
	    -name  => 'theMapImg',
	    -border=> 0,
	    # this is for Internet Explorer, has no effect on Netscape!
	    -onClick=>"send_click(event,'$u')",
	    -usemap=>'#theMap',
	    -isMap=>undef});

	$map = $self->print_map($param, $boxes);
    }

    return $img, $map, $panel;
}

sub print_map {
    my ($self, $param, $boxes) = @_;
    my @lines;
    my $old_clicks = $click;

    # Collect some statistics in order to inhibit those features
    # that are too dense to click on sensibly.
    my %centers;
    foreach my $box (@$boxes) {
	my $center = center($box->{'coordinates'});
	$centers{$center}++;
    }

    my $user_agent =  http('User_Agent');
    my $modern = $user_agent ? $user_agent=~/Mozilla\/([\d.]+)/ && $1 >= 4 : 0;

    my $max = 100;

    foreach my $box (@$boxes) {  
	my $center = center($box->{'coordinates'});
	next if $centers{$center} > $max;
	
	my $coords = join(',',@{$box->{'coordinates'}});
	(my $jcomment = $box->{'comment'} || "$box->{class}:$box->{name}" )
	    =~ s/'/\\'/g; # escape single quotes for javascript

	CASE :
	{
	    if ($box->{name} =~ /gi\|(\d+)/ or 
		($box->{class} eq 'System' and $box->{'comment'}=~/([NP])ID:g(\d+)/)) {
		my($db) = $2 ? $1 : 'n';
		my($gid) = $2 || $1;
		my $url = NCBI . "?db=$db&form=1&field=Sequence+ID&term=$gid";
		push(@lines,qq(<AREA shape="rect"
				     onMouseOver="return toolTip(this,'$jcomment')"
				     coords="$coords"
				     href="$url">));
		last CASE;
	    }
	    if ($box->{class} eq 'BUTTON') {
		my ($c) = map { "$_->[0]-$_->[1]" } [ map { 2+$_ } @{$box->{coordinates}}[0..1]];
		my $clicks = $old_clicks ? "$old_clicks,$c" : $c;
		my $url = "/tools/$request_tool/run?name=$request_name;class=$request_class&click=$clicks";
		push(@lines,qq(<AREA shape="rect"
				     coords="$coords"
				     onMouseOver="return toolTip(this,'$jcomment')"
			             target="_self"
				     href="$url">));
		last CASE;
	    }

	    my $full_name = $box->{'name'};
	    my $n = $full_name =~ /(.*)\".*\".*/ ? $1 : $full_name;
	    my $c = $box->{'class'};
	    my $href;
	    if ("$c" eq 'System' || "$c" eq 'Text') {
		$href = 'nohref';
	    } elsif ($c =~ /gene|rearrangement/i) {
		$href = 'href="' . "/tools/$request_tool/run?name=" . escape($n) . ";class=" . escape($c) . '"';
	    } else {
		$href = 'href="/tools/epic/run?name=' . escape($n) . ";class=" . escape($c) . '"';
	    }
	    push(@lines,qq(<AREA shape="rect"
			         onMouseOver="return toolTip(this,'$jcomment')"
			         coords="$coords"
			         $href>));
	}
    }

    # Create default handling.  Bad use of javascript, but can't think of any other way.
    my $url = "/tools/$request_tool/run?name=$request_name;class=$request_class";
    my $simple_url = $url;
    $url .= "&click=$old_clicks" if $old_clicks;
    $url .= "," if $old_clicks;
    push(@lines,qq(<AREA shape="default"
		         alt=""
		         onClick="send_click(event,'$url'); return false"
		         onMouseOver="return toolTip(this,'clickable region')"
		         href="$simple_url">)) if $modern;
    return qq(<map name="theMap">) . join("\n",@lines) . qq(</map>) . "\n";
}

# special case for maps
# this builds the whole map control/navigation panel
sub build_map_navigation_panel {
    my ($obj,$param,$has_coords) = @_;
    return unless defined $obj;

    my($start,$stop) = $obj->asGif(-getcoords=>1);
    unless ($has_coords) {
      $map_start = $start;
      $map_stop  = $stop;
    }

    my($min,$max)    = get_extremes($DB,$request_name);

    # this section is responsible for centering on the place the user clicks
    if ($click) {
      my ($x,$y) = split '-', $click;
      my $pos    = $map_start + $y/HEIGHT * ($map_stop - $map_start);

      my $offset = $pos - ($map_start + $map_stop)/2;

      $map_start += $offset;
      $map_stop  += $offset;
    }

    my $url = "/tools/gmap/run" ;
    my $half = ($map_stop - $map_start)/2;
    my $a1   = $map_start - $half;
    $a1      = $min if $min > $a1;
    my $a2   = $map_stop - ($map_start - $a1);

    my $b2   = $map_stop + $half;
    $b2      = $max if $b2 > $max;
    my $b1   = $b2 - ($map_stop - $map_start);

    my $m1   = $map_start + $half/2;
    my $m2   = $map_stop  - $half/2;

    my @panel;
    push @panel, start_table({-border=>1});
    push @panel, TR(td({-align=>'CENTER',-class=>'datatitle',-colspan=>2},'Map Control'));
    push @panel, start_TR();
    push @panel, td(
	    table({-border=>0},
		  TR(td('&nbsp;'),
		      td(
			$map_start > $min ?
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$a1;map_stop=$a2"},
			  span({-class=>'ui-icon ui-icon-arrowthick-1-n ui-button'}, 'Up'),' Up')
			:
			font({-color=>'#A0A0A0'},span({-class=>'ui-icon ui-icon-arrowthick-1-n ui-button'}, 'Up'),' Up')
			),
		      td('&nbsp;')
		    ),
		  TR(td({-valign=>'CENTER',-align=>'CENTER'},
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$a1;map_stop=$b2"},
			  span({-class=>'ui-icon ui-icon-zoomout ui-button'}, 'Shrink'),' Shrink')
			),
		      td({-valign=>'CENTER',-align=>'CENTER'},
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$min;map_stop=$max"},'WHOLE')
			),
		      td({-valign=>'CENTER',-align=>'CENTER'},
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$m1;map_stop=$m2"},
			  span({-class=>'ui-icon ui-icon-zoomin ui-button'}, 'Magnify'),' Magnify')
			)
		    ),
		  TR(td('&nbsp;'),
		      td(
			$map_stop < $max ?
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$b1;map_stop=$b2"},
			  span({-class=>'ui-icon ui-icon-arrowthick-1-s ui-button'}, 'Down'),' Down')
			:
			font({-color=>'#A0A0A0'},span({-class=>'ui-icon ui-icon-arrowthick-1-s ui-button'}, 'Down'),' Down')
			),
		      td('&nbsp;'))
		  )

	    );
    push @panel, start_td();

    push @panel, start_form({-action=>'/tools/gmap/run'});
    push @panel, start_p;
    push @panel, hidden({-name=>'name', -value=>$request_name});
    push @panel, 'Show region between: ',
      textfield(-name=>'map_start',-value=>sprintf("%.2f",$map_start),-size=>8,-override=>1),
	' and ',
	  textfield(-name=>'map_stop',- value=>sprintf("%.2f",$map_stop),-size=>8,-override=>1),
	    ' ';
    push @panel, submit('Change');
    push @panel, end_p;
    push @panel, end_form;
    push @panel, end_td(),end_TR(),end_table();

    return \@panel;
}

sub get_extremes {
  my $db = shift;
  my $chrom = shift;
  my $select = qq(select gm[Position] from g in object("Map","$chrom")->Contains[2], gm in g->Map where gm = "$chrom");
  my @positions = $db->aql("select min($select),max($select)");
  my ($min,$max) = @{$positions[0]}[0,1];
  return ($min,$max);
}

sub center {
  my $c = shift;
  my ($left,$right) = @{$c}[0,2];
  # round to nearest 2 pixels
  int( ($left + (($right-$left)/2)) / 2 ) * 2;
}


 
sub error {
  return 0;
}

sub message {
  return 0;
}


1;

