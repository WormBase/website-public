package WormBase::API::Object::Paper;

use Moose;
use ParseName qw(parse_name parse_name_initials);

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

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

#############
## METHODS
#############

sub name {
	my ($self) = @_;
    my $title = $self ~~ 'Title' // $self ~~ 'name';
    $title =~ s/\.*$//;
	return {
		description => 'The object name of the publication',
		data => {
			id		=> $self ~~ 'name',
			label	=> eval {$self->intext_citation->{data}{citation}} // $title,
			class	=> $self ~~ 'class',
		},
	};
}

sub title {
	my ($self) = @_;
    my $title = $self ~~ 'Title' // $self ~~ 'name';
    $title =~ s/\.*$//;
	return {
		description	=> 'The title of the publication',
		data		=> $title,
    };
}

sub journal {
	my ($self) = @_;
    my $journal = $self ~~ 'Journal';
    $journal =~ s/\.*$// if $journal;
	return {
		description => 'The journal the paper was published in',
		data        => $journal,
	};
}

sub page {
	my ($self) = @_;
    my $page = $self ~~ 'Page';
    $page =~ s/\.*$// if $page;
	return {
		description => 'The pages of the publication',
		data        => $page,
    };
}

sub volume {
	my ($self) = @_;
    my $volume = $self ~~ 'Volume';
    $volume =~ s/\.*$// if $volume;
	return {
		description => 'The volume the paper was published in',
		data        => $volume,
    };
}

sub year {
	my ($self) = @_;
	return {
		description => 'The year of publication',
		data        =>  $self->_parse_year($self ~~ 'Publication_date'),
    };
}

sub publication_date {
	my ($self) = @_;
	return {
		description => 'The publication date of the publication',
		data		=> $self ~~ 'Publication_date',
	};
}

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
			$authorname[0];		# author's name in APA format

		push @authors, $self->_pack_obj($obj, $label);
    }

	return {
		description => 'The authors of the publication',
		data        => @authors ? \@authors : undef,
	};
}

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

sub publication_type {
	my ($self) = @_;
	my @type = map {$_->name} @{$self ~~ '@Type'};

	return {
		description => 'Type of publication',
		data		=> @type ? \@type : undef,
	};
}

sub is_wormbook_paper {
	my ($self) = @_;
	my $description = 'Whether this is a publication in the WormBook';
	my $truth = 0;

	my ($type, $journal, $contained);
	if (($type = $self->publication_type and grep {$_ eq 'WormBook'} @{$type->{data}}) or
		($journal = $self->journal and $journal->{data} eq 'WormBook') or
		($contained = $self->contained_in and grep /WormBook/, @{$contained->{data}})) {
		$truth = 1;
	}

	return {
		description => $description,
		data		=> $truth,
	};
}

sub abstract {
	my ($self) = @_;
    my $abs = $self ~~ 'Abstract' // return;
    my $text;

    if ($abs =~ /^WBPaper/i ) {
		$text =	 $abs->right;
		$text =~ s/^\n+//;
		$text =~ s/\n+$//;
    }

	return {
		description => 'The abstract of the publication',
		data        => $text,
	};
}

sub remarks {
	my ($self) = @_;
	my $remarks = $self ~~ '@Remark' // return;

	return {
		description => 'Remarks regarding this publication',
		data		=> @$remarks ? $remarks : undef,
	};
}

sub keywords {
	my ($self) = @_;

	my $data = $self->_pack_objects($self ~~ '@Keyword');
	return {
		description => 'Keywords related to the publication',
		data		=> %$data ? $data : undef,
	};
}

# TODO: publisher should be in format "Location: Publisher"
#       for APA citations. Consider parsing $self ~~ 'Publisher'
#       and returning [Location, Publisher] -- this may be as hard
#       as parsing a name! :(
sub publisher {
	my ($self) = @_;

	return {
		description => 'Publisher of the publication',
		data		=> $self ~~ 'Publisher',
	};
}

sub affiliation {
	my ($self) = @_;

	my $affiliations = $self ~~ '@Affiliation';
	return {
		description => 'Affiliations of the publication',
		data => @$affiliations ? $affiliations : undef,
	};
}

sub doi {
	my ($self) = @_;

	($self ~~ 'Name') =~ m{^(?:doi.*)?(10\.[^/]+.+)$};
	return {
		description => 'DOI of publication',
		data		=> $1,
	};
}

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
		data => $pmid,
	};
}

sub intext_citation {
	my ($self) = @_;

	my $authors = $self->_authors;
	my $year = eval {$self->year->{data}};

	my $innertext;
	if (@$authors > 5) {					 # 6..inf
		my $author = $authors->[0]; # will be author or person object
		$innertext = $self->_parsed_authors->{$author}->[-1] . ' et al.';
	}
	elsif (@$authors) {
		if (@$authors > 2) {		# 3..5
			my @lnames = map {$self->_parsed_authors->{$_}->[-1]} @$authors;
			$innertext = join(', ', @lnames[0..$#lnames-1]) . ', & ' . $lnames[-1];
		}
		else {
			$innertext = join(' & ', map {$self->_parsed_authors->{$_}->[-1]} @$authors);
		}
	}

	$innertext = "($innertext, $year)" if $innertext && defined $year;

	return {
		description => 'APA in-text citation',
		data		=> {
			citation => $innertext,
			paper	 => $self ~~ 'name',
		},
	};
}

sub contained_in {
	my ($self) = @_;
	my $contained_in = $self ~~ '@Contained_in';

	return {
		description => 'Publications this publication is contained in',
		data		=> @$contained_in ? $contained_in : undef,
	};
}

sub refers_to {
	my ($self) = @_;

	my %data;
	foreach my $ref_type (@{$self ~~ '@Refers_to'}) {
		$data{$ref_type} = $self->_pack_objects([$ref_type->col]);
	}

	return {
		description => 'Items that the publication refers to',
		data		=> %data ? \%data : undef,
	};
}

sub genes {
	my ($self) = @_;

	return {
		description => 'Genes related to or mentioned in paper',
		data => $self->_pack_objects($self ~~ '@Gene'),
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

1;

