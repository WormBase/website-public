package WormBase::API::Object::Gene_class;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Gene_class

=head1 SYNPOSIS

Model for the Ace ?Gene_class class.

=head1 URL

http://wormbase.org/species/gene_class

=cut

#######################################
#
# The Overview widget 
#
#######################################

=head2 name

This method will return a data structure of the 
name and ID of the requested gene class.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/name

=head4 Response example

<div class="response-example"></div>

=cut 

# Provided by Object.pm; retain pod for complete documentation of the API
#sub name { }

=head2 other_names

This method will return a data structure containing 
other names that have been used to describe the 
requested gene class.

=head3 PERL API

 $data = $model->other_names();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/other-names

=head4 Response example

<div class="response-example"></div>

=cut 

sub other_names {
    my $self = shift;
    my $object = $self->object;
    my @other_names = map { $self->_pack_obj($_) } $object->Other_name;
    my $data = { description => 'other names that have been used for this gene class',
		 data        => \@other_names };
    return $data;
}


=head2 description

This method will return a data structure containing
a brief description of the gene class abbreviation.

=head3 PERL API

 $data = $model->description();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/description

=head4 Response example

<div class="response-example"></div>

=cut 

sub description {
    my $self = shift;
    my $object = $self->object;
    my $description = $object->Description;
    my $data = { description => 'a brief description of the gene class abbreviation',
		 data        => "$description" };
    return $data;
}

# laboratory() is provided by Object.pm. Documentation
# duplicated here for completeness of API

=head2 laboratory

This method will return a data structure containing
the laboratory that coined the gene class.

=head3 PERL API

 $data = $model->laboratory();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/laboratory

=head4 Response example

<div class="response-example"></div>

=cut 

=head2 phenotype

This method will return a data structure containing
a string describing the general phenotype of genes
placed in this gene class.

=head3 PERL API

 $data = $model->phenotype();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/phenotype

=head4 Response example

<div class="response-example"></div>

=cut 

sub phenotype {
    my $self = shift;
    my $object    = $self->object;
    my $phenotype = $object->Phenotype;
    my $data      = { description => 'general phenotype of genes placed in this gene class',
		      data        => "$phenotype" || undef };
    return $data;
}

# remarks() provided by Object.pm. We retain here for completeness of the API documentation.

=head2 remarks

This method will return a data structure containing
curatorial remarks for the gene class.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/remarks

=head4 Response example

<div class="response-example"></div>

=cut 


#######################################
#
# The Current Members widget 
#
#######################################

=head2 current_members

This method will return a data structure containing
all genes assigned to the class, organized by species.

=head3 PERL API

 $data = $model->current_members();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/current_members

=head4 Response example

<div class="response-example"></div>

=cut 

sub current_members {
    my $self   = shift;
    my $object = $self->object;
    
    my @genes  = $object->Genes;

    my %data;
    foreach my $gene (@genes) {
	
	my $species = $gene->Species;
	
	my $sequence_name = $gene->Sequence_name;
	my $locus_name    = $gene->Public_name;
	my $name = ($locus_name ne $sequence_name) ? "$locus_name ($locus_name)" : "$locus_name";

	# Some redundancy in the data structure here while
	# we decide how to format this data.
	push @{$data{$species}},
	{ species  => "$species",
	  locus    => $self->_pack_obj($gene),
	  sequence => "$sequence_name",
	};		     
    }
    my $data = { description => 'genes assigned to the gene class, organized by species',
		 data        => \%data };
    return $data;
}

#######################################
#
# The Previous Members widget 
#
#######################################

=head2 former_members

This method will return a data structure containing
genes that used to belong to the current gene class
but have been reassigned to another class, or that
have been reassigned a new gene name within the same
class.

=head3 PERL API

 $data = $model->former_members();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/former_members

=head4 Response example

<div class="response-example"></div>

=cut 

sub former_members {
    my $self   = shift;
    my $object = $self->object;

    my %data_pack;
    my @genes = $object->Old_member;

    foreach my $old_gene (@genes) {
	my $gene = $old_gene->Other_name_for || $old_gene->Public_name_for;

	my $data = $self->_stash_former_member($gene,$old_gene,'reassigned to new class');
	
	my $species = $gene->Species;
	push @{$data_pack{$species}},$data;
    }

    my $data = { description => 'genes formerly in the class that have been reassigned to a new class',
		 data        => \%data_pack };    
}


=head2 reassigned_members

This method will return a data structure containing
genes that have been reassigned within the gene class.

=head3 PERL API

 $data = $model->reassigned_members();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/reassigned_members

=head4 Response example

<div class="response-example"></div>

=cut 

sub reassigned_members {
    my $self   = shift;
    my $object = $self->object;
    my $dbh = $self->ace_dsn->dbh;
     
    my @genes = eval {$dbh->fetch(-query=>qq{find Gene where Other_name="$object*"})};
    my %data_pack;
    foreach my $gene (@genes) {
	my $species = $gene->Species;

	# Only keep them if their current locus name matches the object name
	# We're looking for genes that have been reassigned
	my $public_name = $gene->Public_name;
	my @other_names =  grep { /$public_name/ } $gene->Other_name;
	foreach (@other_names) {
	    my $data = $self->_stash_former_member($gene,$_);
	    push @{$data_pack{$species}},$data;
	}
    }
    my $data = { description => 'genes that have been reassigned a new name in the same class',
		 data        => \%data_pack };    
    return $data;
}

##############################
#
# Internal methods
#
##############################
sub _stash_former_member {
    my ($self,$gene,$old_gene,$reason) = @_;
    
    my $sequence_name = $gene->Sequence_name;
    my $locus_name    = $gene->Public_name;
    my %data = ( species => $self->_pack_obj($gene->Species),
		 former_name => "$old_gene",
		 new_name    => $self->_pack_obj($gene,$gene->Public_name),
		 sequence    => ($sequence_name) ? $self->_pack_obj($sequence_name) : undef,
		 reason      => $reason );
    return \%data;
}

1;
