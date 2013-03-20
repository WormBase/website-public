package WormBase::API::Object::Disease; 
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';


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
 	my %data =  %{$self->xrefs->{data}->{OMIM}};
	
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
    my $type = $self ~~ 'Type';
    $type =~ s/_/ /g;
    return {
        description => 'Type of this disease',
        data        => $type && "$type",
    };
}

sub synonym {
    my ($self) = @_;
    my @synonym = map { $_->col} $self->object->Synonymn;

    return {
        description => 'Synonym of this disease',
        data        => @synonym ? \@synonym : undef ,
    };
}

sub genes {
    my ($self) = @_;
    my @genes = map { $self->_pack_obj($_) } $self->object->Gene_by_orthology;
    return {
        description => 'Elegans genes by orthology to human disease gene',
        data        => @genes ? \@genes : undef ,
    };
}


__PACKAGE__->meta->make_immutable;

1;
