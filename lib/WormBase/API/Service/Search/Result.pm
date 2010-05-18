package WormBase::API::Service::Search::Result;

use Moose;

# This class can be constructed:
# WormBase::API::Service::Search::Result->new($ace_obj);
# WormBase::API::Service::Search::Result->new({ace_obj => $ace_obj}); ! doesn't work yet
# WormBase::API::Service::Search::Result->new({id => $id, name => $name, description => $description});

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

    if ( @_ == 1 ) {
        return $class->$orig({id => _set_id($_[0]), 
                            name => _set_name($_[0]), 
                            type => _set_type($_[0]), 
                         details => _set_details($_[0])});
    }
    # this part doesn't work yet... do we need it?
#     elsif (@_->{ace_obj}){
#         my $ace_obj = @_->{ace_obj}; 
#         @_->{id} = _set_id($ace_obj) unless @_->{id};
#         @_->{name} = _set_name($ace_obj) unless @_->{name};
#         @_->{description} = _set_description($ace_obj) unless @_->{description};
#         return $class->$orig(@_);
#     }
    else {
        return $class->$orig(@_);
    }
};

# set id from ace object
# param: acedb obj
# ret: string, object id
sub _set_id {
    my $ace_obj = shift;
    return "" . $ace_obj;
}

# set name from ace object
# param: acedb obj
# ret: string, object name
sub _set_name {
    my $ace_obj = shift;
    my $name = $ace_obj->Public_name ||
      $ace_obj->CGC_name || $ace_obj->Molecular_name || eval { $ace_obj->Corresponding_CDS->Corresponding_protein } || $ace_obj;
    return "" . $name;
}

# set type from ace object
# param: acedb obj
# ret: string, object type
sub _set_type {
    my $ace_obj = shift;
    return lcfirst($ace_obj->class);
}

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
}

no Moose;

1;