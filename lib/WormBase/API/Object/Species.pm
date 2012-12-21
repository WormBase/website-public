package WormBase::API::Object::Species;

use Moose;
use File::Spec;
use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# TODO:
#  Split _build_description (see comment down below)
#  Movie method?

=pod

=head1 NAME

WormBase::API::Object::Species

=head1 SYNPOSIS

Model for the Ace ?Species class.

=head1 URL

http://wormbase.org/species/*

=cut


#######################################
#
# CLASS METHODS
#
#######################################

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


#######################################
#
# The Genome Assemblies widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>




# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>



=head3 assembly

This method will return data for a datatable containing details
on the assemblies for this species

=over

=item PERL API

 $data = $model->assembly();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Species full name (eg Caenorhabditis elegans)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/species/Caenorhabditis elegans/assembly

B<Response example>

<div class="response-example"></div>

=back

=cut

sub assembly {
    my $self   = shift;
    my $object = $self->object;

    # Multiple assemblies for a given species are 
    # represented by linking from the live Sequence_collection
    # to others.

    my @assemblies = $object->Assembly;
    my @data;
    foreach (@assemblies) {
	push @data,$self->_process_assembly($_);

	# Starting from live and working backwards.
	if ($_->Supercedes) {
	    push @data,$self->_process_assembly($_->Supercedes);
	}
    }
    
#    my @data = map {
#      my $ref = $_->Evidence ? $_->Evidence->right : $_->Laboratory;
#      my $label = $_->Name || "$_";
#      { name => $self->_pack_obj($_->Name, "$label", coord => { start => 1 }),
#        sequenced_strain  => $self->_pack_obj($_->Strain),
#        first_wb_release  => "WS" . $_->First_WS_release,
#	latest_wb_release => "WS" . $_->Latest_WS_release,
#	superceded_by     => $self->_pack_obj($_->Superceded_by),
#        reference         => $self->_pack_obj($ref),
#	status            => "live",
#	    
#      }
#     } grep {$_->Status ne 'Dead' && $_->Status ne 'Suppressed'} $object->Assembly;
    

    return {
      description => "genomic assemblies",
      data => @data ? \@data : undef
    }
}


sub _process_assembly {    
    my ($self,$assembly) = @_;
#	if ($assembly->Superceded_by) {
#	    my $data = $self->$process($assembly->Superceded_by);
#	}

    my $ref    = $assembly->Evidence ? $assembly->Evidence->right : $assembly->Laboratory;
    my $label  = $assembly->Name || "$assembly";

    my $superceded_by = $assembly->Superceded_by ? $assembly->Superceded_by : '-';
    my $status        = $superceded_by ? 'superceded' : 'current';

    my $wb_range      = 
	"WS" . $assembly->First_WS_release . ' - '
	. ($assembly->Superceded_by ? "WS" . $assembly->Latest_WS_release : ''); 
	

    my $data = { name => $self->_pack_obj($assembly->Name, "$label", coord => { start => 1 }),
		 sequenced_strain  => $self->_pack_obj($assembly->Strain),
		 first_wb_release  => "WS" . $assembly->First_WS_release,
		 latest_wb_release => "WS" . $assembly->Latest_WS_release,
		 wb_release_range  => $wb_range,
		 reference         => $self->_pack_obj($ref),
		 status            => $status,
    };
    return $data;
}


=head3 ncbi_id

This method will return the NCBI taxonomy ID for this species

=over

=item PERL API

 $data = $model->ncbi_id();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Species full name (eg Caenorhabditis elegans)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/species/Caenorhabditis elegans/ncbi_id

B<Response example>

<div class="response-example"></div>

=back

=cut

sub ncbi_id {
    my $self   = shift;
    my $object = $self->object;

    my $ncbi_id = $object->NCBITaxonomyID;
    return {
      description => "NCBI taxonomy id for the species",
      data => "$ncbi_id" || undef
    }
}



############################################################
#
# PRIVATE METHODS
#
############################################################

__PACKAGE__->meta->make_immutable;

1;

