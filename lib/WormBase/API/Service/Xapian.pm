package WormBase::API::Service::Xapian;

use base qw/Catalyst::Model/;
use Moose;

use strict;

use Encode qw/from_to/;
use Search::Xapian;
use Storable;
use MRO::Compat;
use Time::HiRes qw/gettimeofday tv_interval/;
use Config::General;
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

has '_api' => (
    is => 'ro',
);


sub search {
    my ( $class, $c, $q, $page, $type, $species, $page_size) = @_;
    my $t=[gettimeofday];
    $page       ||= 1;
    $page_size  ||=  10;
    $q =~ s/\s/\* /g;
    $q = "$q*";

    if($page eq 'all'){
      $page_size = $class->_doccount;
      $page = 1;
    }

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

    my ($query, $error) =$class->_setup_query($q, $class->qp, 2|512|16); 
    my $enq       = $class->db->enquire ( $query );

    if($type && $type =~ /paper/){
          $enq->set_sort_by_value(4);
    }
    my @mset      = $enq->matches( ($page-1)*$page_size,
                                     $page_size );

    my ($time)=tv_interval($t) =~ m/^(\d+\.\d{0,2})/;

    return ({ struct=>\@mset,
              search=>$class,
              query=>$q,
              query_obj=>$query,
              querytime=>$time,
              page=>$page,
              page_size=>$page_size }, $error);
}

sub search_autocomplete {
    my ( $class, $c, $q, $type) = @_;
    $q = $class->_add_type_range($c, $q . "*", $type);

    my $query=$class->_setup_query($q, $class->syn_qp,64|16);
    my $enq       = $class->syn_db->enquire ( $query );
    my @mset      = $enq->matches( 0, 10 );

    if($mset[0]){
      $query=$class->_setup_query($q, $class->qp,64|16);
      $enq       = $class->db->enquire ( $query );
      @mset      = $enq->matches( 0, 10 );
    }

    return ({ struct=>\@mset,
              search=>$class,
              query=>$q,
              query_obj=>$query,
              page=>1,
              page_size=>10 });
}

sub search_exact {
    my ($class, $c, $q, $type) = @_;
    my ($query, $enq, @mset);
    if( $type ){
      $query=$class->_setup_query("\"$type$q\" $type..$type", $class->qp,1|2);
      $enq       = $class->db->enquire ( $query );
      @mset = $enq->matches( 0,2 ) if $enq;

      if (!$mset[0]){
        $query=$class->_setup_query($class->_uniquify($q, $type) . "* $type..$type", $class->qp,1|2);
        $enq       = $class->db->enquire ( $query );
        @mset = $enq->matches( 0,2 ) if $enq;
      }
      @mset = undef if (@mset != 1);
    }

    if((!$mset[0] || $q =~ m/\s/) && (!($q =~ m/\s.*\s/))){
        my $qu = "$q";
        $qu = "\"$qu\"" if(($qu =~ m/\s/) && !($qu =~ m/_/));
        $qu = $class->_add_type_range($c, "$qu", $type);
        $query=$class->_setup_query($qu, $class->syn_qp,16|2|256);
        $enq       = $class->syn_db->enquire ( $query );
        @mset      = $enq->matches( 0,2 ) if $enq;
    }

    if(!$mset[0]){
      $q = "\"$q\"" if(($q =~ m/\s/) && !($q =~ m/_/));
      $q =~ s/\s/\* /g;
      $q = $class->_add_type_range($c, "$q", $type);
      $query=$class->_setup_query($q, $class->qp, 2|16|256|512);
      $enq       = $class->db->enquire ( $query );
      @mset      = $enq->matches( 0,2 );
    }

    return ({ struct=>\@mset,
              search=>$class,
              query=>$q,
              query_obj=>$query,
              page=>1,
              page_size=>1 });
}

sub random {
    my ( $class, $c) = @_;
    return $class->_get_obj($c, $class->db->get_document(int(rand($class->_doccount)) + 1));
}

sub search_count_estimate {
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

    my $query=$class->_setup_query($q, $class->qp, 2|512|16);
    my $enq       = $class->db->enquire ( $query );

    my $mset      = $enq->get_mset( 0, 0, 500 );

    my $amt = $mset->get_matches_estimated();
    # $amt = ($amt > 500) ? "500+" : "$amt";
    return $amt;
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
  while($data =~ m/^([^=\s]*)[=](.*)[\n]([\s\S]*)$/){
    my ($d, $label) = ($2, $1);
    my $array = $ret->{$label} || ();
    $data = $3;
    
    if($d =~ m/^WB/){
      $d = $self->_get_tag_info($c, $d, $self->modelmap->WB2ACE_MAP->{$label} ? $label : undef);
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
  if(!$class || ($class ne 'protein')){ # this is a hack to deal with the Protein labels
                           # we can remove this if Protein?Gene_name is updated to 
                           # contain the display name for the protein
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
      my ($it,$res)= $self->search_exact($c, $id, $aceclass ? lc($aceclass) : undef);
      if($it->{pager}->{total_entries} > 0 ){
        my $doc = @{$it->{struct}}[0]->get_document();
          if($fill){
            return $self->_get_obj($c, $doc, $footer);
          }
          return $self->_pack_search_obj($c, $doc);
      }
    }
  }

  my $api = $self->_api;
  my $object = $api->fetch({ class => ucfirst $class, name => $id });
  my $tag = $object->name->{data} if ($object > 0);

  $tag =  { id => $id,
           class => $class
  } unless $tag;
  $tag = { name => $tag, footer => $footer } if $fill;
  return $tag;
}

# why is species sometimes getting stored weird in xapian? 
# eg. c_caenorhabditis_elegans instead of c_elegans
#
# Snips of possible BioProject suffix. For example,
# 'c_elegans_PRJNA13758' becomes 'c_elegans'. This
# is (probably) the right behaviour for this sub.
sub _get_taxonomy {
  my ($self, $doc) = @_;
  my $taxonomy = $doc->get_value(5);
  $taxonomy =~ s/_([^_]*)_/\_/g;
  return $taxonomy;
}

sub _setup_query {
  my($self, $q, $qp, $opts) = @_;
  my $error;

  my $query=$qp->parse_query( $q, $opts );

  if($query->get_length() > 1000){
    $query = $qp->parse_query($q);
    $error .= "Query too large: wildcard, synonym and phrase search disabled. Please try a more specific search term.";
  }
  return wantarray ? ($query, $error) : $query;
}

sub _pack_search_obj {
  my ($self, $c, $doc, $label) = @_;
  my $id = $doc->get_value(1);
  my $class = $doc->get_value(2);
  $class = $self->modelmap->ACE2WB_MAP->{class}->{$class} || $self->modelmap->ACE2WB_MAP->{fullclass}->{$class};
  $label ||= $doc->get_value(6) || $id;
  $label =~ s/\\(.)/$1/g;
  return {  id => $id,
            label => $label,
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
