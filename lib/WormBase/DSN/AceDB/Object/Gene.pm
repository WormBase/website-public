package WormBase::DSN::AceDB::Object::Gene;

use Moose;

has 'acedbh' => (
    is => 'ro',
    required => 1,
    );

extends 'WormBase::DSN::AceDB::Object';


# Should I try to fetch an object during instantiation?

#sub BUILD {
#    my $self   = shift;
#    return $self if $self->has_current_object;
#    $self->log->debug("instantiating " . __PACKAGE__);
#    my $object = $self->get_object(ucfirst($self->class),$self->request);    
#    $self->ace_object($object) if $object;
#}


###################################################
# Methods overriding SUPER belong here.
###################################################
sub common_name {
  my ($self) = @_;
#  my $object = $self->current_object;
  my $object = $self->get_object('Gene','WBGene00006798');
  $self->log->debug($object);
  my $common_name = 
    $object->Public_name
      || $object->CGC_name
	|| $object->Molecular_name
	  || eval { $object->Corresponding_CDS->Corresponding_protein }
	    || $object;
  return $common_name;
}



1;
