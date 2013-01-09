package WormBase::API::Object::Analysis;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Analysis

=head1 SYNPOSIS

Model for the Ace ?Analysis class.

=head1 URL

http://wormbase.org/resources/analysis

=cut


#######################################
#
# CLASS METHODS
#
#######################################


#######################################
#
# INSTANCE METHODS
#
#######################################


#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# title { }
# This method returns a data structure containing the 
# the title of the analysis, if there is one.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/title

sub title {
    my ($self) = @_;
    my $title = $self ~~ 'Title';

    return {
        description => 'the title of the analysis',
        data        => $title && "$title",
    };
}

# description { }
# Supplied by Role

# based_on_wb_release { }
# This method returns a data structure containing 
# the WormBase release the analysis is based on.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/based_on_wb_release

sub based_on_wb_release {
    my ($self) = @_;
    my $release = $self ~~ 'Based_on_WB_Release';

    return {
        description => 'the WormBase release the analysis is based on',
        data        => $release && "$release",
    };
}


# based_on_db_release { }
# This method returns a data structure containing 
# the database release the analysis is based on.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/based_on_db_release

sub based_on_db_release {
    my ($self) = @_;
    my $release = $self ~~ 'Based_on_DB_Release';

    return {
        description => 'the database release the analysis is based on',
        data        => $release && "$release",
    };
}

# project { }
# This method returns a data structure containing 
# the project that conducted the analysis.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/project

sub project {
    my $self = shift;

    return { description => 'the project that conducted the analysis',
	     data        => $self->_pack_obj($self ~~ 'Project')
    };
}


# subproject { }
# This method returns a data structure containing 
# the subproject of the analysis.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/subproject

sub subproject {
    my $self = shift;
   
    return { description => 'the subproject of the analysis if there is one',
	     data        => $self->_pack_obj($self ~~ 'Subproject')
    };
}

# conducted_by { }
# This method returns a data structure containing 
# the person that conducted the analysis.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/conducted_by

sub conducted_by {
    my ($self) = @_;

    return {
        description => 'the person that conducted the analysis',
        data        => $self->_pack_obj($self ~~ 'Conducted_by'),
    };
}


############################################################
#
# The External Links widget
#
############################################################ 

# xrefs {}
# Supplied by Role


#######################################
#
# The References Widget
#
#######################################

# references {}
# Supplied by Role

__PACKAGE__->meta->make_immutable;

1;

