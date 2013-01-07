package WormBase::API::Object::Disease; 

use Moose;
use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';
# extends 'WormBase::API::Object';

has 'object' => (
    is  => 'rw',
    
    required => 1,
);

has 'name' => (
    is       => 'rw',
    required => 1,
    lazy     => 1,
    builder  => '_build_name',
);
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

# id { }
# This method returns a data structure containing the 
# omim_id of the disease
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/disease/182870/id

sub id {
	my $self = shift;
	return $self->omim_id;
}

# name { }
# This method returns a data structure containing the 
# name of the disease
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/disease/182870/name

sub _build_name {
	my $self = shift;
	 
	return { data=>$self->object->{name},
		  description=>"the title of the disease",
	      };
}



sub notes {
	my $self = shift;
	 
	return { data=>$self->object->{description} || undef,
		  description=>"the description of the disease from OMIM",
	      };
}

sub synonym {
	my $self = shift;
	
	 
	return { data=>      $self->object->{synonym}? $self->object->{synonym} : undef,
		  description=>"the synonym of the disease from OMIM",
	      };
}

sub hs_genes {
	my $self = shift;
	 
	return { data=>$self->object->{hsgene}? [grep { $_ ne ''} @{$self->object->{hsgene}}] : undef,
		  description=>"the related human genes of the disease from OMIM",
	      };
}

sub genes {
	my $self = shift;
	 
	return { data=>$self->object->{gene} ? [grep { $_ ne ''} @{$self->object->{gene}}] : undef,
		  description=>"the Orthologous C.elegans genes of the disease",
	      };
}




1;
