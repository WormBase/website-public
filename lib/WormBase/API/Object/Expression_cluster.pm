package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The name of the expression cluster',
         data        => $self->_pack_obj($object),
    };
    return $data;
}

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

=head2 remarks

This method will return a data structure containing
curatorial remarks for the gene class.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/remarks

=head4 Response example

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
