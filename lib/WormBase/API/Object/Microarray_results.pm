package WormBase::API::Object::Microarray_results;
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
    my $data = { description => 'The corresponding gene',
         data        =>  $self->_pack_obj($object->Gene, $object->Gene->Public_name), 
    };
    return $data;
}

sub cds {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The corresponding cds',
         data        => $self->_pack_obj($object->CDS),
    };
    return $data;
}



1;
