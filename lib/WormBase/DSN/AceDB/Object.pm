package WormBase::DSN::AceDB::Object;

use Moose;

has 'acedbh' => (
    is => 'ro',
    required => 1,
    );



#has 'current_object' => (
#    is => 'rw',
#    predicate => 'has_ace_object',
#    );

#has 'request' => (
#    is => 'ro',
#    isa => 'Str' 
#   );



sub hi {
    my $self = shift;
    print "Hi, I'm a " . ref($self) . " and I say [" . $self->acedbh. "]\n";
}



sub get_object {
    my ($self,$class,$name) = @_;
    
    $self->log->debug("get_object(): class:$class name:$name");
    
    my $db = $self->dbh();
    my $formatted_class = ucfirst($class);
    my $object = $db->fetch(-class=>$formatted_class,-name=>$name,-fill=>1);    

    return $object;
}


1;
