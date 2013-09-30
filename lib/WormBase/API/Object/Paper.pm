package WormBase::API::Object::Paper;

use Moose;
use WormBase::Util::ParseName qw(parse_name parse_name_initials);
use List::Util qw(first);

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# TODO:
#  build data tables for refers_to() ?
#  re-evaluate cruft (see cruft section below); consider deletion

=pod

=head1 NAME

WormBase::API::Object::Paper

=head1 SYNPOSIS

Model for the Ace ?Paper class.

=head1 URL

http://wormbase.org/resources/paper

=cut

has '_authors' => (
	is => 'ro',
	isa => 'ArrayRef[Ace::Object]',
	lazy => 1,
	default => sub {
		my ($self) = @_;
		return $self ~~ '@Author';
	},
);

has '_parsed_authors' => (
	is => 'ro',
	isa => 'HashRef[ArrayRef]',
	lazy => 1,
	default => sub {
		my ($self) = @_;
		return {map {$_ => [parse_name_initials($_)]} @{$self->_authors}};
	},
);


#######################################
#
# CLASS METHODS
#
#######################################

#######################################
#
# INSTANCE METHODS
#
#######################################

#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

sub _build__common_name {
    my ($self) = @_;
    return $self->intext_citation->{data}{citation} // $self->object->name;
}

# title { }
# This method will return a data structure containing
# the title of the paper.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/title

sub title {
    my ($self) = @_;
    my $title = $self ~~ 'Title' // $self ~~ 'name'; # always defined
    $title =~ s/\.*$//;
    return {
        description	=> 'The title of the publication',
        data		=> $title,
    };
}


# journal { }
# This method will return a data structure containing
# the journal the paper was published in, if appropriate.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/journal

sub journal {
    my ($self) = @_;
    my $journal = $self ~~ 'Journal';
    $journal =~ s/\.*$// if $journal;
    return {
        description => 'The journal the paper was published in',
        data        => $journal,
    };
}

# pages { }
# This method will return a data structure containing
# the page range of the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/pages

sub pages {
    my ($self) = @_;
    my $page = $self ~~ 'Page';
    $page =~ s/\.*$// if $page; # stringified if defined
    return {
        description => 'The pages of the publication',
        data        => $page ? "$page" : undef,
    };
}

# volume { }
# This method will return a data structure containing
# the volume of the paper the journal was published in.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/volume

sub volume {
    my ($self) = @_;
    my $volume = $self ~~ 'Volume';
    $volume =~ s/\.*$// if $volume;
    return {
        description => 'The volume the paper was published in',
        data        => $volume,
    };
}

# year { }
# This method will return a data structure containing
# the year of publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/year

sub year {
    my ($self) = @_;
    (my $date = $self ~~ 'Publication_date' || 'n.d') =~ /(\d{4})/;
    return {
        description => 'The year of publication',
        data        =>  $1 || $date,
    };
}

# publication_date { }
# This method will return a data structure containing
# the date the paper was published.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/publication_date

sub publication_date {
    my ($self) = @_;
    return {
        description => 'The publication date of the publication',
        data		=> $self ~~ 'Publication_date',
    };
}

# authors { }
# This method will return a data structure containing
# the authors of the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/authors

sub authors {
    my ($self) = @_;

    my @authors;
    foreach my $author (@{$self->_authors}) {
        my $obj = $author;
        foreach my $col ($author->col) {
            $obj = $col->right if $col eq 'Person';
        }

        my @authorname = @{$self->_parsed_authors->{$author}};
        my $label = @authorname > 1 ?
	    "$authorname[-1], " . join('. ', @authorname[0..$#authorname-1]) . '.' :
	    $authorname[0];         # author's name in APA format

        push @authors, $self->_pack_obj($obj, $label);
    }

    return {
        description => 'The authors of the publication',
        data        => @authors ? \@authors : undef,
    };
}

# editors { }
# This method will return a data structure containing
# the editors of the publication, if any.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/editors

sub editors {
    my ($self) = @_;
    my $editors = $self ~~ '@Editor';

    unless ($self->is_wormbook_paper->{data}) {
        $editors = [map {@$_ > 1 ? $_->[-1] . ', ' . join('. ', $_->[0..$#_-1]) . '.'
                         : $_->[0]} map [parse_name_initials($_)], @$editors];
    }

    return {
        description => 'Editor of publication',
        data		=> @$editors ? $editors : undef,
    };
}

# publication_type { }
# This method will return a data structure containing
# the type of publication, eg "Book Chapter".
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/publication_type

sub publication_type {
    my ($self) = @_;
    my @type = map {$_->name} @{$self ~~ '@Type'};

    return {
        description => 'Type of publication',
        data		=> @type ? \@type : undef,
    };
}

# is_wormbook_paper { }
# This method will return a data structure containing
# whether or not this publication came from WormBook.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/is_wormbook_paper

sub is_wormbook_paper {
    my ($self) = @_;
    my $truth = 0;

    my ($type, $journal, $contained);
    if (($type = $self->publication_type and first { $_ eq 'WormBook' } @{$type->{data}})
        or ($journal = $self->journal and $journal->{data} eq 'WormBook')
        or ($contained = $self->contained_in and first {/WormBook/} @{$contained->{data}})) {
        $truth = 1;
    }

    return {
        description => 'Whether this is a publication in the WormBook',
        data	    => $truth,
    };
}

# abstract { }
# This method will return a data structure containing
# the abstract for the publication, if available.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/abstract

sub abstract {
    my ($self) = @_;

    my $abs;
    if ($abs = $self ~~ 'Abstract') {
        $abs =	 $abs->right;
        $abs =~ s/^\n+//;
        $abs =~ s/\n+$//;
    }

    return {
        description => 'The abstract of the publication',
        data        => $abs && "$abs",
    };
}

# remarks {}
# Supplied by Role

# keywords { }
# This method will return a data structure containing
# keywords associated with the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/keywords

sub keywords {
    my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Keyword');
    return {
        description => 'Keywords related to the publication',
        data	    => %$data ? $data : undef,
    };
}


# publisher { }
# This method will return a data structure containing
# the publisher of the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/publisher

# Considerations: publisher should be in format "Location: Publisher"
#                 for APA citations. Consider parsing $self ~~ 'Publisher'
#                 and returning "Location, Publisher" -- this may be harder
#                 than parsing a name! :(
sub publisher {
	my ($self) = @_;
    my $publisher = $self ~~ 'Publisher';

	return {
		description => 'Publisher of the publication',
		data		=> $publisher && "$publisher",
	};
}

# affiliation { }
# This method will return a data structure containing
# the affiliations of the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/affiliation

sub affiliation {
    my ($self) = @_;

    my @affiliations = map { "$_" } $self->object->Affiliation;
    return {
        description => 'Affiliations of the publication',
        data => @affiliations ? \@affiliations : undef,
    };
}

# doi { }
# This method will return a data structure containing
# the DOI of the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/doi

sub doi {
    my ($self) = @_;

    ($self ~~ 'Name') =~ m{^(?:doi.*)?(10\.[^/]+.+)$};
    return {
        description => 'DOI of publication',
        data		=> $1,
    };
}

# pmid { }
# This method will return a data structure containing
# the Pubmed ID of the publication.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/pmid

sub pmid {
    my ($self) = @_;

    my $pmid;
    foreach ($self->object->Database(2)) {
        if ($_ == 'PMID') {
            $pmid = $_->right->name;
            last;
        }
    }

    return {
        description => 'PubMed ID of publication',
        data        => $pmid // "$pmid",
    };
}


# history { }
# This method will return a data structure containing
# the history of the paper
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/history

sub history {
    my $self   = shift;
    my $object = $self->object;
    my @data;

    foreach my $action ('Merged_into', 'Acquires_merge') {
      (my $a = $action) =~ s/_/ /;
      push @data, map {
        { action  => $a,
        remark    => $self->_pack_obj($_)}
      } $object->$action;
    }

    return {
        description => 'the curatorial history of the gene',
        data        => @data ? \@data : undef
    };
}


# merged_into { }
# This method will return the paper this paper has been merged into
# if the paper has been merged
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/merged_into

sub merged_into {
    my $self   = shift;
    my $paper = $self->object->Merged_into;

    return {
        description => 'the curatorial history of the gene',
        data        => $paper ? $self->_pack_obj($paper) : undef
    };
}


# intext_citation { }
# This method will return a data structure containing
# an APA-formatted in-text (i.e. parenthetical) citation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/intext_citation

sub intext_citation {
    my ($self) = @_;

    my $authors = $self->_authors;
    my $year = eval {$self->year->{data}};

    my $innertext;
    if (@$authors > 5) {        # 6..inf
        my $author = $authors->[0]; # will be author or person object
        $innertext = $self->_parsed_authors->{$author}->[-1] . ' et al.';
    }
    elsif (@$authors) {
        if (@$authors > 2) {    # 3..5
            my @lnames = map {$self->_parsed_authors->{$_}->[-1]} @$authors;
            $innertext = join(', ', @lnames[0..$#lnames-1]) . ', & ' . $lnames[-1];
        }
        else {
            $innertext = join(' & ', map {$self->_parsed_authors->{$_}->[-1]} @$authors);
        }
    }

    $innertext = "$innertext, $year" if $innertext && defined $year;

    return {
        description => 'APA in-text citation',
        data		=> {
            citation => "$innertext",
            paper	 => $self ~~ 'name',
        },
    };
}

# contained_in { }
# This method will return a data structure containing
# publications the current publication is contained in.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/contained_in

sub contained_in {
    my ($self) = @_;
    my $contained_in = $self ~~ '@Contained_in';

    return {
        description => 'Publications this publication is contained in',
        data		=> @$contained_in ? $contained_in : undef,
    };
}

#######################################
#
# The Referenced Widget
#
#######################################

# refers_to { }
# This method will return a data structure containing
# items that the publication refers to.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/paper/WBPaper00000031/refers_to

sub refers_to {
    my ($self) = @_;
    my %data;
    foreach my $ref_type ($self->object->Refers_to) {
      # modified to just get count - breaking on large amounts of xrefs - AC
      $data{$ref_type} = $self->_get_count($self->object, $ref_type);

      $data{$ref_type} = $self->_pack_objects([$ref_type->col]) if $data{$ref_type} < 10000;
        # Or build some data tables for different object types
        #	foreach $ref_type ($ref_type->col) {
        #	    if ($ref_type eq '') {
        #		# ...
        #	    }
        #	}
    }

    return {
        description => 'Items that the publication refers to',
        data		=> %data ? \%data : undef,
    };
}



############################################################
#
# The External Links widget
#
############################################################

# xrefs {}
# Supplied by Role


#######################################
#
# This may all just be cruft; handled by refers_to above.
#
#######################################

sub genes {
    my ($self) = @_;

    return {
        description => 'Genes referenced by the paper',
        data		=> $self->_pack_objects($self ~~ '@Gene'),
    };
}

sub alleles {
    my ($self) = @_;

    return {
        description => 'Alleles referenced by the paper',
        data		=> $self->_pack_objects($self ~~ '@Allele'),
    };
}

sub interactions {
    my ($self) = @_;

    return {
        description => 'Interactions referenced by the paper',
        data => $self->_pack_objects($self ~~ '@Interaction'),
    };
}

sub strains {
    my ($self) = @_;

    return {
        description => 'Strains referenced by the paper',
        data 		=> $self->_pack_objects($self ~~ '@Strain'),
    };
}

############################################################
#
# PRIVATE METHODS
#
############################################################

__PACKAGE__->meta->make_immutable;

1;


