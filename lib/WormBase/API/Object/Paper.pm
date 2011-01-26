package WormBase::API::Object::Paper;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



sub name {
    my $self = shift;
    my $title = eval {$self ~~ 'Title'} || $self ~~ 'name';
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
    my $self = shift;
    my $title = eval {$self ~~ 'Title'} || return;
    $title =~ s/\.*$//;
    my $data = {
					description	=> 'The title of the paper',
					data		=> $title,
    };
    return $data;
}

sub journal {
    my $self = shift;
    my $journal = eval {$self ~~ 'Journal'} || return;
    $journal =~ s/\.*$//;
    my $data = { description => 'The journal the paper was published in',
		 data        => $journal,
    };
    return $data;
}

sub page {
    my $self = shift;
    my $page = eval {$self ~~ 'Page'} || return;
    $page =~ s/\.*$//;
    my $data = { description => 'The page numbers of the paper',
		 data        => $page,
    };
    return $data;
}

sub volume {
    my $self = shift;
    my $volume = eval {$self ~~ 'Volume'} || return;
    $volume =~ s/\.*$//;
    my $data = { description => 'The volume the paper was published in',
		 data        => $volume,
    };
    return $data;
}

sub year {
    my $self = shift;
    my $year = $self->_parse_year($self ~~ 'Publication_date');
    return unless $year;
    my $data = { description => 'The publication year of the paper',
		 data        => $year,
    };
    return $data;
}

sub publication_date {
	my $self = shift;
	my $date = $self ~~ 'Publication_date';
	my $data = {
					description => 'The publication date of the paper',
					data		=> $date,
	};
	return $data;
}

sub authors {
    my $self = shift;
  # this is the long form of author
    my @authors;
    foreach my $author (@{$self ~~ '@Author'}) {
	  my $obj = $author;
	  foreach my $col ($author->col) {
	    if($col eq 'Person') {
	      $obj = $col->right;
	    }
	  }
	  push(@authors,{
			  id=>$obj,
			  class=>$obj->class,
			  label =>$author ,
		      });
    }
    my $data = { description => 'The authors of the paper',
		 data        => \@authors,
    };
    return $data;
}

sub publication_type {
	my $self = shift;
	my $paper = $self->object;

    return ''; # TODO
}

sub abstract {
    my $self = shift;
    my $abs = $self ~~ 'Abstract';
    my $abstext = $self->ace_dsn->fetch(LongText=>$abs);
    my $text = "";

    if ($abstext =~ /WBPaper/i ) {
	 $text = $abstext->right;
	 $text=~s/^\n+//gs;
	 $text=~s/\n+$//gs;
    }

    my $data = {description => 'The abstract of the paper',
		 data        => $text,
    };
    return $data;
}

sub keywords {
	my $self = shift;
	my $keywords = $self->_pack_objects($self ~~ '@Keyword');
	my $data = {
					description => 'Keywords related to the paper',
					data		=> $keywords,
	};
	return $data;
}

sub PMID {
	my $self = shift;
	my @dbfields = $self->object->Database(2);
	foreach (@dbfields) {
		return $_->right if $_ == 'PMID'; # ?Accession_number (should be PMID)
	}
	return ''; # why can't I return; ?
}

sub intext_citation {
	my $self = shift;

	my $packed_authors = $self->authors->{data};
	my $year = $self->year->{data};

	my $innertext;
	if (@$packed_authors > 5) { # 6..inf
		my $author = $packed_authors->[0]->{id}; # will be author or person object
		$innertext = _extract_last_name_from_person($author) . ' et al.';
	}
	else {
		my @authors = map $_->{id}, @$packed_authors;
		if (@authors > 2) { # 3..5
			my @lnames = map {_extract_last_name_from_person($_)} @authors;
			$innertext = join(', ', @lnames[0..$#lnames]) . ', & ' . $lnames[-1];
		}
		elsif (@authors > 0) {  # 1..2
			$innertext = join(' & ', map {_extract_last_name_from_person($_)} @authors);
		}
	}

	return unless $innertext;

	if (defined $year) {
		$innertext .= ", $year";
	}
	$innertext = "($innertext)";

	my $data = {
				description => 'APA in-text citation',
				data => $innertext
			   };
	return $data;
}


sub refers_to {
	my $self = shift;
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

# below are deprecated in favour of refers_to()

sub genes {
	my $self = shift;
	my $genes = $self->_pack_objects($self ~~ '@Gene');
	my $data = {
					description => 'Genes related to or mentioned in paper',
					data => $genes,
				};
	return $data;
}

sub alleles {
	my $self = shift;
	my $alleles = $self->_pack_objects($self ~~ '@Allele');
	my $data = {
					description => 'TODO',
					data		=> $alleles,
	};
	return $data;
}

sub interactions {
	my $self = shift;
	my $interactions = $self->_pack_objects($self ~~ '@Interaction');
	my $data = {
					description => '',
					data => $interactions,
	};
	return $data;
}

sub strains {
	my $self = shift;
	my $strains = $self->_pack_objects($self ~~ '@Strain');
	my $data = {
					description => '',
					data 		=> $strains,
	};
	return $data;
}

############################################################
#
# PRIVATE METHODS
#
############################################################

# should consider moving this into Person?
sub _extract_last_name_from_person {
	my $person = shift;
	return unless eval{$person->isa('Ace::Object')};

	my $lastname;
	if ($person->class eq 'Author') {
		$lastname ||= _extract_last_name($person->Full_name);
		$lastname ||= _extract_last_name($person->Also_known_as);
		$lastname ||= _extract_last_name("$person");
	}
	elsif ($person->class eq 'Person') {
		$lastname ||= $person->Last_name;
		$lastname ||= _extract_last_name($person->Full_name);
		$lastname ||= _extract_last_name($person->Standard_name);
	}
	return $lastname;
}

sub _extract_last_name {
	$_ = shift;
	s/^[^A-Za-z]+//; # strip non-alphas from front
	s/[^A-Za-z.]+$//; # strip non-alphas (exc. '.') from back
	s/_/ /g; # underscores should be spaces
	s/- +/-/g; # fix hyphenation
	my $lastname_part;
	if (/,/) {
		$lastname_part = (split /,/)[0];
	}
	else {
	  s/ +([A-Z]\.? *)+$//;
	  $lastname_part = $_;
	}
	return (split/[. ]/, $lastname_part)[-1];
}

1;
