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

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# Class-level methods
#
#######################################

=head2 Summary Data

=head3 all_gene_classes

This method will return a data structure containing
all gene classes.

=over

=item PERL API

 $data = $model->all_gene_classes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

The keyword 'all'.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/all/all_gene_classes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub all_gene_classes {
    my $self   = shift;

    my $db   = $self->ace_dsn->dbh;
    my @gene_class = $db->fetch(-query=>qq/find Gene_class/);
    my @rows;
    
    foreach (@gene_class) {
	my $lab   = $_->Designating_laboratory;
	my $desc  = $_->Description; 
	my $phene = $_->Phenotype;
	my @genes = $_->Genes;
        push @rows, { gene_class => $self->_pack_obj($_),
		      laboratory => $self->_pack_obj($lab),
		      description => "$desc",
		      phenotype   => "$phene",
		      genes       => scalar @genes };
    }
    
    return { description => 'a summary of all gene classes',
	     data        => \@rows };   
}


#######################################
#
# Object-level methods
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut

#######################################
#
# The Overview widget 
#
#######################################

=head2 Overview

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub other_names { }
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

=head3 phenotype

This method will return a data structure containing
a string describing the general phenotype of genes
placed in this gene class.

=over

=item PERL API

 $data = $model->phenotype();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Gene class (eg unc)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/phenotype

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub phenotype {
    my $self = shift;
    my $object    = $self->object;
    my $phenotype = $object->Phenotype;
    my $data      = { description => 'general phenotype of genes placed in this gene class',
		      data        => "$phenotype" || undef };
    return $data;
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>



#######################################
#
# The Current Genes widget 
#
#######################################

=head2 Current Genes

=head3 current_genes

This method will return a data structure containing
all genes assigned to the class, organized by species.

=over

=item PERL API

 $data = $model->current_genes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Gene class (eg unc)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/current_genes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub current_genes {
    my $self   = shift;
    my $object = $self->object; 
    
    my %data;
    foreach my $gene ($object->Genes) {
	
	my $species = $gene->Species;
	
	my $sequence_name = $gene->Sequence_name;
	my $locus_name    = $gene->Public_name;
	my $name = ($locus_name ne $sequence_name) ? "$locus_name ($locus_name)" : "$locus_name";
	
	# Some redundancy in the data structure here while
	# we decide how to format this data.
	push @{$data{$species}},
	{ species  => $self->_split_genus_species($species),
	  locus    => $self->_pack_obj($gene),
	  sequence => "$sequence_name",
	};		     
    }
    return { description => 'genes assigned to the gene class, organized by species',
	     data        => \%data };
}

#######################################
#
# The Previous Genes widget 
#
#######################################

=head2 Previous Genes

=head3 former_genes

This method will return a data structure containing
genes that used to belong to the current gene class
but have been reassigned to another class, or that
have been reassigned a new gene name within the same
class.

=over

=item PERL API

 $data = $model->former_genes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Gene class (eg unc)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/former_genes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub former_genes {
    my $self   = shift;
    my $object = $self->object;
        
    my %data;
    foreach my $old_gene ($object->Old_member) {
	my $gene = $old_gene->Other_name_for || $old_gene->Public_name_for;
	
	my $data = $self->_stash_former_member($gene,$old_gene,'reassigned to new class');
	
	my $species = $gene->Species;
	push @{$data{$species}},$data;
    }
    
    my $data = { description => 'genes formerly in the class that have been reassigned to a new class',
		 data        => \%data };    
}


=head3 reassigned_genes

This method will return a data structure containing
genes that have been reassigned within the gene class.

=over

=item PERL API

 $data = $model->reassigned_genes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Gene class (eg unc)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/reassigned_genes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub reassigned_genes {
    my $self   = shift;
    my $object = $self->object;
    my $dbh = $self->ace_dsn->dbh;
    
    my @genes = eval {$dbh->fetch(-query=>qq{find Gene where Other_name="$object*"})};
    my %data;
    foreach my $gene (@genes) {
	my $species = $gene->Species;
	
	# Only keep them if their current locus name matches the object name
	# We're looking for genes that have been reassigned
	my $public_name = $gene->Public_name;
	my @other_names =  grep { /$public_name/ } $gene->Other_name;
	foreach (@other_names) {
	    my $data = $self->_stash_former_member($gene,$_);
	    push @{$data{$species}},$data;
	}
    }
    my $data = { description => 'genes that have been reassigned a new name in the same class',
		 data        => \%data };    
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
    my %data = ( species     => $self->_pack_obj($gene->Species),
		 former_name => "$old_gene",
		 new_name    => $self->_pack_obj($gene,$gene->Public_name),
		 sequence    => ($sequence_name) ? $self->_pack_obj($sequence_name) : undef,
		 reason      => $reason );
    return \%data;
}

__PACKAGE__->meta->make_immutable;

1;

