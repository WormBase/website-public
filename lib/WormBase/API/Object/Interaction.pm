package WormBase::API::Object::Interaction;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Interaction

=head1 SYNPOSIS

Model for the Ace ?Interaction class.

=head1 URL

http://wormbase.org/species/*/interaction

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

# Override Role to give a better label for name.
sub _build_name { 
    my $self = shift;
    my $object = $self->object;
    my $label = join(' : ',map { $_->Public_name } $object->Interactor);
    return {
        description => "The name and WormBase internal ID of $object",
        data        =>  $self->_pack_obj($object,$label),
    };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 interactor

This method will return a data structure with the interactors.

=over

=item PERL API

 $data = $model->interactor();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Interaction id (eg WBInteraction0000779)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interactor

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub interactor {
    my $self   = shift;   
    my $object = $self->object;
    my @interacting = $object->Interactor;
    my $genes  = $self->_pack_objects(\@interacting);
    return { description => 'the genes in this interaction',
	     data        => %$genes ? $genes : undef,
    };
}

=head3 interaction_types

This method will return a data structure containing the effector, effected, and phenotypes for each Interaction_type.

=over

=item PERL API

 $data = $model->interaction_types();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Interaction id (eg WBInteraction0000779)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interaction_types

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub interaction_types {
    my $self = shift;
    my $object = $self->object;
    my @data;

    foreach my $type ($object->Interaction_type) {
	my %info;

	$info{Type} = "$type";
	foreach my $tag ('Effector', 'Effected', 'Non_directional', 'Interaction_phenotype', 'Interaction_RNAi'){
	    my @vals = map {$self->_pack_obj($_)} $type->$tag;
	    if ($tag =~ /Effect|Non_dir/) { $info{Interactors}{interaction}{$tag} = @vals ? \@vals : undef }
	    else { $info{$tag} = @vals ? \@vals : undef }
	}

	push @data, \%info;
    }

    return {
        data => @data ? \@data : undef,
        description => 'Effector, Effected, and Phenotypes associated with each Interaction type'
    };
}

###########################
#
# The Interactors Widget
#
###########################

=head2 Interactors

=cut

=head3 effector_data

This method will return a data structure with effector_data for the interaction.

=over

=item PERL API

 $data = $model->effector_data();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Interaction id (eg WBInteraction0000779)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/effector_data

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub effector_data {
    my $self = shift;
    my $data = $self->_interactor_data('Effector');

    return {
        data        => $data || undef,
        description => 'Additional information about effector interactor(s)'
    };
}

=head3 effected_data

This method will return a data structure with effected_data for the interaction.

=over

=item PERL API

 $data = $model->effected_data();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Interaction id (eg WBInteraction0000779)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/effected_data

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub effected_data {
    my $self = shift;
    my $data = $self->_interactor_data('Effected');
    return {
        data        => $data,
        description => 'Additional information about effected interactor(s)'
    };
}

=head3 non_directional_data

This method will return a data structure with date for the non_directional interactions.

=over

=item PERL API

 $data = $model->non_directional_data();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Interaction id (eg WBInteraction0000779)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/non_directional_data

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub non_directional_data {
    my $self      = shift;
    my $data = $self->_interactor_data('Non_directional');

    return {
        data => $data,
        description => 'Additional information about non-directional interactor(s)'
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

#######################################
#
# The References Widget
#
#######################################

=head2 References

=cut

# sub references {}
# Supplied by Role; POD will automatically be inserted here.
# << include references >>



#######################################
#
# Internal Methods
#
#######################################

sub _interactor_data {
    my ($self, $interactor_type) = @_;
    my $object = $self->object;
    my %data;

    foreach my $type ($object->Interaction_type){
	foreach my $gene ($type->$interactor_type){
	    next if $data{$gene};
	    my @num_interactions = $gene->Interaction;
	    my @proteins = map {
			my $protein = $_->Corresponding_protein;
			my $name = $self->_make_common_name($protein);
			$self->_pack_obj($protein, "$name ($protein)")
		} $gene->Corresponding_CDS;
	    $data{"$gene"} = {
		gene		=> $self->_pack_obj($gene),
		interactions	=> scalar @num_interactions,
		proteins	=> @proteins ? \@proteins : undef,
	    }
	}
    }
    my @results = sort values %data;
    return @results ? \@results : undef;
}

__PACKAGE__->meta->make_immutable;

1;

