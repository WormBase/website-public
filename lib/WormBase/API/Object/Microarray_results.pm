package WormBase::API::Object::Microarray_results;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=head2 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head4 Response example

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
