package WormBase::API::Object::Disease; 
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';
with    'WormBase::API::Role::ThirdParty::OMIM';


=pod 

=head1 NAME

WormBase::API::Object::Disease

=head1 SYNPOSIS

Model for the Ace ?Disease class.

=head1 URL

http://wormbase.org/species/disease

=cut




##############################
#
# Overview Widget
#
###############################

sub definition {
    my ($self) = @_;
    my $def = $self ~~ 'Definition';
    return {
        description => 'Definition of this disease',
        data        => $def && "$def",
    };
}

sub omim {
	my $self = shift; 
 	my %data =  %{$self->xrefs->{data}->{OMIM}} if $self->xrefs->{data}->{OMIM};
	
	return {
		description => 'link to OMIM record',
		data => %data ? \%data : undef 
	}
}

sub parent {
    my ($self) = @_;
    my @parent = map { $self->_pack_obj($_) } $self->object->Is_a;
    return {
        description => 'Parent of this disease ontology',
        data        => @parent ? \@parent : undef,
    };
}

sub child {
    my ($self) = @_;
    my @child = map { $self->_pack_obj($_) } $self->object->Child->col if $self->object->Child;
    return {
        description => 'Children of this disease ontology',
        data        => @child ? \@child : undef ,
    };
}

sub type {
    my ($self) = @_;
    my @types = map {"$_"} $self->object->Type;
    map {s/_/ /g} @types;
    return {
        description => 'Type of this disease',
        data        => @types ? \@types : undef,
    };
}

sub synonym {
    my ($self) = @_;
    my @synonym = map { map { "$_" } $_->col } $self->object->Synonym;

    return {
        description => 'Synonym of this disease',
        data        => @synonym ? \@synonym : undef ,
    };
}

has 'genes_orthology' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__genes_orthology',
);

has 'genes_biology' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__genes_biology',
);

sub _get_gene_relevance{
    my ($self, $gene) = @_;
    my @omim_ace = $gene->DB_info->at('OMIM.gene') if $gene->DB_info;  #human homologs
    my @omim = map {"$_";} @omim_ace;
    my @relevance_ace = $gene->Disease_relevance;
    my @relevance = map { {text => "$_", evidence=>$self->_get_evidence($_->right) } } @relevance_ace;

    my $relevance;
    my $data = {
        gene => $self->_pack_obj($gene),
        human_orthologs => $self->markup_omims(\@omim),
        relevance => @relevance ? \@relevance : undef
    };

    return $data;
}

sub _build__genes_orthology {
    my ($self) = @_;
    my @data = map { _get_gene_relevance($self, $_) } $self->object->Gene_by_orthology;
    return {
        description => 'Genes by orthology to human disease gene',
        data        => @data ? \@data : undef ,
    };
}

sub _build__genes_biology {
    my ($self) = @_;
    my @genes = map { _get_gene_relevance($self, $_) } $self->object->Gene_by_biology;
    return {
        description => 'Genes used as experimental models',
        data        => @genes ? \@genes : undef ,
    };
}






__PACKAGE__->meta->make_immutable;

1;
