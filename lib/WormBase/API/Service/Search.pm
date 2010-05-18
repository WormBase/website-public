package WormBase::API::Service::Search;

use Moose;
use WormBase::API::Service::Search::Result;

has 'dbh' => (
    is         => 'ro',
    isa        => 'WormBase::API::Service::acedb',
    );

sub basic {
  my ($self,$args) = @_;
  my $class  = $args->{class};
  my $pattern   = $args->{pattern};
  my ($count,@objs);
  @objs = $self->dbh->fetch(-class=>$class,
			    -pattern=>$pattern,
			    -total=>\$count);
  return (\@objs) if @objs;
}

# Search for gene objects
sub gene {
  my ($self,$args) = @_;
  my $pattern   = $args->{pattern};
  my ($count,@objs);

# implement searching for things other than WBGeneID
  @objs = $self->dbh->fetch(-class=>'Gene',
			    -pattern=>$pattern,
			    -total=>\$count);

  # don't bother formatting object if we're going to redirect
  if(scalar @objs == 1){ return \@objs;} 

  my $result = __PACKAGE__ . "::Result";
  @objs = map { $result->new($_)} @objs;
  return (\@objs) if @objs;
}

# Search for variataion objects
sub variation {
  return;
}

no Moose;
# __PACKAGE__->meta->make_immutable;

1;