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

# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>




=head3 species

This method will return a data structure with species containing the operon.

=over

=item PERL API

 $data = $model->species();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Operon id (eg CEOP1140)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/species

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub species {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Species;
    my $data_pack  = $self->_pack_obj($tag_object);
    return {
        'data'        => $data_pack,
        'description' => 'species containing the operon'
    };
}

=head3 structure

This method will return a data structure with structure of the operon.

=over

=item PERL API

 $data = $model->structure();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Operon id (eg CEOP1140)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/structure

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub structure {
    my $self   = shift;
    my $operon = $self->object;
    my @data_pack;
    my @member_gene = $operon->Contains_gene;

    foreach my $gene (@member_gene) {
        my $gene_info = $self->_pack_obj($gene);
        my %spliced_leader;
        foreach my $sl ( $gene->col ) {
            my @evidence = $sl->col;
            $spliced_leader{$sl} = \@evidence
              ;    # each spliced leader key is linked to an array of evidence
        }
        push @data_pack,
          {
            gene_info   => $gene_info,
            splice_info => \%spliced_leader
          };
    }
    return {
        'data'        => \@data_pack,
        'description' => 'structure information for this operon'
    };
}

=head3 history

This method will return a data structure with history of the operon.

=over

=item PERL API

 $data = $model->history();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Operon id (eg CEOP1140)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/operon/CEOP1140/history

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub history {
     my $self   = shift;
     my $object = $self->object;
     my %data_pack;
     my @history_types = $object->History;
 
     foreach my $history_type (@history_types) {
         my %histories;
         foreach my $h ( $history_type->col ) {
             my @evidence = $h->col;
             @evidence = $self->_get_evidence_names(\@evidence);
             $histories{$h} = \@evidence;
         }
         $data_pack{$history_type} = \%histories;
     }
     return {
         'data'        => @history_types ? \%data_pack : undef,
         'description' => 'history of the information on the operon'
     };
}

#########################
#
# Internal Methods
#
##########################

sub _get_evidence_names {
	my $self = shift;
    my $evidences = shift;
    my @ret;

    foreach my $ev (@$evidences) {
        my @names = $ev->col;
        if (   $ev eq "Person_evidence"
            || $ev eq "Author_evidence"
            || $ev eq "Curator_confirmed" )
        {
            $ev =~ /(.*)_(evidence|confirmed)/;   #find a better way to do this?
            @names = map { $1 . ': ' . $_->Full_name || $_ } @names;
        }
        elsif ( $ev eq "Paper_evidence" ) {
            @names = map { 'Paper: ' . $_->Brief_citation || $_ } @names;
        }
        elsif ( $ev eq "Feature_evidence" ) {
            @names = map { 'Feature: ' . $_->Visible->right || $_ } @names;
        }
        elsif ( $ev eq "From_analysis" ) {
            @names = map { 'Analysis: ' . $_->Description || $_ } @names;
        }
        else {
            @names = map { $ev . ': ' . $_ } @names;
        }
        push( @ret, @names );
    }
    return @ret;
}

__PACKAGE__->meta->make_immutable;

1;

