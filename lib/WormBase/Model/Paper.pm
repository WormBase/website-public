package WormBase::Model::Paper;

use strict;
use warnings;
use base 'WormBase::Model';

###########################################
# Generic References panel for any given object
###########################################

# This search isn't really all that robust...
sub search {
  my $self = shift;
  my $dbh = $self->dbh_ace;
  my ( $name, $class );
  #  $class ||= 'Gene';
  #  $name  ||= 'WBGene00006763';
  
  my @papers;
  
  if ($name =~ /^WBPaper/) {
    # First try fetching WBPaper IDs
    @papers = $dbh->fetch(-class =>'Paper',
			  -name  => $name,
			  #			  -fill  => 1
			 );
  } 
  
  unless (@papers) {
    # No?  Let's try fetching via Paper_name
    my @paper_names = $dbh->fetch(-class =>'Paper_name',
				  -name  => $name,
				  -fill  => 1
				 );
    my %seen;
    @papers = grep {!$seen{$_}}
      map {
	$_->CGC_name_for 
	  || $_->PMID_for
	    || $_->Medline_name_for
	      || $_->Meeting_abstract_name
		|| $_->WBG_abstract_name
		  || $_->Old_WBPaper_name
		    || $_->Other_name_for;
      } @paper_names;
  }
  
  # Okay. Two most direct approaches didn't work.  Try
  # other terms
  if ($class && !@papers) {
    # Keywords are treated specially because of Ace query language
    # deficiencies (bugs?)
    my $follow =
      $class =~ /keyword/i ? 'Quoted_in'
	: ( $class =~ /author/i || $class =~ /person/i ) ? 'Paper'
	  :                                                  'Reference';
    @papers = $dbh->find(
			 -query => qq{$class IS "$name" ; >$follow},
			 -fill  => 1
			);
    @papers = grep ( $_->class eq 'Paper', @papers )
      if $class =~ /keyword/i;
  }
  
  # Try searching by Person ID or Person_name
  unless (@papers) {
    @papers = $dbh->find( -query => qq{Person IS "$name" ; >Paper} );
    
    # not an author, try a Person_name
    my @temp =
      $dbh->find( -query => qq{find Person_name "$name"}, -fill => 1 );
    
    my %seen;
    push @papers, grep { !$seen{$_}++ } map { $_->Paper } map {
      $_->Full_name_of
	|| $_->Standard_name_of
	  || $_->Last_name_of
	    || $_->Other_name_of
	  } @temp if @temp;    
  }
  
  # BLECH
  unless (@papers) {
    # no type given.  Try fetching as a gene
    my $gene;
    #    my ( $gene, $best ) =
    #      $c->model('WormBase::Web::Model::Gene')->_fetch_gene($c);
    if ($gene) {
      @papers = eval { $gene->Reference };
    }
  }
  
  unless (@papers) {
    @papers = $dbh->find(
			 -query => qq{Clone IS "$name" ; >Reference},
			 -fill  => 1
			);
  }
  
  my @primary_papers;
  my %seen;
  foreach (@papers) {
    my $paper;
    if ($_->Merged_into) {
      $paper = $_->Merged_into;
    } else {
      $paper = $_;
    }
    
    push @primary_papers, grep {!$seen{$_}++ } $_;
  }
  return \@primary_papers;
}


# THIS SHOULD BE PART OF THE SEARCH VIEW
# 	  popup_menu(-name=>'category',
#		     -values=>[sort keys %bib_patterns],
#		     -labels=>\%bib_patterns,
#		     -onChange=>'document.form1.submit()')
#	 ),
#         end_form;




# This probably just needs to return the object
sub external_links_table {
  my $self = shift;
  my $object = $self->current_object;
  my $pmid = $object->PMID;
  my $cgc  = $object->CGC_name;
}







=head1 NAME

WormBase::Web::Model::Paper - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
