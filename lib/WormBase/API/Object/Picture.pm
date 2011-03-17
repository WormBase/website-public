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
		data		=> $pic && $self->_wrap($pic)->image->{data},
	};
}

sub cropped_pictures {
	my ($self) = @_;

    my %data = map {$_ => $self->_wrap($_)->image->{data}} @{$self ~~ '@Crop_picture'};
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

sub image { # this is too bulky...
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
    if ($filename = $self ~~ 'Name' and $reference = $self->_reference) {
        $class     = 'new_images'; # temporary for transition to new pictures
        $file      = $self->pre_compile->{new_images} . '/' . $reference . '/' . $filename;
    }
    else { # legacy support
        $filename = "$obj"; # the filename in this case is the same as the object name
        foreach (qw(expr_pattern_localizome expr_pattern)) {
            $class = $_;
            # TODO: the following (and pre_compile statement above) are fairly low
            #       level and shouldn't be dealt with in these models...
            #       it should be abstracted elsewhere... perhaps a role
            #       which may also remove the need to wrap Picture objects
            $file = $self->pre_compile->{$class} . '/' . $filename;
            last if -e $file && !-z $file;
        }
    }


    my ($namepart, $format, $source);
    if (-e $file && !-z $file) {
        $filename =~ /^(.+)\.(.+)$/; # will match names like a.b.c.jpg properly due to greediness
        ($namepart, $format) = ($1 || $obj.'', $2 || '');

        if ($class eq 'new_images') {
            $namepart = "$reference/$namepart";

            if (my $label = $self ~~ 'Template') {
                $label =~ s/\<([^>]+)\>/$self ~~ $1/ge; # assume Ace caches stuff
                # # the following would be used instead if caching is required
                # my %cache;
                # $label =~ s| \<([^>]+)\>                                # look for <tag>
                #            | unless ($cache{$1}) {                      # check for cached value
                #                my ($tmp) = $obj->$1; $cache{$1} = $tmp; # cache value (don't step in!)
                #              };
                #              eval{$cache{$1}->Name} // $cache{$1}
                #            |gex;                                        # replaces <tag> with tag value

                my $link;
                if (my ($db, $field, $accessor) = $cache{Article_URL}->row) {
                    $link = $db->URL_constructor;
                    # one would imagine the following, but...
                    # $link = sprintf($link, $accessor);
                    $link =~ s/%S/$accessor/g; # is this always the case? %S?
                }

                # it's possible to not have a link, but still label the source
                $source = $label && {
                    text => $label,
                    link => $link,
                };
            }
        }
    }

    # could use _pack_obj, but Papers handle labelling differently
    $reference = $self->_wrap($reference)->name->{data} if $reference;
	return {
		description => 'Information pertaining to underlying image of picture',
		data		=> $namepart && {
            id		  => "$obj",               # internal object identifier
            name	  => $namepart,            # used by /draw as identifier...
            class	  => $class,               # what kind of picture
            format	  => $format,              # what format of image (for /draw)
            reference => $reference,           # from which paper
            source    => $source,              # source of picture
        },
	};
}


# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

sub expression_patterns {
    my ($self) = @_;

    my $expr_patterns = $self->_pack_objects($self ~~ '@Expr_pattern');

    return {
        description => 'Expression pattern(s) that this picture depicts',
        data        => %$expr_patterns ? $expr_patterns : undef,
    };
}

sub go_terms {
    my ($self) = @_;

    my $go_terms = $self->_pack_objects($self ~~ '@Cellular_component');

    return {
        description => 'GO terms for this picture',
        data        => %$go_terms ? $go_terms : undef,
    };
}

sub anatomy_terms {
    my ($self) = @_;

    my $anatomy_terms = $self->_pack_objects($self ~~ '@Anatomy');

    return {
        description => 'Anatomy terms for this picture',
        data        => %$anatomy_terms ? $anatomy_terms : undef,
    };
}

# pending obsolescence for the 3 above
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
