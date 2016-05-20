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

# Should be overridden by implementations that would like to have
# images generated (via '_build_genomic_image') for each of their
# genomic positions.
sub _make_multiple_genomic_images {
    return undef;
}

# This is a fallback. Defaults to the largest genomic_position (i.e. only 1 position is used for image).
sub _build_genomic_image { # genomic_picture_position?
    my ($self) = @_;

    my $positions = $self->genomic_position->{data};

    if ($self->_make_multiple_genomic_images()) {
      return {
          description => 'The genomic locations of the sequences to be displayed by GBrowse',
          data        => $positions
      };
    }

    # Go through all positions and pick the one with the widest range:
    my $widest_span = undef;
    for my $position (@$positions) {
        unless (defined $widest_span) {
            # No purported widest range set yet, so pick the first best choice and
            # iterate over that in the next rounds of the 'for' loop.
            $widest_span = $position;
        } else {
          if (defined $position->{'label'}) {
            # Positions are taken from the 'label', which look like: I:4224..5286
            if (not defined $widest_span->{'label'}) {
                # If the current purported widest span has no label, then pick the current
                # position as next best choice (which may not have a 'label' either).
                $widest_span = $position;
            } else {
                # Otherwise: dissect both labels and compare the start/end coordinates.
                if ($position->{'label'} =~ /.+:[0-9]+\.+[0-9]+/ && $widest_span->{'label'} =~ /.+:[0-9]+\.+[0-9]+/) {
                    my @purported_widest_loci = split(/:\./, $widest_span->{'label'});
                    my @loci = split(/:\./, $position->{'label'});

                    if ($purported_widest_loci[1] >= $loci[1] && $purported_widest_loci[-1] <= $loci[-1]) {
                        $widest_span = $position;
                    }
                }
            }
          }
        }
    }
    return {
        description => 'The genomic location of the sequence to be displayed by GBrowse',
        data        => $widest_span
    };
}

# this is the fallback. defaults to all segments, without modification to coords.
sub _build_genomic_position {
    my ($self) = @_;

    my @positions = $self->_genomic_position($self->_segments);
    unless ($self->_make_multiple_genomic_images()) {
        @positions = splice(@positions, 0, 1);
    }
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

    my ($ref, $o_start, $o_stop) = map { $segment->$_ } qw(seq_id start end);
    # return if abs($stop - $start) == 0; # why ?

    my ($start, $stop) = $adjust_coords->($o_start, $o_stop) if $adjust_coords;

    # Create padded coordinates suitable for generating a GBrowse image
    my $position = $self->_format_coordinates(ref => $ref, start => ($start || $o_start), stop => ($stop || $o_stop), pad_for_gbrowse => 1);
    # Use the ACTUAL feature coordinates for the label, not the GBrowse coordinates.
    return {
        label      => $self->_format_coordinates(ref => $ref, start => $o_start, stop => $o_stop),
        id         => $position,
        taxonomy   => $self->_parsed_species,
        class      => 'genomic_location',
        pos_string => $position, # independent from label -- label may change in the future
    };
}

sub _format_coordinates {
    my ($self,%args) = @_;

    my ($ref, $start, $stop, $pad_for_gbrowse)
	= $args{sequence} ? map { $args{sequence}->$_ } qw(abs_ref start stop pad_for_gbrowse)
	: @args{qw(ref start stop pad_for_gbrowse)};

    if (defined $start && defined $stop && $ref) { # definedness sufficient?
        $ref =~ s/^CHROMOSOME_//;
        ($start, $stop) = ($stop, $start) if $start > $stop;

	# This probably doesn't belong here and should be parameterized.
	if ($pad_for_gbrowse) {
	    $start = int($start - 0.2*($stop-$start));
	    $stop  = int($stop  + 0.05*($stop-$start));
	}
        $ref .= ":$start..$stop";
    }
    return $ref;
}

# Is the segment smaller than 100? Let's adjust
# NOTE: this ISN'T a function called with $self
sub _pad_short_seg_simple {
    my ($start, $stop) = @_;
    return $stop - $start < 100
             ? ($start - 50, $stop + 50)
             : ($start, $stop);
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
    my $class  = $self->_api->modelmap->ACE2WB_MAP->{class}->{$object->class};
    my ($chromosome,$position,$error,$method);

    # CDSs and Sequence are only interpolated
    # AD: no... only Sequence... (that's what the models suggests)
    #  if ($class eq 'CDS' || $class eq 'Sequence') {
    if ($class eq 'Sequence' || $class eq 'Variation') {
        my $imp = eval {$object->Interpolated_map_position};
        if ($imp) {
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';

        }
        else {
            # Try fetching from the gene
            if (my $gene = $object->Gene) {
                #$chromosome = $gene->get(Map=>1);
                #$position   = $gene->get(Map=>3);
		# Let's include the error, too.
		($chromosome,undef,$position,undef,$error) = eval{$gene->Map(1)->row};
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
        if (($class eq 'Sequence' || $class eq 'Gene') && $object->Interpolated_map_position) {
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';
        }
    }

    return {
        description => "Genetic position of $class:$object",
        data => [ $self->make_genetic_position_object($class, $object, $chromosome, $position, $error, $method)->{'data'} ]
    };
}

# Creates a label for the genetic position object and then returns its data
# structure denoting genomic locus and method used, or error message (if applicable).
# Class and object type have to be passed along too, which determine provenance of
# the object's content (API class).
sub make_genetic_position_object {
    my ($self,$class,$object,$chromosome,$position,$error,$method) = @_;

    my $label;
    if (defined $position) {
        $label= sprintf("$chromosome:%2.2f +/- %2.3f cM",$position,$error || 0);
    }
    else {
        $label = $chromosome;
    }

    return {
        description => "the genetic position of the $class:$object",
        data        => {
	    chromosome => $chromosome && "$chromosome",
	    position   => defined $position ? "$position" : undef,  # watch out for 0 value
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
    my $abs_stop = $segment->abs_end;

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
