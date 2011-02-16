package WormBase::API::Object::Picture;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
	my ($self) = @_;
	my $objname = $self ~~ 'name';
	my $name	= $self ~~ 'Name' || $objname;
	return {
		description => 'The object name of the picture',
		data		=> {
			id	  => $objname,
			label => $name,
			class => $self ~~ 'class',
		},
	};
}

sub description {
	my ($self) = @_;
	my $description = join(' ', @{$self ~~ '@Descriptions'});
	return {
		description => 'Description of the picture',
		data		=> $description,
	};
}

sub cropped_from {
	my ($self) = @_;
	my $pic = $self ~~ 'Cropped_from';
	return {
		description => 'Picture that this picture was cropped from',
		data		=> $pic,
	};
}

sub cropped_pictures {
	my ($self) = @_;
	my $pics = $self ~~ '@Cropped_picture';
	return {
		description => 'Picture(s) that were cropped from this picture',
		data		=> @$pics ? $pics : undef,
	};
}

sub pick_me_to_call {
	my ($self) = @_;
	# not sure what this field is...
	my $data;
	if (my $node = $self ~~ 'Pick_me_to_call') {
		$data = join ':', $node->row;
	}

	return {
		description => 'Unknown',
		data		=> $data,
	};
}

sub image {
	my ($self) = @_;
	my $obj = $self->object;

	# The following was lifted from the Expr_pattern model;
	# however, there is no such equivalent data yet. There is an
	# equivalent, currently unpopulated Remark field in Picture.
	# Keep an eye out for that.
	#
	#	my $class = $self ~~ 'Remark' =~ /chronogram/ ?
	#	  'expr_pattern_localizome' : 'expr_pattern';

	my $data;

	foreach my $class (qw(expr_pattern_localizome expr_pattern)) { # test all for now
		my $file = $self->pre_compile->{$class}. '/' . $obj;
		next unless -e $file && !-z $file;

		$obj =~ /^([^.]+)\.(.+)$/;
		my ($name, $format) = ($1 || $obj.'', $2 || '');

		my $reference;
		if (my $ref_paper = $self->reference_paper->{data}) {
			$reference = $self->_pack_object($ref_paper);
		}

		$data = {
			id		  => "$obj",
			name	  => $name,
			class	  => $class,
			format	  => $format,
			reference => $reference,
		};
		last;
	}

	return {
		description => 'Information pertaining to underlying image of picture',
		data		=> $data,
	};
}

sub remarks {
	my ($self) = @_;
	my $remarks = $self ~~ '@Remark';

	return {
		description => 'Remarks regarding this picture',
		data		=> @$remarks ? $remarks : undef,
	};
}

sub depicts {
	my ($self) = @_;
	my %depictions; # a picture can depict more than one thing...
	foreach (@{$self ~~ '@Depict'}) {
		push @{$depictions{$_}}, $self->_pack_object($_->right);
	}

	return {
		description => 'What this picture depicts',
		data		=> keys %depictions ? \%depictions : undef,
	};
}

sub reference_paper {
	my ($self) = @_;
	my $paper = $self ~~ 'Paper';
	$paper = $self->_pack_object($paper) if $paper;

	return {
		description => 'Paper that this picture belongs to',
		data		=> $paper,
	};
}

sub contact {
	my ($self) = @_;
	my $contact = $self ~~ 'Contact';

	return {
		description => 'Who to contact about this picture',
		data		=> $contact,
	};
}

1;
