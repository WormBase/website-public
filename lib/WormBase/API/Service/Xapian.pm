package WormBase::API::Service::Xapian;

use base qw/Catalyst::Model/;
use Moose;

use strict;

use Catalyst::Model::Xapian::Result;
use Encode qw/from_to/;
use Search::Xapian qw/:all/;
use Storable;
use MRO::Compat;
use Time::HiRes qw/gettimeofday tv_interval/;
use Config::General;
use Number::Format qw(:subs :vars);
use URI::Escape;


has 'db' => (isa => 'Search::Xapian::Database', is => 'rw');
has 'syn_db' => (isa => 'Search::Xapian::Database', is => 'rw');

has 'qp' => (isa => 'Search::Xapian::QueryParser', is => 'rw');
has 'syn_qp' => (isa => 'Search::Xapian::QueryParser', is => 'rw');

has '_doccount' => (
    is          => 'ro',
    isa         => 'Int',
    default     => sub {
      my $self = shift;
      return $self->db->get_doccount;
    },
);

has 'modelmap' => (
    is => 'ro',
    lazy => 1,
    required => 1,
    default => sub {
        return WormBase::API::ModelMap->new; # just a blessed scalar ref
    },
);


sub search {
    my ( $class, $c, $q, $page, $type, $species, $page_size) = @_;
    my $t=[gettimeofday];
    $page       ||= 1;
    $page_size  ||=  10;
    $q =~ s/\s/\* /g;
    $q = "$q*";

    if($type){
      $q = $class->_add_type_range($c, $q, $type);
      if(($type =~ m/paper/) && ($species)){
        my $s = $c->config->{sections}->{resources}->{paper}->{paper_types}->{$species};
        $q .= " ptype:$s..$s" if defined $s;
        $species = undef;
      }
    }

    if($species){
        my $s = $c->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s" if defined $s;
    }

    my $query=$class->qp->parse_query( $q, 512|16 );
    my $enq       = $class->db->enquire ( $query );

    if($type && $type =~ /paper/){
          $enq->set_sort_by_value(4);
    }
    my $mset      = $enq->get_mset( ($page-1)*$page_size,
                                     $page_size );


    my ($time)=tv_interval($t) =~ m/^(\d+\.\d{0,2})/;

    return Catalyst::Model::Xapian::Result->new({ mset=>$mset,
        search=>$class,query=>$q,query_obj=>$query,querytime=>$time,page=>$page,page_size=>$page_size });
}

sub search_autocomplete {
    my ( $class, $c, $q, $type) = @_;
    $q = $class->_add_type_range($c, $q . "*", $type);

    my $query=$class->syn_qp->parse_query( $q, 64|16 );
    my $enq       = $class->syn_db->enquire ( $query );
    $c->log->debug("query auto:" . $query->get_description());
    my $mset      = $enq->get_mset( 0, 10 );

    if($mset->empty()){
      $query=$class->qp->parse_query( $q, 64|16 );
      $enq       = $class->db->enquire ( $query );
      $c->log->debug("query auto2:" . $query->get_description());
      $mset      = $enq->get_mset( 0, 10 );
    }

    return Catalyst::Model::Xapian::Result->new({ mset=>$mset,
        search=>$class,query=>$q,query_obj=>$query,page=>1,page_size=>10 });
}

sub search_exact {
    my ($class, $c, $q, $type) = @_;
    my ($query, $enq, $mset);
    if( $type ){
      $query=$class->qp->parse_query( "\"$type$q\"", 1|2 );
      $enq       = $class->db->enquire ( $query );
      $c->log->debug("query exacta:" . $query->get_description());
      $mset = $enq->get_mset( 0,2 ) if $enq;

      if ($mset->size() != 1){
        $query=$class->qp->parse_query( $class->_uniquify($q, $type) . "*", 1|2 );
        $enq       = $class->db->enquire ( $query );
        $c->log->debug("query exactaa:" . $query->get_description());
        $mset = $enq->get_mset( 0,2 ) if $enq;
      }
      $mset = undef if ($mset->size() != 1);
    }

    if((!$mset || $mset->empty() || $q =~ m/\s/) && (!($q =~ m/\s.*\s/))){
        my $qu = "$q";
        $qu = "\"$qu\"" if(($qu =~ m/\s/) && !($qu =~ m/_/));
        $qu = $class->_add_type_range($c, "$qu", $type);
        $query=$class->syn_qp->parse_query( $qu, 16|2|256 );
        $enq       = $class->syn_db->enquire ( $query );
        $c->log->debug("query exactb:" . $query->get_description());
        $mset      = $enq->get_mset( 0,2 ) if $enq;
    }

    if(!$mset || $mset->empty()){
      $q = "\"$q\"" if(($q =~ m/\s/) && !($q =~ m/_/));
      $q =~ s/\s/\* /g;
      $q = $class->_add_type_range($c, "$q", $type);
      $query=$class->qp->parse_query( $q, 2|16|256|512 );
      $enq       = $class->db->enquire ( $query );
      $c->log->debug("query exactc:" . $query->get_description());
      $mset      = $enq->get_mset( 0,2 );
    }

    return Catalyst::Model::Xapian::Result->new({ mset=>$mset,
        search=>$class,query=>$q,query_obj=>$query,page=>1,page_size=>1 });
}

sub random {
    my ( $class, $c) = @_;
    return $class->_get_obj($c, $class->db->get_document(int(rand($class->_doccount)) + 1));
}

sub search_count {
 my ( $class, $c, $q, $type, $species) = @_;
    $q =~ s/\s/\* /g;
    $q = "$q*";

    if($type){
      $q = $class->_add_type_range($c, $q, $type);

      if(($type =~ m/paper/) && ($species)){
        my $s = $c->config->{sections}->{resources}->{paper}->{paper_types}->{$species};
        $q .= " ptype:$s..$s" if defined $s;
        $species = undef;
      }
    }

    if($species){
        my $s = $c->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s" if defined $s;
    }

    my $query=$class->qp->parse_query( $q, 512|16 );
    my $enq       = $class->db->enquire ( $query );
    $c->log->debug("query count:" . $query->get_description());

    my $mset      = $enq->get_mset( 0, 500000 );
    return format_number($mset->get_matches_estimated());
}
 
 
=item extract_data <item> <query>

Extract data from a L<Search::Xapian::Document>. Defaults to
using Storable::thaw.

=cut

sub extract_data {
    my ( $self,$item, $query ) = @_;
    my $data=Storable::thaw( $item->get_data ); 
    return $data;
}


sub _get_obj {
  my ($self, $c, $doc, $footer) = @_;

  my %ret;
  $ret{name} = $self->_pack_search_obj($c, $doc);
  my $species = $ret{name}{taxonomy};
  if($species =~ m/^(.).*_([^_]*)$/){
    my $s = $c->config->{sections}{species_list}{$species};
    $ret{taxonomy}{genus} = $s->{genus} || uc($1) . '.';
    $ret{taxonomy}{species} = $s->{species} || $2;
  }
  $ret{ptype} = $doc->get_value(7) if $doc->get_value(7);
  %ret = %{$self->_split_fields($c, \%ret, uri_unescape($doc->get_data()))};
  if($doc->get_value(4) =~ m/^(\d{4})/){
    $ret{year} = $1;
  }

  $ret{footer} = $footer if $footer;
  return \%ret;
}

sub _split_fields {
  my ($self, $c, $ret, $data) = @_;

  $data =~ s/\\([\;\/\\%\"])/$1/g;
  while($data =~ m/^([\S]*)[=](.*)[\n]([\s\S]*)$/){
    my ($d, $label) = ($2, $1);
    my $array = $ret->{$label} || ();
    $data = $3;
    
    if($d =~ m/^WB/){
     $d = $self->_get_tag_info($c, $d, $label);
    }elsif($label =~ m/^author$/){
      my ($id, $l);
      if($d =~ m/^(.*)\s(WBPerson\S*)$/){
        $id = $2;
        $l = $1;
      }
      $d = { id =>$id || $d, 
             label=>$l || $d,
             class=>'person'}
    }
    push(@{$array}, $d);
    $ret->{$label} = $array;
  }
  return $ret;
}

sub _get_tag_info {
  my ($self, $c, $id, $class, $fill, $footer, $aceclass) = @_;

  if ($class) { # WB class was provided
      $aceclass = $self->modelmap->WB2ACE_MAP->{class}->{ucfirst($class)}
                || $self->modelmap->WB2ACE_MAP->{fullclass}->{ucfirst($class)};
      $aceclass = $class unless $aceclass;
  }

  if (ref $aceclass eq 'ARRAY') { # multiple Ace classes
    foreach my $ace (@$aceclass) {
      my ($it,$res)= $self->search_exact($c, $id, lc($ace));
      if($it->{pager}->{total_entries} > 0 ){
        my $doc = @{$it->{struct}}[0]->get_document();
        return $self->_get_obj($c, $doc, $footer) if $fill;

        my $ret = $self->_pack_search_obj($c, $doc);
        $ret->{class} = $class;
        return $ret;
      }
    }
  }else{
    my ($it,$res)= $self->search_exact($c, $id, lc($aceclass));
    if($it->{pager}->{total_entries} > 0 ){
      my $doc = @{$it->{struct}}[0]->get_document();
        if($fill){
          return $self->_get_obj($c, $doc, $footer);
        }
        return $self->_pack_search_obj($c, $doc);
    }
  }
  my $tag =  { id => $id,
           class => $class
  };
  $tag = { name => $tag, footer => $footer } if $fill;
  return $tag;
}

# why is species sometimes getting stored weird in xapian? 
# eg. c_caenorhabditis_elegans instead of c_elegans
sub _get_taxonomy {
  my ($self, $doc) = @_;
  my $taxonomy = $doc->get_value(5);
  $taxonomy =~ s/_([^_]*)_/\_/g;
  return $taxonomy;
}

sub _pack_search_obj {
  my ($self, $c, $doc, $label) = @_;
  my $id = $doc->get_value(1);
  my $class = $doc->get_value(2);
  $class = $self->modelmap->ACE2WB_MAP->{class}->{$class} || $self->modelmap->ACE2WB_MAP->{fullclass}->{$class};
  return {  id => $id,
            label => $label || $doc->get_value(6) || $id,
            class => lc($class),
            taxonomy => $self->_get_taxonomy($doc),
            coord => { start => $doc->get_value(9),
                       end => $doc->get_value(10),
                       strand => $doc->get_value(11)}
  }
}

sub _add_type_range {
  my ($self, $c, $q, $type) = @_;
  if( $type ){
      my $aceclass = $self->modelmap->WB2ACE_MAP->{class}->{ucfirst($type)}
                || $self->modelmap->WB2ACE_MAP->{fullclass}->{ucfirst($type)};
      my %classes = map { $_ => undef } ref($aceclass) eq 'ARRAY' ? map {lc($_)} @{$aceclass} : ($type);
      foreach my $t (keys %classes){
        $q .= " $t..$t";
      }
  }
  return $q;
}

sub _uniquify {
  my ($self, $q, $type) = @_;
  $q =~ s/\W/_/g;
  return "$type$q";
}

1;
