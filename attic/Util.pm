package WormBase::Web::View::Template::Plugin::Util;

# This is still used in a few places
# config/.svn/text-base/main.svn-base:      data = util.parse_hash(object);
#config/main:      data = util.parse_hash(object);
#paper/.svn/text-base/format_paper.tt2.svn-base:    [% results = util.parse_hash(paper.In_book) %]    
#paper/format_paper.tt2:    [% results = util.parse_hash(paper.In_book) %] 

use strict;
use CGI qw/:standard/;
use Template::Plugin;
use Template::Stash;
#use lib '/usr/local/wormbase/cgi-perl/lib/WormBase/Util';
#use WormBase::Web::Util::Rearrange;
use base qw/WormBase::Web::View::TT/;


sub load {
  my ($class,$context,@params) = @_;
  my $self = bless {
		    _CONTEXT => $context,
		    _PARAMS  => \@params,
		   },$class;
  my $stash = $context->stash;
  return $self;
}

sub new {
  my ($self,$context) = @_;
  return $self;
}


=item parse_hash($node)

Generically parse an Acedb hash (be it evidence, molecular_info, interaction)
from a provided node of an object tree.  Really, this just checks for the
presence of a hash to the right of any node and flattens it into a Perl hash.

Options

 -node  A node of an object tree

Returns

 A hash reference suitable for display and further parsing or null
 if no hash is found.

=cut

sub parse_hash {
  my ($self,$node) = @_;

  # Collect all the hashes for this node
  # Save all the top level tags as keys in a perl
  # hash for easier parsing and formatting
  my %hash = map { $_ => $_ } eval { $node->col };

  # Previously, I also returned a boolean if this
  # hash contained the Not negation.

  return \%hash;
}



# Convert a sequence into FASTA
# I'm not sure if this should really be solely a part of the View
sub fasta {
  my ($self,$name,$sequence,$skip_spaces) = @_;
  $sequence ||= '';
  my @markup;
  for (my $i=0; $i < length $sequence; $i += 10) {
    if ($skip_spaces) {
      # Don't add markup for flanking sequences
      push (@markup,[$i,$i % 80 ? '' : "\n"]);
    } else {	
      push (@markup,[$i,$i % 80 ? ' ':"\n"]);
    }
  }
  
  markup(\$sequence,\@markup);
  return ">$name<br>$sequence";
}

# insert HTML tags into a string without disturbing order
sub markup {	
  my $string = shift;
  my $markups = shift;
  for my $m (sort {$b->[0]<=>$a->[0]} @$markups) { #insert later tags first so position remains correct
    my ($position,$markup) = @$m;
    next unless $position <= length $$string;
    substr($$string,$position,0) = $markup;
  }
}


1;
