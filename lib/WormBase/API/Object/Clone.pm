package WormBase::API::Object::Clone;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Clone

=head1 SYNPOSIS

Model for the Ace ?Clone class.

=head1 URL

http://wormbase.org/species/clone

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 type

This method will return a data structure containing
the general type of this clone.

=over

=item PERL API

 $data = $model->type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/type

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub type {
    my ($self) = @_;
    
    my $type = $self ~~ 'Type';
    return {
	description => 'The type of this clone',
	data		=> $type && "$type",
    };
}

=head3 sequences

This method will return a data structure containing
sequences corresponding to the clone in FASTA format.

=over

=item PERL API

 $data = $model->sequences();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/sequences

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub sequences {
    my ($self) = @_;
    
    # genomic data of the sequence can probably be refactored out somewhere...
    # see comment in genomic_picture
    my %sequences = map {
        my $map = $_->Interpolated_map_position(2);
        my ($start, $end, $refname, $ref) = $self->_get_genomic_position_using_object($_);
        $_ => $self->_pack_obj(
            $_, undef,
            start   => $start,
            end     => $end,
            ref     => $ref,
            refname => $refname,
            chrom   => $self->_pack_obj($_->Interpolated_map_position),
            map     => $map && "$map",
	    )
    } @{$self ~~ '@Sequence'};
    
    return {
	description => 'sequences associated with this clone',
	data		=> %sequences ? \%sequences : undef,
    }
}


=head3 lengths

This method will return a data structure containing
the lenths of clones as estimated by gel electrophoresis.

=over

=item PERL API

 $data = $model->lengths();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/lengths

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub lengths {
    my ($self) = @_;
    my %data = map { $_ => $self ~~ "$_" } qw(Seq_length Gel_length);
    return {
	description => 'lengths relevant to this clone',
	data   	    => %data ? \%data : undef,
    };
}


=head3 maps

This method will return a data structure containing
maps relevant to the requested clone.

=over

=item PERL API

 $data = $model->maps();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/maps

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub maps {
    my ($self) = @_;
    
    # get Maps from object itself, otherwise try for Maps from Pmap
    my $map = $self ~~ '@Map';
    $map = eval {[$self->object->Pmap->Map] } unless @$map;
    
    return {
	description => 'maps assigned to this clone',
	data	    => $map && @$map ? $self->_pack_objects($map) : undef,
    };
}


=head3 sequence_status

This method will return a data structure containing
the sequencing status of this clone.

=over

=item PERL API

 $data = $model->sequence_status();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/sequence_status

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Returns the sequence status of the clone. Each key represents a status
# and a status => undef pair represents no ?DateType or Text data for the status,
# but does not invalidate the status itself.
sub sequence_status {
    my ($self) = @_;
    
    # eval is in scalar context to force an undef instead of empty list
    my %status = map { $_ => scalar eval {$_->right->name}} @{$self ~~ '@Sequence_status'};
    return {
	description => 'sequencing status of clone',
	data	    => %status ? \%status : undef,
    };
}

=head3 canonical_for

This method will return a data structure containing
clones that the requested clone is a canonical
representative of.

=over

=item PERL API

 $data = $model->canonical_for();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/canonical_for

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub canonical_for {
    my ($self) = @_;
    
    my $canonical = $self->_pack_objects($self ~~ '@Canonical_for');
    return {
	description => 'clones that the requested clone is a canonical representative of',
	data		=> %$canonical ? $canonical : undef,
    };
}

=head3 canonical_parent

This method will return a data structure containing
the canonical parent of this clone, if there is one.

=over

=item PERL API

 $data = $model->canonical_parent();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/canonical_parent

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub canonical_parent {
    my ($self) = @_;

    my @canonical_parent = map {$self->_pack_obj($_)}  (
	$self ~~ 'Approximate_Match_to',
	$self ~~ 'Exact_Match_to',
	$self ~~ 'Funny_Match_to',
    );
    
    return {
	description => 'canonical parent for clone',
	data	    => @canonical_parent ? \@canonical_parent : undef,
    }
}

=head3 screened_positive

This method will return a data structure containing
entities that were shown to be contained within the clone.

=over

=item PERL API

 $data = $model->screened_positive();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/screened_positive

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub screened_positive {
    my ($self) = @_;
    
    my %weaks = map {$_ => 1} @{$self ~~ '@Pos_probe_weak'};
    my %data = map { $_ => $self->_pack_obj($_, undef, weak => $weaks{$_}) }
    $self->object->Positive(2);
    
    return {
	description => 'entities shown to be contained within this clone',
	data		=> %data ? \%data : undef,
    };
}

=head3 screened_negative
    
This method will return a data structure containing
entities shown NOT to be contained within the requested
clone.

=over

=item PERL API

 $data = $model->screened_negative();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/screened_negative

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub screened_negative {
    my ($self) = @_;
    
    my $data = $self->_pack_objects([$self->object->Negative(2)]);
    return {
	description => 'entities shown to NOT be contained within the requested clone',
	data	    => %$data ? $data : undef,
    };
}


=head3 gridded_on

This method will return a data structure containing
gridding information of the clone during fingerprinting.

=over

=item PERL API

 $data = $model->gridded_on();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/gridded_on

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub gridded_on {
    my ($self) = @_;
    
    my $data = $self->_pack_objects($self ~~ '@Gridded');
    return {
	description => 'grid this clone was gridded on during fingerprinting',
	data	    => %$data ? $data : undef,
    };
}

=head3 references

This method will return a data structure containing
references citing this clone.

=over

=item PERL API

 $data = $model->references();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/references

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub references {
    my ($self) = @_;
    
    my $data = $self->_pack_objects($self ~~ '@Reference');
    return {
	description => 'references that cite this clone',
	data	    => %$data ? $data : undef,
    };
}

=head3 physical_picture

This method will return a data structure containing
a link to an image representing this clone.

=over

=item PERL API

 $data = $model->physical_picture();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/physical_picture

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub physical_picture { # TODO (TH: And probably not necessary)
    my ($self) = @_;
    
    # not what $PmapGFF translates to, e.g. $DBGFF --> $self->gff_dsn
    # see classic code seq/clone
    
    return {
        description => 'Physical picture data',
        data        => 'NOT IMPLEMENTED',
    };
}

=head3 genomic_picture

This method will return a data structure containing
the genomic coordinates of the clone.

=over

=item PERL API

 $data = $model->genomic_picture();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/genomic_picture

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub genomic_picture {
    my ($self) = @_;
    
    my ($ref, $start, $stop);
    if (my $segment = $self->gff_dsn->segment(-class => 'region',
                                              -name => $self->object)) {
        # the following looks like something done in Object::genomic_position...
        # consider refactoring?  TH: Yes it is, but the method in Role::Object isn't yet sufficiently generic. It should be.
        my ($absref,           $absstart,           $absend)
	    = ($segment->abs_ref, $segment->abs_start, $segment->abs_end);
        ($absstart, $absend) = ($absend, $absstart) if $absstart > $absend;
	
        ($ref, $start, $stop) = ($absref, int $absstart, int $absend);
	
        # the following appear in classic website but are commented out because
        # fore som reason it doesn't work. may wish to investigate later
	
        # my $new_segment = $self->gff_dsn->segment({
        #     -name => 'name',
        #     -class => 'Sequence'
        #     -start => $start,
        #     -stop => $stop,
        # });
	
    }
    
    return {
        description => 'genomic environs of the clone',
        data        => {
            ref   => $ref,
            start => $start,
            stop  => $stop,
        },
    };
}



#######################################
#
# The External Links widget
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>


########################################
## PRIVATE METHODS
########################################

# override default remarks from Role::Object
sub _build_remarks {
    my ($self) = @_;

    my @remarks = map { "$_" } (@{$self ~~ '@General_remark'},
                                @{$self ~~ '@Y_remark'},
                                @{$self ~~ '@PCR_remark'});

    return {
        description => 'Remarks',
        data        => @remarks ? \@remarks : undef,
    };
}

1;
