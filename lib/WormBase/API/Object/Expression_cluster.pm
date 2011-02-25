package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=head3 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Transgene ID (gmIs13)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head5 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}



sub gene {
    my $self = shift;
    my $object = $self->object;
    my %ret;
    map { {$ret{"$_"} = $self->_pack_obj($_, $_->Public_name)}} $object->Gene;
    my $data = { description => 'The corresponding gene',
         data        =>  \%ret, 
    };
    return $data;
}

sub description {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'Description',
         data        =>  $object->Description, 
    };
    return $data;
}

# remarks() provided by Object.pm. We retain here for completeness of the API documentation.

=head3 remarks

This method will return a data structure containing
curatorial remarks for the gene class.

=head4 PERL API

 $data = $model->remarks();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

A Gene class (eg unc)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/remarks

=head5 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }

sub algorithm {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'Algorithm',
         data        =>  $object->Algorithm, 
    };
    return $data;
}



1;
