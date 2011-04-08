package WormBase::Util::ParseName;

use Exporter 'import';
use strict;
use warnings;

our @EXPORT_OK = qw(parse_name parse_name_initials);

sub parse_name_initials {
	my ($obj) = @_;
	my @nameparts = parse_name($obj);
	return @nameparts if @nameparts < 2;
	my $last = pop @nameparts;
	return map({uc substr $_, 0, 1} @nameparts), $last;
}

sub parse_name {
	my ($obj) = @_;
	if (eval {$obj->isa('Ace::Object')}) {
		if ($obj->class eq 'Author') {
			return _parse_name_author($obj);
		}
		elsif ($obj->class eq 'Person') {
			return _parse_name_person($obj);
		}
	}
	# scalar or unknown ref
	return _parse_name("$obj"); # try to parse stringified object...
}

sub _parse_name_author {
	my ($author) = @_;
	my @nameparts;

	if (my $person = $author->Possible_person) {
		@nameparts = _parse_name_person($person);
	}

	# skipping AKAs... will just try to directly parse from obj name
	@nameparts = _parse_name("$author") unless @nameparts;

	return @nameparts;
}

sub _parse_name_person {
	my ($person) = @_;

	if (my $firstname = $person->First_name and
		  my $lastname = $person->Last_name) {
		my $middlename = $person->Middle_name;
		return $firstname, $middlename, $lastname if $middlename;
		return $firstname, $lastname;
	}
	elsif (my $name = $person->Full_name || $person->Standard_name) {
		return  _parse_name($name);
	}

	return;
}

sub _parse_name {
	local ($_) = @_;  # for brevity
	s/^[^A-Za-z]+//; s/[^A-Za-z.]+$//;
	s/_/ /g; # underscores should be spaces
	s/- +/-/g; # fix hyphenation

	my $name = $_; # for clarity

	if ($name =~ /,/) {
		my ($lastname_part, $firstname_part)  = split /, */, $name, 2;
		my @nameparts =  map {split /[ .]+/, $_} $firstname_part, $lastname_part;
		return @nameparts if uc $name eq $name; # anything goes
		return map { /^[A-Z]{2,3}$/ ? split // : $_ } @nameparts;
	} # dealing with commas is easier...

	my @tokens = split / +/, $name;
	if (@tokens == 1) {	# I.Last maybe
		return split /\./, $name;
	}

	# initials with periods
	if ($name =~ /\.$/) {
		my $lastname = shift @tokens;
		return map({split /\./} @tokens), $lastname;
	}

	if ($name =~ /\./) {
		return map {split /\./} @tokens;
	}

	# initials without periods or no initials at all
	if ($name =~ / [A-Z]$/) { # likely separate initial(s) at end
		my $lastname = shift @tokens;
		return @tokens, $lastname;
	}

	if (uc $name ne $name) { # anything goes if allcaps
		if ($name =~ /^[A-Z]{2,3} /) { # likely clustered initials at beginning
			my @initials = split //, shift @tokens; # split cluster
			return @initials, @tokens;
		}

		if ($name =~ / [A-Z]{2,3}$/) { # clustered initials at end?
			my $lastname = shift @tokens;
			my @initials = split //, pop @tokens;
			return @initials, @tokens, $lastname if @tokens;
			return @initials, $lastname;
		}
	}

	return @tokens;
}

1;
