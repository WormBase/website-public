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
		description => 'The object name of the paper',
		data => {
			id		=> $self ~~ 'name',
			label	=> $title,
			class	=> $self ~~ 'class'
		   },
	};
    return $data;
}


############################################################
#
# The Overview widget
#
############################################################

sub title {
	my ($self) = @_;
    my $title = $self ~~ 'Title' // return;
    $title =~ s/\.*$//;
    my $data = {
		description	=> 'The title of the paper',
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
		description => 'The page numbers of the paper',
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
		description => 'The publication year of the paper',
		data        =>  $self->_parse_year($date),
    };
    return $data;
}

sub publication_date {
	my ($self) = @_;
	my $date = $self ~~ 'Publication_date' // return;
	my $data = {
		description => 'The publication date of the paper',
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
		description => 'The authors of the paper',
		data        => \@authors,
	};
    return $data;
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

sub abstract {
	my ($self) = @_;
    my $abs = $self ~~ 'Abstract' // return;
    my $abstext = $self->ace_dsn->fetch(LongText=>$abs);
    my $text = "";

    if ($abstext =~ /WBPaper/i ) {
		$text = $abstext->right;
		$text=~s/^\n+//gs;
		$text=~s/\n+$//gs;
    }

    my $data = {
		description => 'The abstract of the paper',
		data        => $text,
	};
    return $data;
}

sub keywords {
	my ($self) = @_;
	my $keywords = $self->_pack_objects($self ~~ '@Keyword');
	my $data = {
		description => 'Keywords related to the paper',
		data		=> $keywords,
	};
	return $data;
}

sub doi {
	my ($self) = @_;
	my $name = $self ~~ 'Name' // return;
	my $field;
	if ($name =~ m{^(?:doi.*)?(10\.[^/]+.+)$}) {
		$field = {
			description => 'DOI of paper',
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
				description => 'PubMed ID of paper',
				data => $_->right,
			};
		}
	}
	return;
}

sub intext_citation {
	my ($self) = @_;

	my $packed_authors = $self->authors->{data} // return;
	my $year = $self->year->{data};

	my $innertext;
	if (@$packed_authors > 5) {					 # 6..inf
		my $author = $packed_authors->[0]->{id}; # will be author or person object
		$innertext = (parse_name($author))[-1] . ' et al.';
	}
	else {
		my @authors = map $_->{id}, @$packed_authors;
		if (@authors > 2) {		# 3..5
			my @lnames = map {(parse_name($_))[-1]} @authors;
			$innertext = join(', ', @lnames[0..$#lnames]) . ', & ' . $lnames[-1];
		}
		else {
			$innertext = join(' & ', map {(parse_name($_))[-1]} @authors);
		}
	}

	return unless $innertext;

	$innertext .= ", $year" if defined $year;

	my $data = {
		description => 'APA in-text citation',
		data => '(' . $innertext . ')',
		paper => $self->object,
	};
	return $data;
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
		description => 'Objects that the paper refers to',
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

