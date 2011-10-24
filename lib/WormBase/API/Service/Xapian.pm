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

has '_fields'   => (
    is          => 'rw',
    isa         => 'HashRef',
    default     => sub { {} },
    );


sub search {
    my ( $class, $c, $q, $page, $type, $species, $page_size) = @_;
    my $t=[gettimeofday];
    $page       ||= 1;
    $page_size  ||=  10;

    if($type){
      if(($type =~ m/paper/) && ($species)){
        my $s = $c->config->{sections}->{resources}->{paper}->{paper_types}->{$species};
        $q .= " $type..$type ptype:$s..$s";
        $species = undef;
      }else{
        $q .= " $type..$type";
      }
    }

    if($species){
        my $s = $c->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s";
    }

    my $query=$class->qp->parse_query( $q, 512|16 );

    my $enq       = $class->db->enquire ( $query );
    $c->log->debug("query:" . $query->get_description());
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

    if($type){
      $q .= "* $type..$type";
    }

    my $query=$class->syn_qp->parse_query( $q, 64|16 );
    my $enq       = $class->syn_db->enquire ( $query );
    $c->log->debug("query:" . $query->get_description());
    my $mset      = $enq->get_mset( 0, 10 );

    if($mset->empty()){
      $query=$class->qp->parse_query( $q, 64|16 );
      $enq       = $class->db->enquire ( $query );
      $c->log->debug("query2:" . $query->get_description());
      $mset      = $enq->get_mset( 0, 10 );
    }

    return Catalyst::Model::Xapian::Result->new({ mset=>$mset,
        search=>$class,query=>$q,query_obj=>$query,page=>1,page_size=>10 });
}

sub search_exact {
    my ( $class, $c, $q, $type) = @_;
  
    my ($query, $enq);
    if( $q =~ m/^WB/i ){
      $q = "$type$q" if $type;
      $query=$class->qp->parse_query( $q, 1|2 );
      $enq       = $class->db->enquire ( $query );
    }else{
      $q .= " $type..$type" if $type;
      $query=$class->syn_qp->parse_query( $q, 1|2 );
      $enq       = $class->syn_db->enquire ( $query );
    }

    my $mset      = $enq->get_mset( 0,1 );

    return Catalyst::Model::Xapian::Result->new({ mset=>$mset,
        search=>$class,query=>$q,query_obj=>$query,page=>1,page_size=>1 });
}

sub search_count {
 my ( $class, $c, $q, $type, $species) = @_;

    if($type){
      if(($type =~ m/paper/) && ($species)){
        my $s = $c->config->{sections}->{resources}->{paper}->{paper_types}->{$species};
        $q .= " $type..$type ptype:$s..$s";
        $species = undef;
      }else{
        $q .= " $type..$type";
      }
    }

    if($species){
        my $s = $c->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s";
    }

    my $query=$class->qp->parse_query( $q, 512|16 );
    my $enq       = $class->db->enquire ( $query );
    $c->log->debug("query:" . $query->get_description());

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



# input: list of ace objects
# output: list of Result objects
sub _wrap_objs {
  my $self  = shift;
  my $c = shift;
  my $object  = shift;
  my $class = shift;
  my $footer = shift;

  my $api = $c->model('WormBaseAPI');
  my $fields = $self->_fields->{$class};

  return unless $object;

  unless($fields){
    my $f;
    if ( defined $c->config->{sections}{species}{$class}){
      $f = $c->config->{sections}->{species}->{$class}->{search}->{fields};
    } else{
      $f = $c->config->{sections}->{resources}->{$class}->{search}->{fields};
    }
    push(@$fields, @$f) if $f;
    $self->_fields->{$class} = $fields;
  }

  my %data;
  $data{obj_name}="$object";
  $data{footer} = $footer if $footer;
  foreach my $field (@$fields) {
    my $field_data = $object->$field;     # if  $object->meta->has_method($field); # Would be nice. Have to make sure config is good now.
    $field_data = $field_data->{data};
    $data{$field} = $field_data;
  }
  return \%data;
}




sub _get_obj {
  my ($self, $c, $api, $doc, $footer) = @_;
  my $species = $doc->get_value(5);

  $c->log->debug("class:" . $doc->get_value(0) . ", name:" . $doc->get_value(1));

  my %ret;
  $ret{name} = $self->_pack_search_obj($c, $doc);
  if(my $s = $c->config->{sections}->{species_list}->{$species}){
    $ret{taxonomy}{genus} = $s->{genus};
    $ret{taxonomy}{species} = $s->{species};
  }
    $ret{ptype} = $doc->get_value(7);
  %ret = %{$self->_split_fields($c, $api, \%ret, uri_unescape($doc->get_data()))};
  if($doc->get_value(4) =~ m/^(\d{4})/){
    $ret{year} = $1;
  }


  $ret{footer} = $footer if $footer;
  return \%ret;
}

sub _split_fields {
  my ($self, $c, $api, $ret, $data) = @_;

  $data =~ s/\\([\;\/\\%])/$1/g;
  while($data =~ m/^([\S]*)[=](.*)[\n]([\s\S]*)$/){
    my $d = $2;
    my $label = $1;
    $data = $3;
    
    my $array = $ret->{$label} || ();

    if($d =~ m/^WB/){
     $d = $self->_get_tag_info($c, $api, $d, $label);
    }elsif($label =~ m/^author$/){
      my $id = $d;
      my $l = $id;
      if($d =~ m/^(.*)\s(WBPerson\S*)$/){
        $id = $2;
        $l = $1;
      }
      $d = { id =>$id, 
             label=>$l,
             class=>'person'}
    }

    push(@{$array}, $d);
    $ret->{$label} = $array;
  }

  return $ret;
}

sub _get_tag_info {
  my ($self, $c, $api, $id, $class, $fill) = @_;
  my ($it,$res)= $self->search_exact($c, $id, $class);
  if($it->{pager}->{total_entries} > 0 ){
    my $doc = @{$it->{struct}}[0]->get_document();
    if($fill){
      return $self->_get_obj($c, $api, $doc);
    }
    return $self->_pack_search_obj($c, $doc);
  }
  my $tag =  { id => $id,
           label => $id,
           class => $class
  };
  $tag = { name => $tag } if $fill;
  return $tag;
}

sub _pack_search_obj {
  my ($self, $c, $doc, $label) = @_;
  my $id = $doc->get_value(1);
  return {  id => $id,
            label => $label || $doc->get_value(6) || $id,
            class => $doc->get_value(2),
            taxonomy => $doc->get_value(5)
  }
}


1;
