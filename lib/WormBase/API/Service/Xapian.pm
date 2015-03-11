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

# Xapian search flags
#  FLAG_BOOLEAN = 1, FLAG_PHRASE = 2, FLAG_LOVEHATE = 4, FLAG_BOOLEAN_ANY_CASE = 8,
#  FLAG_WILDCARD = 16, FLAG_PURE_NOT = 32, FLAG_PARTIAL = 64, FLAG_SPELLING_CORRECTION = 128,
#  FLAG_SYNONYM = 256, FLAG_AUTO_SYNONYMS = 512, FLAG_AUTO_MULTIWORD_SYNONYMS = 1024 | FLAG_AUTO_SYNONYMS, FLAG_DEFAULT = FLAG_PHRASE|FLAG_BOOLEAN|FLAG_LOVEHATE

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

# Main search - returns a page of results
sub search {
    my ( $class, $args) = @_;

    my $q = $args->{query};
    my $page = $args->{page} || 1;
    my $type = $args->{type};
    my $species = $args->{species};
    my $page_size = $args->{page_size} || 10;

    my $t=[gettimeofday];
    my $count = $class->count_estimate($q, $type, $species);

#    my $stemmer = Search::Xapian::Stem->new('english');
#    $q = $stemmer->stem_word($q) unless $q =~ /[\/\@\<\>\=\*[\{\:]/;

    if($page eq 'all'){
      $page_size = $class->_doccount;
      $page = 1;
    }

    if($type){
      $q = $class->_add_type_range($q, $type);
      if(($type =~ m/paper/) && ($species)){
        my $s = $class->_api->config->{sections}->{resources}->{paper}->{paper_types}->{$species};
        $q .= " ptype:$s..$s" if defined $s;
        $species = undef;
      }
    }

    if($species){
        my $s = $class->_api->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s" if defined $s;
    }

    my ($query, $error) =$class->_setup_query($q, $class->qp, 1|2|512|16);
    my $enq       = $class->db->enquire ( $query );

    if($type && $type =~ /paper/){
          $enq->set_sort_by_value(4);
    }

    my $check_at_least_matches = 500;
    $check_at_least_matches = $count if $count < $check_at_least_matches;
    # coincidentally, $count is exact when < 500, no need to look further for potential matches
    my @mset      = $enq->matches( ($page-1)*$page_size,
                                     $page_size, $check_at_least_matches );

    my ($time)=tv_interval($t) =~ m/^(\d+\.\d{0,2})/;

    @mset = map { $class->_get_obj($_->get_document ) } @mset;

    return ({ matches=>\@mset,
              search=>$class,
              query=>$q,
              query_obj=>$query,
              querytime=>$time,
              page=>$page,
              count=>$count,
              page_size=>$page_size }, $error);
}

# Autocomplete - returns 10 results
sub autocomplete {
    my ( $class, $q, $type) = @_;
    $q = $class->_add_type_range($q . "*", $type);

    my $query=$class->_setup_query($q, $class->syn_qp,64|16);
    my $enq       = $class->syn_db->enquire ( $query );
    my @mset      = $enq->matches( 0, 10 );

    unless($mset[0]){
      $query=$class->_setup_query($q, $class->qp,64|16);
      $enq       = $class->db->enquire ( $query );
      @mset      = $enq->matches( 0, 10 );
    }
    @mset = map { $class->_pack_search_obj($_->get_document ) } @mset;

    return ({ struct=>\@mset,
              search=>$class,
              query=>$q,
              query_obj=>$query,
              page=>1,
              page_size=>10 });
}



# This will fetch the object from Xapian and return a hashref containing the id, label and class (similar to _pack_obj)
# label - return the correct label (important for protein and interaction)
#       - default returns the label stored in Xapian
# fill - return more than just the name tag, all info from search results included
# footer - if a filled tag is returns, will insert this info as a footer

sub fetch {
  my ($self, $args) = @_;
  my $fill = $args->{fill};
  my $footer = $args->{footer};
  my $label = $args->{label};

  return ($fill || $footer || $label) ? $self->_get_tag_info($args) : $self->_search_exact($args);
}

# Returns a random filled object from the database

sub random {
    my ( $class) = @_;
    return $class->_get_obj($class->db->get_document(int(rand($class->_doccount)) + 1));
}

# Estimates the search results amount - accurate up to 500

sub count_estimate {
 my ( $class, $q, $type, $species) = @_;

    if($type){
      $q = $class->_add_type_range($q, $type);

      if(($type =~ m/paper/) && ($species)){
        my $s = $class->_api->config->{sections}->{resources}->{paper}->{paper_types}->{$species};
        $q .= " ptype:$s..$s" if defined $s;
        $species = undef;
      }
    }

    if($species){
        my $s = $class->_api->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s" if defined $s;
    }

    my $query=$class->_setup_query($q, $class->qp, 1|2|512|16);
    my $enq       = $class->db->enquire ( $query );

    my $mset      = $enq->get_mset( 0, 0, 500 );

    my $amt = $mset->get_matches_estimated();
    return $amt;
}

sub _search_exact {
    my ($class, $args) = @_;
    my $q = $args->{query} || $args->{id};
    $q =~ s/\*//g;  # exact match, be conservative, no wild card guessing
    my $type = $args->{class};
    my $species = $args->{species};
    my $doc = $args->{doc};

    my ($query, $enq, @mset);
    if( $type ){
      # exact match using type/query - will only work if query is the WBObjID
      $q =~ s/\"//g;
      $query=$class->_setup_query("\"$type$q\" $type..$type", $class->qp,1|2);
      $enq       = $class->db->enquire ( $query );
      @mset = $enq->matches( 0,1 ) if $enq;

      if (!$mset[0]){
        $query=$class->_setup_query($class->_uniquify($q, $type) . " $type..$type", $class->qp,1|2);
        $query = $class->_add_species($query, $species) if $species;
        $enq       = $class->db->enquire ( $query );
        @mset = $enq->matches( 0,1 ) if $enq;
      }

      # reset if top result is not the exact query
      @mset = () unless $mset[0] && $class->_check_exact_match($q, $mset[0]->get_document);

    }

    # phrase search in the synonym database
    if((!$mset[0] || $q =~ m/\s/) && (!($q =~ m/^\s.*\s$/))){
        my $qu = "$q";
        $qu = "\"$qu\"" if(($qu =~ m/\s/) && !($qu =~ m/_/) && !($qu =~ m/\"/));
        $qu = $class->_add_type_range("$qu", $type);
        $qu = $class->_add_species($qu, $species) if $species;
        $query=$class->_setup_query($qu, $class->syn_qp, 1|2|16|512);
        $enq       = $class->syn_db->enquire ( $query );
        @mset      = $enq->matches( 0,10 ) if $enq;

        # reset if top result is not the exact query
        @mset = () unless $mset[0] && $class->_check_exact_match($q, $mset[0]->get_document);
    }

    # search main database
    if(!$mset[0]){

      my $qu = "$q";
      $qu = "\"$qu\"" if(($qu =~ m/\s/) && !($qu =~ m/_/) && !($qu =~ m/\"/));
      $qu = $class->_add_type_range("$qu", $type);
      $qu = $class->_add_species($qu, $species) if $species;
      $query=$class->_setup_query($qu, $class->qp, 1|2|512|16);
      $enq       = $class->db->enquire ( $query );
      @mset      = $enq->matches( 0,10 );

      my $is_exact_match;
      if($mset[0]){
          # scores 100% with the query, and 40 in actual score
          # to scores 40, takes a synonym match of Wbid, OR a long phrase
          # Can't think of a better way, without re-index with prefixed terms
          $is_exact_match = $is_exact_match =
              ($mset[0]->get_weight() >= 40) && ($mset[0]->get_percent() == 100);

          #convention check for exact match
          $is_exact_match ||= $class->_check_exact_match($q, $mset[0]->get_document);
      }

      # reset if top result is not the exact query
      @mset = () unless $is_exact_match;
    }

    if($mset[0]){
      my $d = $mset[0]->get_document;
      return $doc ? $d : $class->_pack_search_obj($d);
    }

}

# Note: synonyms of Wbids fails this check, has to be handled separately
sub _check_exact_match {
  my ($class, $q, $doc) = @_;

  my $label = $doc->get_value(6);
  my $id = $doc->get_value(1);

  return (($q =~ m/\Q$label\E/i) || ($q =~ m/\Q$id\E/i));
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
  my ($self, $doc, $footer) = @_;

  my %ret;
  $ret{name} = $self->_pack_search_obj($doc);
  my $species = $ret{name}{taxonomy};
  if($species =~ m/^(.*)_([^_]*)$/){
    my $s = $self->_api->config->{sections}{species_list}{$species};
    $ret{taxonomy}{genus} = $s->{genus} || ucfirst($1);
    $ret{taxonomy}{species} = $s->{species} || $2;
  }
  $ret{ptype} = $doc->get_value(7) if $doc->get_value(7);
  %ret = %{$self->_split_fields(\%ret, uri_unescape($doc->get_data()))};
  if($doc->get_value(4) =~ m/^(\d{4})/){
    $ret{year} = $1;
  }

  $ret{footer} = $footer if $footer;
  return \%ret;
}

sub _split_fields {
  my ($self, $ret, $data) = @_;

  $data =~ s/\\([\;\/\\%\"])/$1/g;
  while($data =~ m/^([^=\s]*)[=](.*)[\n]([\s\S]*)$/){
    my ($d, $label) = ($2, $1);
    my $array = $ret->{$label} || ();
    $data = $3;

    if($d =~ m/^WB/){
      my $class = $self->modelmap->WB2ACE_MAP->{class}->{ucfirst($label)} ?
          $label : undef;
      $d = $self->_get_tag_info({id => $d, class => $class });
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
  my ($self, $args) = @_;

  my $id = $args->{id} || $args->{query};
  my $class = $args->{class};
  my $fill = $args->{fill};
  my $footer = $args->{footer};
  my $aceclass = $args->{aceclass};
  my $tag;

  if ($class) { # WB class was provided
      $aceclass = $self->modelmap->WB2ACE_MAP->{class}->{ucfirst($class)}
                || $self->modelmap->WB2ACE_MAP->{fullclass}->{ucfirst($class)};
      $aceclass = $class unless $aceclass;
  }
  if(!$class || (($class ne 'protein') && ($class ne 'interaction'))){ # this is a hack to deal with the Protein labels
                           # we can remove this if Protein?Gene_name is updated to
                           # contain the display name for the protein
    if (ref $aceclass eq 'ARRAY') { # multiple Ace classes
      foreach my $ace (@$aceclass) {
        my $doc = $self->_search_exact({query => $id, class => lc($ace), doc => 1});
        if($doc){
          return $self->_get_obj($doc, $footer) if $fill;

          my $ret = $self->_pack_search_obj($doc);
          $ret->{class} = $class;
          return $ret;
        }
      }
    }else{
      my $doc = $self->_search_exact({query => $id, class => $aceclass ? lc($aceclass) : undef, doc => 1 });
      return ($fill ? $self->_get_obj($doc, $footer) : $self->_pack_search_obj($doc)) if $doc;
    }
  }else{
    my $object = $self->_api->fetch({ class => ucfirst $class, name => $id });
    $tag = $object->name->{data} if ($object > 0);
  }

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
  my ($self, $doc, $label) = @_;
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
  my ($self, $q, $type) = @_;
  if( $type ){
      my $aceclass = $self->modelmap->WB2ACE_MAP->{class}->{ucfirst($type)}
                || $self->modelmap->WB2ACE_MAP->{fullclass}->{ucfirst($type)};
      my %classes = map { $_ => undef } ref($aceclass) eq 'ARRAY' ? map {lc($_)} @{$aceclass} : (lc($aceclass));
      foreach my $t (keys %classes){
        $q .= " $t..$t";
      }
  }
  return $q;
}

sub _add_species {
    my ($class, $q, $species) = @_;
    if($species){
        my $s = $class->_api->config->{sections}->{species_list}->{$species}->{ncbi_taxonomy_id};
        $q .= " species:$s..$s" if defined $s;
    }
    return $q;
}

sub _uniquify {
  my ($self, $q, $type) = @_;
  $q =~ s/\W/_/g;
  return "$type$q";
}

1;
