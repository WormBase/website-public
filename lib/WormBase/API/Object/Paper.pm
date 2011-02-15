package WormBase::API::Object::Paper;

use Moose;
use ParseName qw(parse_name parse_name_initials);

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
    my $self = shift;
    my $title = $self ~~ 'Title' // $self ~~ 'name';
    $title =~ s/\.*$//;
    my $data = {
		description => 'The object name of the publication',
		data => {
			id		=> $self ~~ 'name',
			label	=> eval {$self->intext_citation->{data}{citation}} // $title,
			class	=> $self ~~ 'class'
		   },
	};
    return $data;
}

sub title {
	my ($self) = @_;
    my $title = $self ~~ 'Title' // return;
    $title =~ s/\.*$//;
    my $data = {
		description	=> 'The title of the publication',
		data		=> $title,
    };
    return $data;
}

sub journal {
	my ($self) = @_;
    my $journal = $self ~~ 'Journal' // return;
    $journal =~ s/\.*$//;
    my $data = { description => 'The journal the paper was published in',
				 data        => $journal,
			 };
    return $data;
}

sub page {
	my ($self) = @_;
    my $page = $self ~~ 'Page' // return;
    $page =~ s/\.*$//;
    my $data = {
		description => 'The pages of the publication',
		data        => $page,
    };
    return $data;
}

sub volume {
	my ($self) = @_;
    my $volume = $self ~~ 'Volume' // return;
    $volume =~ s/\.*$//;
    my $data = { 
		description => 'The volume the paper was published in',
		data        => $volume,
    };
    return $data;
}

sub year {
    my $self = shift;
	my $date = $self ~~ 'Publication_date' // return;
    my $data = {
		description => 'The year of publication',
		data        =>  $self->_parse_year($date),
    };
    return $data;
}

sub publication_date {
	my ($self) = @_;
	my $date = $self ~~ 'Publication_date' // return;
	my $data = {
		description => 'The publication date of the publication',
		data		=> $date,
	};
	return $data;
}

sub authors {
	my ($self) = @_;
	# this is the long form of author
	my $authors = $self ~~ '@Author';
	return unless @$authors;

    my @authors;
    foreach my $author (@$authors) {
		my $obj = $author;
		foreach my $col ($author->col) {
			$obj = $col->right if $col eq 'Person';
		}

		my @authorname = parse_name_initials($author);
		my $label = @authorname > 1 ?
		  "$authorname[-1], " . join('. ', @authorname[0..$#authorname-1]) . '.' :
			$authorname[0];		# author's name in APA format

		push(@authors,{
			id=>$obj,
			class=>$obj->class,
			label => $label,
		});
    }
    my $data = {
		description => 'The authors of the publication',
		data        => \@authors,
	};
    return $data;
}

sub editors {
	my ($self) = @_;
	my $editors = $self ~~ '@Editor';
	return unless @$editors;

	unless ($self->is_wormbook_paper->{data}) {
		$editors = [map {@$_ > 1 ? $_->[-1] . ', ' . join('. ', $_->[0..$#_-1]) . '.'
						   : $_->[0]} map [parse_name_initials($_)], @$editors];
	}

	return {
		description => 'Editor of publication',
		data => $editors,
	};
}

sub publication_type {
	my ($self) = @_;
	my $type = $self ~~ '@Type';
	return unless @$type;
	return {
		description => 'Type of publication',
		data => $type,
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
		data => $truth,
	};
}

sub abstract {
	my ($self) = @_;
    my $abs = $self ~~ 'Abstract' // return;
    my $text = '';

    if ($abs =~ /^WBPaper/i ) {
		$text = $abs->right;
		$text=~s/^\n+//;
		$text=~s/\n+$//;
    }

    my $data = {
		description => 'The abstract of the publication',
		data        => $text,
	};
    return $data;
}

sub remarks {
	my ($self) = @_;
	my $remarks = $self ~~ '@Remark' // return;
	return unless @$remarks;
	return {
		description => 'Remarks regarding this publication',
		data => $remarks,
	};
}

sub keywords {
	my ($self) = @_;
	my $keywords = $self ~~ '@Keyword';
	return unless @$keywords;
	my $data = $self->_pack_objects($keywords);

	my $field = {
		description => 'Keywords related to the publication',
		data		=> $data,
	};
	return $field;
}

# TODO: publisher should be in format "Location: Publisher"
#       for APA citations. Consider parsing $self ~~ 'Publisher'
#       and returning [Location, Publisher] -- this may be as hard
#       as parsing a name! :(
sub publisher {
	my ($self) = @_;
	my $publisher = $self ~~ 'Publisher' // return;
	return {
		description => 'Publisher of the publication',
		data => $publisher,
	};
}

sub affiliation {
	my ($self) = @_;
	my $affiliations = $self ~~ '@Affiliation';
	return  unless @$affiliations;

	return {
		description => 'Affiliations of the publication',
		data => $affiliations,
	};
}

sub doi {
	my ($self) = @_;
	my $name = $self ~~ 'Name' // return;
	my $field;
	if ($name =~ m{^(?:doi.*)?(10\.[^/]+.+)$}) {
		$field = {
			description => 'DOI of publication',
			data => $1,
		};
	}
	return $field;
}

sub pmid {
	my ($self) = @_;
	my @dbfields = $self->object->Database(2);
	foreach (@dbfields) {
		if ($_ == 'PMID') {
			return {
				description => 'PubMed ID of publication',
				data => $_->right,
			};
		}
	}
	return;
}

sub intext_citation {
	my ($self) = @_;

	my $packed_authors = eval {$self->authors->{data}} // return;
	my $year = eval {$self->year->{data}};

	my $innertext;
	if (@$packed_authors > 5) {					 # 6..inf
		my $author = $packed_authors->[0]->{id}; # will be author or person object
		$innertext = (parse_name($author))[-1] . ' et al.';
	}
	else {
		my @authors = map $_->{id}, @$packed_authors;
		if (@authors > 2) {		# 3..5
			my @lnames = map {(parse_name($_))[-1]} @authors;
			$innertext = join(', ', @lnames[0..$#lnames-1]) . ', & ' . $lnames[-1];
		}
		else {
			$innertext = join(' & ', map {(parse_name($_))[-1]} @authors);
		}
	}

	return unless $innertext;

	$innertext .= ", $year" if defined $year;

	my $data = {
		description => 'APA in-text citation',
		data => {
			citation => '(' . $innertext . ')',
			paper => $self->object,
		},
	};
	return $data;
}

sub contained_in {
	my ($self) = @_;
	my $contained_in = $self ~~ '@Contained_in';
	return unless @$contained_in;

	my $field = {
		description => 'Publications this publication is contained in',
		data => $contained_in,
	};
	return $field;
}

sub refers_to {
	my ($self) = @_;
	my %data;
	my @refers_to = $self->object->Refers_to;
	foreach my $ref_type (@refers_to) {
		my @columns = $ref_type->col;
		$data{$ref_type} = $self->_pack_objects(\@columns);
	}
	my $fields = {
		description => 'Items that the publication refers to',
		data => \%data,
	};
	return $fields;
}

sub genes {
	my ($self) = @_;
	my $genes = $self->_pack_objects($self ~~ '@Gene');
	return unless @$genes;

	my $data = {
		description => 'Genes related to or mentioned in paper',
		data => $genes,
	};
	return $data;
}

sub alleles {
	my ($self) = @_;
	my $alleles = $self->_pack_objects($self ~~ '@Allele');
	return unless @$alleles;

	my $data = {
		description => 'Alleles referenced by the paper',
		data		=> $alleles,
	};
	return $data;
}

sub interactions {
	my ($self) = @_;
	my $interactions = $self->_pack_objects($self ~~ '@Interaction');
	return unless @$interactions;

	my $data = {
		description => 'Interactions referenced by the paper',
		data => $interactions,
	};
	return $data;
}

sub strains {
	my ($self) = @_;
	my $strains = $self->_pack_objects($self ~~ '@Strain');
	return unless @$strains;

	my $data = {
		description => 'Strains referenced by the paper',
		data 		=> $strains,
	};
	return $data;
}

############################################################
#
# PRIVATE METHODS
#
############################################################

1;

