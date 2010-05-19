package WormBase::API::Service::Search::Result;

use Moose;

=head1 SYNOPSIS 
This class can be constructed in several ways:

1) give an acedb object as a parameter 
       WormBase::API::Service::Search::Result->new($ace_obj);
   This will construct the result object, setting attributes by getting info
   from the acedb object

2) give an acedb object AND attributes as a parameter
       WormBase::API::Service::Search::Result->new({ace_obj => $ace_obj, id => $id, name => $name, details => $details, type => $type});
   if you specify both an ace object and other params, the params you specify will override
   the default attribute contents from the acedb obj - except for details.  
   The default details will be appended to the details you specify.

3) just give attributes as parameters
      WormBase::API::Service::Search::Result->new({id => $id, name => $name, details => $details, type => $type});
   This will set the attributes without using an acedb object


CONSTRUCTOR ATTRIBUTES:

ace_obj => an acedb object - will be used to set undefined attributes

id      => String, id used in the uri for the object

name    => String, name to be displayed in the search results

details => String, details for the object

type    => type of object, all lowercase (eg gene, variation, etc) 

=cut

# id used in uri for the object
has 'id' => (
     is  => 'rw',
     isa => 'Str',  
     );

# common name/public name used in link
has 'name' => (
     is    => 'rw',
     isa   => 'Str',
     );

# any details to display in the search results, along with object
has 'details' => (
     is       => 'rw',
     isa      => 'Str',
     );

# type of object the result is
has 'type' => (
     is    => 'rw',
     isa   => 'Str',
     );

# overloads constructor to allow for a singer parameter (an acedb object)
# it will then use the acedb object to set values for all the other attributes
around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    if ( @_ == 1 && ref $_[0] ne 'HASH') {
        return $class->$orig(_create_construct_hash($_[0]));
    }
    my $ret = $_[0];
    if(ref $_[0] ne 'HASH') {
      my %hash = @_;
      $ret = \%hash;
    }
    if(exists $ret->{ace_obj}) {
       $ret = _create_construct_hash($ret->{ace_obj}, $ret);
    }
    return $class->$orig($ret);
};

# takes in an acedb object and the constructor arguments, and sets the arguments
# based on the current contents and the acedb info.
# params: acedb object, the constructor arguments as a hash reference
# ret: hash reference of the modified constructor arguemnts
sub _create_construct_hash {
    my $ace_obj = shift;
    my $hash = shift;
        $hash->{id} = _set_id($ace_obj) unless $hash->{id};
        $hash->{name} = _set_name($ace_obj) unless $hash->{name};
        $hash->{details} = $hash->{details} . _set_details($ace_obj);
        $hash->{type} = _set_type($ace_obj) unless $hash->{type};
    return $hash;
}

# set id from ace object
# param: acedb obj
# ret: string, object id
sub _set_id {
    my $ace_obj = shift;
    return "" . $ace_obj;
};

# set name from ace object
### TODO this might only work for genes right now!!!
# param: acedb obj
# ret: string, object name
sub _set_name {
    my $ace_obj = shift;
    my $name = $ace_obj->Public_name ||
               $ace_obj->CGC_name || 
               $ace_obj->Molecular_name || 
        eval { $ace_obj->Corresponding_CDS->Corresponding_protein } || 
               $ace_obj;
    return "" . $name;
};

# set type from ace object
# param: acedb obj
# ret: string, object type
sub _set_type {
    my $ace_obj = shift;
    return lcfirst($ace_obj->class);
};

# set description from ace object.  Use config settings to find
# what should be placed in the description
# param: acedb obj
# ret: string, object description
sub _set_details {
    my $ace_obj = shift;

    # Dear Abby,
    #
    # Finish implementing this to use the config to find out
    # what to place here.  Don't just leave it on Concise_description.
    #
    # Love,
    # your past self

    my $desc = "" . $ace_obj->Concise_description;
    return $desc;
};

no Moose;

1;