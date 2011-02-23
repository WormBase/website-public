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

=head1 Methods

=cut

#######################################
#
# The Overview Widget
#
#######################################

=head2 name

This method will return a data structure of the name
of the analysis object.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/name

=head4 Response example

<div class="response-example"></div>

=cut			 

# supplied by Object.pm; retain pod for complete documentation of API
# sub name { }

=head2 database

This method returns a data structure containing the 
the database of the analysis, if there is one.

=head3 PERL API

 $data = $model->database();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/database

=head4 Response example

<div class="response-example"></div>

=cut

sub database {
    my $self   = shift;
    my $object = $self->object;

    my $database = $object->Database;
    my $url    = $object->URL;
    my $description = ($database) ? $database->Description : undef;

    my $data   = {  description => 'the remote database and URI',
		    data        =>  { database    => "$database"  || undef,
				      url         => "$url"       || undef,
				      description => "$description",
		    },
    };
    return $data;
}
    
=head2 title

This method returns a data structure containing the 
the title of the analysis, if there is one.

=head3 PERL API

 $data = $model->titlee();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/title

=head4 Response example

<div class="response-example"></div>

=cut

sub title {
    my $self = shift;
    my $object = $self->object;
    my $title  = $object->Title;
    my $data = { description => 'the title of the analysis',
		 data        => "$title" || undef};
    return $data;
}

=head2 description

This method returns a data structure containing 
a description of the analysis, if there is one.

=head3 PERL API

 $data = $model->description();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/description

=head4 Response example

<div class="response-example"></div>

=cut

sub description {
    my $self = shift;
    my $object = $self->object;
    my $description = $object->Description;
    my $data  = { description => 'a description of the analysis',
		  data        => "$description" || undef };
    return $data;
}


=head2 based_on_wb_release

This method returns a data structure containing 
the WormBase release the analysis is based on.

=head3 PERL API

 $data = $model->based_on_wb_release();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/based_on_wb_release

=head4 Response example

<div class="response-example"></div>

=cut

sub based_on_wb_release {
    my $self = shift;
    my $object = $self->object;
   
    my $release = $object->Based_on_WB_Release;
    my $data = { description => 'the WormBase release the analysis is based on',
		 data        => "$release" || undef };
    return $data;
}


=head2 based_on_db_release

This method returns a data structure containing 
the database release the analysis is based on.

=head3 PERL API

 $data = $model->based_on_db_release();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/based_on_db_release

=head4 Response example

<div class="response-example"></div>

=cut

sub based_on_db_release {
    my $self = shift;
    my $object = $self->object;
   
    my $release = $object->Based_on_DB_Release;
    my $data = { description => 'the database release the analysis is based on',
		 data        => "$release" || undef };
    return $data;
}

=head2 project

This method returns a data structure containing 
the project that conducted the analysis.

=head3 PERL API

 $data = $model->project();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/project

=head4 Response example

<div class="response-example"></div>

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


=head2 subproject

This method returns a data structure containing 
the subproject of the analysis.

=head3 PERL API

 $data = $model->subproject();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/subproject

=head4 Response example

<div class="response-example"></div>

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

=head2 conducted_by

This method returns a data structure containing 
the person that conducted the analysis.

=head3 PERL API

 $data = $model->conducted_by();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

An analysis ID (eg TreeFam)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/analysis/TreeFam/conducted_by

=head4 Response example

<div class="response-example"></div>

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


1;
