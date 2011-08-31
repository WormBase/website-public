package WormBase::API::Role::Position;

use Moose::Role;

# TODO: (spliced from Role::Object)
# Reconcile all the various versions of genomic_environs and genomic_picture
# Test interpolated_genetic_position
# Genomic position isn't fully abstract: It requires GFF segments to be passed in, or that the Model implement segments()

# segments should probably be private, i.e. prefix with _ ?
# otherwise it should return data in a datapack.
has '_segments' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build__segments',
);

requires '_build__segments'; # no fallback to build segments... yet (or ever?).

has 'genomic_position' => (
    is       => 'ro',
    required => 1,
	lazy     => 1,
	builder  => '_build_genomic_position',
);

# used by genome browser to render image
has 'genomic_image' => (
    is       => 'ro',
    required => 1,
	lazy     => 1,
	builder  => '_build_genomic_image',
);

has 'tracks' => (
    is       => 'ro',
    required => 1,
	lazy     => 1,
	builder  => '_build_tracks',
);

has 'genetic_position' => (
    is       => 'ro',
    required => 1,
	lazy     => 1,
	builder  => '_build_genetic_position',
);

has 'genetic_position_interpolated' => (
    is       => 'ro',
    required => 1,
	lazy     => 1,
	builder  => '_build_genetic_position_interpolated',
);

# NOTE: genomic_picture has been superceded by genomic_image & tracks attribute
#       see Object::Clone and respective templates for example

# this is the fallback. and defaults to the first in genomic_position (i.e. only 1 pos used for image)
sub _build_genomic_image { # genomic_picture_position?
    my ($self) = @_;

    my $positions = $self->genomic_position->{data};
    return {
        description => 'The genomic location of the sequence to be displayed by GBrowse',
        data        => $positions ? $positions->[0] : undef,
    };
}

# this is the fallback. defaults to all segments, without modification to coords.
sub _build_genomic_position {
    my ($self) = @_;

    my @positions = $self->_genomic_position($self->_segments);
    return {
        description => 'The genomic location of the sequence',
        data        => @positions ? \@positions : undef,
    };
}

# this is used when overriding genomic_position
sub _genomic_position {
    my ($self, $segments, $adjust_coords) = @_;
    return unless $segments;
    return map { $self->_seg2posURLpart($_, $adjust_coords) } @$segments;
}

# converts a segment into a URL part for use in GBrowse links
# (optionally with coordinate adjustment)
sub _seg2posURLpart {
    my ($self, $segment, $adjust_coords) = @_;

    my ($ref, $start, $stop) = map { $segment->$_ } qw(abs_ref abs_start abs_stop);
    # return if abs($stop - $start) == 0; # why ?

    ($start, $stop) = $adjust_coords->($start, $stop) if $adjust_coords;

    my $position = $self->_gbrowse_url(ref => $ref, start => $start, stop => $stop);

    return {
        label      => $position,
        id         => $self->_parsed_species . '/?name=' . $position, # looks like a template thing...
        class      => 'genomic_location',
        pos_string => $position, # independent from label -- label may change in the future
    };
}

sub _gbrowse_url {       # should probably be called something else...
    my ($self, %args) = @_;

    my ($ref, $start, $stop)
    = $args{sequence} ? map { $args{sequence}->$_ } qw(abs_ref abs_start abs_stop)
    : @args{qw(ref start stop)};

    if (defined $start && defined $stop && $ref) { # definedness sufficient?
        $ref =~ s/^CHROMOSOME_//;
        ($start, $stop) = ($stop, $start) if $start > $stop;
        if ((my $length = $stop - $start + 1) < 500) {
            $start = int($start - 0.05*$length);
            $stop  = int($stop  + 0.05*$length);
        }
        $ref .= ":$start..$stop";
    }
    return $ref;
}

=head3 genetic_position

This method returns a data structure containing
the genetic position of the requested object, if known.

=over

=item PERL API

 $data = $model->genetic_position();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/genetic_position

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% genetic_position %]

sub _build_genetic_position {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my ($chromosome,$position,$error,$method);

    # CDSs and Sequence are only interpolated
    # AD: no... only Sequence... (that's what the models suggests)
    #  if ($class eq 'CDS' || $class eq 'Sequence') {
    if ($class eq 'Sequence' || $class eq 'Variation') {
        if (eval {$object->Interpolated_map_position}) { # eval added here... should always have Interpolated_map_position?
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';
        }
        else {
            # Try fetching from the gene
            if (my $gene = $object->Gene) {
                $chromosome = $gene->get(Map=>1);
                $position   = $gene->get(Map=>3);
                $method = 'interpolated';
            }
        }
    }
    else {
        ($chromosome,undef,$position,undef,$error) = eval{$object->Map(1)->row};
        # TH: Can't conclude that this is experimentally determined. Model used inconsistently.
        #  $method = 'experimentally determined' if $chromosome;  
	$method = '';
    }

    # Nothing yet? Trying fetching interpolated position.
    unless ($chromosome) {
        #      if ($object->Interpolated_map_position) {
        if ($class eq 'Sequence' && $object->Interpolated_map_position) {
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';
        }
    }

    my $label;
    if ($position) {
        $label= sprintf("$chromosome:%2.2f +/- %2.3f cM",$position,$error || 0);
    }
    else {
        $label = $chromosome;
    }
    
    return {
        description => "the genetic position of the $class:$object",
        data        => {
	    chromosome => $chromosome && "$chromosome",
	    position   => $position   && "$position",
	    error      => $error      && "$error",
	    formatted  => $label      && "$label",
	    method     => $method     && "$method",
	}
    };
}

sub _seg2coords {
    my ($self,$segment) = @_;

    return unless $segment;

    my $prev_abs = $segment->absolute(0); # temporarily set to relative

    my $ref       = $segment->ref;
    my $start     = $segment->start;
    my $stop      = $segment->stop;

    $segment->absolute($prev_abs); # reset relativity

    my $abs_ref   = $segment->abs_ref;
    my $abs_start = $segment->abs_start;
    my $abs_stop  = $segment->abs_stop;
    ($abs_start,$abs_stop) = ($abs_stop,$abs_start) if ($abs_start > $abs_stop);

    return ($abs_ref,$abs_start,$abs_stop,$start,$stop); # what about $ref?
}

######## NOT IN USE AND LIKELY NO LONGER NEEDED


=head3 genetic_position_interpolated

This method returns a data structure containing
the genetic position of the requested object, if known.

=over

=item PERL API

 $data = $model->genetic_position_interpolated();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/genetic_position_interpolated

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% interpolated_genetic_position %]

sub _build_genetic_position_interpolated {
    my ($self) = @_;
    my $object = $self->object;
    my ($chrom,$pos,$error);
    for my $cds ($object->Corresponding_CDS) {
        ($chrom,$pos,$error) = $self->_get_interpolated_position($cds);
        last if $chrom;
    }
    return { description => 'the interpolated genetic position of the object',
             data        => { chromosome         => "$chrom",
                              position            => "$pos",
                              formatted_position => sprintf("%s:%2.2f",$chrom,$pos)
                          },
         }
}

# get the interpolated position of a sequence on the genetic map
# returns ($chromosome, $position,$error)
# position is in genetic map coordinates
# This MIGHT also be the actual experimental position
sub _get_interpolated_position {
    my ($self,$object) = @_;
    $object ||= $self->object;
    if ($object) {
        if ($object->class eq 'CDS') {
            # Is it a query
            # wquery/genelist.def:Tag Locus_genomic_seq
            # wquery/new_wormpep.def:Tag Locus_genomic_seq
            # wquery/wormpep.table.def:Tag Locus_genomic_seq
            # wquery/wormpepCE_DNA_Locus_OtherName.def:Tag Locus_genomic_seq

            # Fetch the interpolated map position if it exists...
            # if (my $m = $object->get('Interpolated_map_position')) {
            if (my $m = eval {$object->get('Interpolated_map_position') }) {
                #my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
                my ($chromosome,$position) = $m->right->row;
                return ($chromosome,$position) if $chromosome;
            }
            elsif (my $l = $object->Gene) {
                return $self->_get_interpolated_position($l);
            }
        }
        elsif ($object->class eq 'Sequence') {
            #my ($chromosome,$position,$error) = $obj->Interpolated_map_position(1)->row;
            my $chromosome = $object->get(Interpolated_map_position=>1);
            my $position   = $object->get(Interpolated_map_position=>2);
            return ($chromosome,$position) if $chromosome;
        }
        else {
            my $chromosome = $object->get(Map=>1);
            my $position   = $object->get(Map=>3);
            return ($chromosome,$position) if $chromosome;
            if (my $m = $object->get('Interpolated_map_position')) {
                my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row unless $position;
                ($chromosome,$position) = $m->right->row unless $position;
                return ($chromosome,$position,$error) if $chromosome;
            }
        }
    }
    return;
}



1;
