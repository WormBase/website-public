package WormBase::API::Service::epic;

use Moose;
with 'WormBase::API::Role::Object';

use strict;
use vars qw/$DB $dsn $request_name $request_class $click $map_start $map_stop/;

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
    my $data = {};
    return $data;
}

sub run {
    my ($self, $param) = @_;
    $request_name = $param->{'name'};
    $request_class = $param->{'class'};
    $click = $param->{'click'};
    $map_start = $param->{'map_start'};
    $map_stop  = $param->{'map_stop'};

    my ($obj, $bestname, $img, $map, $msg);

    $dsn  = $self->ace_dsn->dbh;
    if ($request_name && $request_class) { $obj = $dsn->fetch(-class => $request_class, -name  => $request_name, -fill => 1) }

    if (DISABLED) {
	$msg = "Sorry, but graphical displays have been disabled temporarily.";
    } elsif (lc($request_class) eq 'sequence' && $request_name =~ /SUPERLINK|CHROMOSOME/) {
	$msg = "This sequence is too large to display. Try a shorter segment.";
    } elsif ($obj) {
	($img, $map) = $self->display_object($param,$obj);
	$msg    = "No graphical information about $request_name available in the database" unless $img;
    } else {
	$msg = "$request_class:$request_name could not be found in the database.";
    }

    return { data => { object => { class => $request_class,
			  name  => $request_name,
	      },
	      img   => $img,
	      img_map   => $map,
	      msg    => $msg || undef,
    }};
}

sub display_object {
    my ($self, $param, $obj) = @_;
    my $has_coords = defined $map_start && defined $map_stop && $map_start =~ /^-?\d+(?:\.\d+)?$/ && $map_stop =~ /^-?\d+(?:\.\d+)?$/ && $map_start < $map_stop;

    my $nav_panel = build_map_navigation_panel($obj,$param,$has_coords) if $request_class =~ /Map/i;

    my $safe_name = $request_name;
    $safe_name=~tr/[a-zA-Z0-9._\-]/_/c;
    my $db = $dsn->title;
    $db=~s!^/!!;
    my $path = join('/',$db,$request_class);

    $safe_name .= "." . $click if $click;
    $safe_name .= ".start=$map_start,stop=$map_stop" if $has_coords;
    $safe_name .= ".gif";
    my $image_file = $self->image_dir . '/' . $safe_name;
    my $image_path = $self->tmp_image_uri($image_file);

    # get the parameters for the image generation
    my @clicks =  map { [ split('-',$_) ] } split(',',$click);

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
	my $u = "/tools/epic/run?name=$request_name;class=$request_class";
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

    return $img, $map;
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
    my $modern = $user_agent=~/Mozilla\/([\d.]+)/ && $1 >= 4;

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
		my $url = "/tools/epic/run?name=$request_name;class=$request_class&click=$clicks";
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
	    my $href = "$c" eq 'System' || "$c" eq 'Text' ? 'nohref' : 'href="/tools/epic/run?name=' . escape($n) . ";class=" . escape($c) . '"';
	    push(@lines,qq(<AREA shape="rect"
			         onMouseOver="return toolTip(this,'$jcomment')"
			         coords="$coords"
			         $href>));
	}
    }

    # Create default handling.  Bad use of javascript, but can't think of any other way.
    my $url = "/tools/epic/run?name=$request_name;class=$request_class";
    my $simple_url = $url;
    $url .= "&click=$old_clicks";
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

    my $url = "/tools/epic/run" ;
    my $half = ($map_stop - $map_start)/2;
    my $a1   = $map_start - $half;
    $a1      = $min if $min > $a1;
    my $a2   = $map_stop - ($map_start - $a1);

    my $b2   = $map_stop + $half;
    $b2      = $max if $b2 > $max;
    my $b1   = $b2 - ($map_stop - $map_start);

    my $m1   = $map_start + $half/2;
    my $m2   = $map_stop  - $half/2;

    my $text = '';
    $text .= start_table({-border=>1});
    $text .= TR(td({-align=>'CENTER',-class=>'datatitle',-colspan=>2},'Map Control'));
    $text .= start_TR();
    $text .= td(
	    table({-border=>0},
		  TR(td('&nbsp;'),
		      td(
			$map_start > $min ?
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$a1;map_stop=$a2"},
			  img({-src=>UP_ICON,-align=>'MIDDLE',-border=>0}),' Up')
			:
			font({-color=>'#A0A0A0'},img({-src=>UP_ICON,-align=>'MIDDLE',-border=>0}),' Up')
			),
		      td('&nbsp;')
		    ),
		  TR(td({-valign=>'CENTER',-align=>'CENTER'},
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$a1;map_stop=$b2"},
			  img({-src=>ZOOMOUT_ICON,-align=>'MIDDLE',-border=>0}),' Shrink')
			),
		      td({-valign=>'CENTER',-align=>'CENTER'},
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$min;map_stop=$max"},'WHOLE')
			),
		      td({-valign=>'CENTER',-align=>'CENTER'},
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$m1;map_stop=$m2"},
			  img({-src=>ZOOMIN_ICON,-align=>'MIDDLE',-border=>0}),' Magnify')
			)
		    ),
		  TR(td('&nbsp;'),
		      td(
			$map_stop < $max ?
			a({-href=>"$url?name=$request_name;class=$request_class;map_start=$b1;map_stop=$b2"},
			  img({-src=>DOWN_ICON,-align=>'MIDDLE',-border=>0}),' Down')
			:
			font({-color=>'#A0A0A0'},img({-src=>DOWN_ICON,-align=>'MIDDLE',-border=>0}),' Down')
			),
		      td('&nbsp;'))
		  )

	    );
    $text .= start_td({-rowspan=>2});

    $text .= start_form;
    $text .= start_p;
    $text .= hidden($_) foreach qw(class name);
    $text .= 'Show region between: ' .
      textfield(-name=>'map_start',-value=>sprintf("%.2f",$map_start),-size=>8,-override=>1) .
	' and ' .
	  textfield(-name=>'map_stop',- value=>sprintf("%.2f",$map_stop),-size=>8,-override=>1) .
	    ' ';
    $text .= submit('Change');
    $text .= end_p;
    $text .= end_form;
    $text .= end_td(),end_TR(),end_table();

    return $text;
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

