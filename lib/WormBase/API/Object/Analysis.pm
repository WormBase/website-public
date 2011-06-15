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

=head3 title

This method returns a data structure containing the 
the title of the analysis, if there is one.

=over

=item PERL API

 $data = $model->title();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An analysis ID (eg TreeFam)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/title

B<Response example>

<div class="response-example"></div>

=back

=cut

sub title {
    my $self = shift;
    my $object = $self->object;
    my $title  = $object->Title;
    my $data = { description => 'the title of the analysis',
		 data        => "$title" || undef};
    return $data;
}

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>


=head3 based_on_wb_release

This method returns a data structure containing 
the WormBase release the analysis is based on.

=over

=item PERL API

 $data = $model->based_on_wb_release();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An analysis ID (eg TreeFam)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/based_on_wb_release

B<Response example>

<div class="response-example"></div>

=back

=cut

sub based_on_wb_release {
    my $self = shift;
    my $object = $self->object;
   
    my $release = $object->Based_on_WB_Release;
    my $data = { description => 'the WormBase release the analysis is based on',
		 data        => "$release" || undef };
    return $data;
}


=head3 based_on_db_release

This method returns a data structure containing 
the database release the analysis is based on.

=over

=item PERL API

 $data = $model->based_on_db_release();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An analysis ID (eg TreeFam)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/based_on_db_release

B<Response example>

<div class="response-example"></div>

=back

=cut

sub based_on_db_release {
    my $self = shift;
    my $object = $self->object;
   
    my $release = $object->Based_on_DB_Release;
    my $data = { description => 'the database release the analysis is based on',
		 data        => "$release" || undef };
    return $data;
}

=head3 project

This method returns a data structure containing 
the project that conducted the analysis.

=over

=item PERL API

 $data = $model->project();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An analysis ID (eg TreeFam)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/project

B<Response example>

<div class="response-example"></div>

=back

=cut

sub project {
    my $self = shift;
    my $object = $self->object;
   
    my $project = $object->Project;
    my $data    = { description => 'the project that conducted the analysis',
		    data        => $project ? $self->_pack_obj($project) : undef
    };
    return $data;
}


=head3 subproject

This method returns a data structure containing 
the subproject of the analysis.

=over

=item PERL API

 $data = $model->subproject();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An analysis ID (eg TreeFam)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/subproject

B<Response example>

<div class="response-example"></div>

=back

=cut

sub subproject {
    my $self = shift;
    my $object = $self->object;
   
    my $project = $object->Subproject;
    my $data    = { description => 'the subproject of the analysis if there is one',
		    data        => $project ? $self->_pack_obj($project) : undef
    };
    return $data;
}

=head3 conducted_by

This method returns a data structure containing 
the person that conducted the analysis.

=over

=item PERL API

 $data = $model->conducted_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An analysis ID (eg TreeFam)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/conducted_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub conducted_by {
    my $self = shift;
    my $object = $self->object;
   
    my $person = $object->Conducted_by;
    if ($person) {
	my $name = $person->Standard_name;
	$person = $self->_pack_obj($person,$name);
    }
    my $data    = { description => 'the person that conducted the analysis',
		    data        => $person ? $person : undef };
    return $data;
}


############################################################
#
# The External Links widget
#
############################################################ 

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


__PACKAGE__->meta->make_immutable;

1;

