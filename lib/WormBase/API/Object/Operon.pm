package WormBase::API::Object::Operon;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Operon

=head1 SYNPOSIS

Model for the Ace ?Operon class.

=head1 URL

http://wormbase.org/species/operon

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

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub remarks { }
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head2 species

This method will return a data structure species containing this Operon.

=head3 PERL API

 $data = $model->species();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Operon ID CEOP1140

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/species

=head4 Response example

<div class="response-example"></div>

=cut

sub species {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Species;
	my $data_pack = $self->_pack_obj($tag_object);
	return {
		'data'=> $data_pack,
		'description' => ''
		};
}

=head2 structure

This method will return a data structure with the species containing this Operon.

=head3 PERL API

 $data = $model->structure();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Operon ID CEOP1140

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/structure

=head4 Response example

<div class="response-example"></div>

=cut

sub structure {
	my $self = shift;
	my $operon = $self->object;
	my @data_pack;
	my @member_gene = $operon->Contains_gene;
 
	foreach my $gene (@member_gene) {
		my $gene_info = $self->_pack_obj($gene);
	  	my %spliced_leader;
	    foreach my $sl ($gene->col) {
	    	my @evidence = $sl->col;
			$spliced_leader{$sl} = \@evidence;      # each spliced leader key is linked to an array of evidence 
	    }
	    push @data_pack, {
	    	gene_info => $gene_info,
			splice_info => \%spliced_leader
	    };
	 } 
	return {
		'data'=> \@data_pack,
		'description' => 'structure information for this operon'
	};
}

=head2 history

This method will return a data structure with history info on this Operon.

=head3 PERL API

 $data = $model->history();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Operon ID CEOP1140

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/history

=head4 Response example

<div class="response-example"></div>

=cut

sub history {
	my $self = shift;
	my $object = $self->object;
	my %data_pack;
	my  @history_types = $object->History;
	
	foreach my $history_type (@history_types) {
		my %histories;
	  	foreach my $h ($history_type->col) {
	    	my @evidence = $h->col;	     
	     	@evidence = _get_evidence_names(\@evidence);
	    	$histories{$h} = \@evidence;                    
	  	} 
	  	$data_pack{$history_type} = \%histories;        
	}
	return {
		'data'=> $data_pack,
		'description' => ''
	};
}

sub _get_evidence_names {
  my ($evidences)=shift;
  my @ret;
  
  foreach my $ev (@$evidences) {
    my @names = $ev->col;
    if($ev eq "Person_evidence" || $ev eq "Author_evidence" || $ev eq "Curator_confirmed") {    
      $ev =~ /(.*)_(evidence|confirmed)/;  #find a better way to do this?    
      @names =  map{$1 . ': ' . $_->Full_name || $_} @names;
    }elsif ($ev eq "Paper_evidence"){
      @names = map{'Paper: ' . $_->Brief_citation || $_} @names;
    }elsif ($ev eq "Feature_evidence"){
      @names = map{'Feature: '.  $_->Visible->right || $_} @names;
    }elsif ($ev eq "From_analysis"){
      @names = map{'Analysis: '. $_->Description || $_} @names;
    }else {
      @names = map{$ev . ': ' . $_} @names;
    }
    push(@ret, @names);
  }
  return @ret;
}


1;
