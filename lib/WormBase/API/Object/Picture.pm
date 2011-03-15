package WormBase::API::Object::Picture;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has '_reference' => ( # single reference or undef
    is => 'ro',
    lazy_build => 1,
);

sub _build__reference {
    my ($self) = @_;
    return $self ~~ 'Reference';
}

=pod 

=head1 NAME

WormBase::API::Object::Picture

=head1 SYNPOSIS

Model for the Ace ?Picture class.

=head1 URL

http://wormbase.org/resources/picture

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>


sub cropped_from {
	my ($self) = @_;

    my $pic = $self ~~ 'Cropped_from';
	return {
		description => 'Picture that this picture was cropped from',
		data		=> $pic && $self->wrap($pic)->image->{data},
	};
}

sub cropped_pictures {
	my ($self) = @_;

    my %data = map {$_ => $self->wrap($_)->image->{data}} @{$self ~~ '@Crop_picture'};
	return {
		description => 'Picture(s) that were cropped from this picture',
		data        => %data ? \%data : undef,
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

    my ($file, $filename, $reference, $class);
    if ($reference = $self->_reference) { {
        $filename = $self ~~ 'Name'; # file name
        last unless $filename; # break out (that's why there's an extra {} block)
        $file = $self->pre_compile->{new_images} . '/' . $reference . '/' . $filename;
        unless (-e $file && !-z $file) {
            undef $file;
            undef $filename;
            last;
        }
        $class = 'new_images';
    } } # if $file is undef, then could not find

    if (!$file) { # try the old images
        $filename = "$obj";
        foreach (qw(expr_pattern_localizome expr_pattern)) {
            $class = $_;
            $file = $self->pre_compile->{$class} . '/' . $filename;
            if (!-e $file || -z $file) {
                undef $file;
                next;
            }
        }
    } # if $file is still undef, then there is no image file.

    $filename =~ /^(.+)\.(.+)$/; # will match names like a.b.c.jpg properly due to greediness
    my ($namepart, $format) = ($1 || $obj.'', $2 || '');

    if ($reference) {
        my $ref_label;
        if ($ref_label = $self ~~ 'Template') {
            foreach (qw(Publication_year Article_URL Journal_URL Publisher_URL Person_name)) {
                $ref_label =~ s/\<$_\>/$self ~~ $_/ge;
            }
        }
        $reference = $self->_pack_obj($reference, $ref_label);
    }

    # THIS IS A HACK -- CHANGE LATER:
    $namepart = "$reference->{id}/$namepart" if $class eq 'new_images';

    $data = {
        id		  => "$obj",
        name	  => $namepart,
        class	  => $class,
        format	  => $format,
        reference => $reference,
    };

	return {
		description => 'Information pertaining to underlying image of picture',
		data		=> $data,
	};
}


# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

sub depicts {
	my ($self) = @_;
	my %depictions; # a picture can depict more than one thing...
    foreach my $depict_type (@{$self ~~ '@Depict'}) {
        $depictions{$depict_type} = $self->_pack_objects([$depict_type->col]);
    }

	return {
		description => 'What this picture depicts',
		data		=> %depictions ? \%depictions : undef,
	};
}

sub reference { # could this be multiple? (model allows it)
	my ($self) = @_;

	return {
		description => 'Paper that this picture belongs to',
		data		=> $self->_pack_obj($self->_reference),
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
