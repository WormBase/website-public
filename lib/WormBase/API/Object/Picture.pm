package WormBase::API::Object::Picture;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has 'reference' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_reference {
	my ($self) = @_;

	return {
		description => 'Paper that this picture belongs to',
		data		=> $self->_pack_obj($self ~~ 'Reference'),
	};
}

has 'contact' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_contact {
	my ($self) = @_;

	return {
		description => 'Who to contact about this picture',
		data		=> $self->_pack_obj($self ~~ 'Reference'),
	};
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

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>


sub cropped_from {
	my ($self) = @_;

	return {
		description => 'Picture that this picture was cropped from',
		data		=> $self->_pack_obj($self ~~ 'Cropped_from'),
	};
}

sub cropped_pictures {
	my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Crop_picture');
	return {
		description => 'Picture(s) that were cropped from this picture',
		data        => %$data ? $data : undef,
	};
}

sub image {
	my ($self) = @_;

	my $datapack = {
        description => 'Information pertaining to the underlying image of the picture',
        data        => undef,
    };

    my $reference = $self->reference->{data};
    my $contact   = $self->contact->{data};
    return $datapack unless $reference || $contact;

    my $filename = $self ~~ 'Name';
    return $datapack unless $filename;

    my $file = $self->pre_compile->{picture} . '/'
             . $reference->{id} || $contact->{id} . '/' . $filename;
    return $datapack unless -e $file && !-z $file;

    $filename =~ /^(.+)\.(.+)$/ or return $datapack; # greedy . will match 'a.b.c.jpg' properly
    $datapack->{data} = {
        name   => $1 || $self->object->name,
        format => $2 || '',
        class  => 'picture',
    };

    return $datapack;
}

sub external_source {
    my ($self) = @_;
    my $obj    = $self->object;

    my $source;
    if (my $label = $self ~~ 'Template') {
        $label =~ s/\<([^>]+)\>/$obj->$1/ge; # Ace caches stuff...?

        my $link;
        if (my ($article_URL) = $obj->Article_URL) {
            my ($db, $field, $accessor) = $article_URL->row;
            $link = $db->URL_constructor;
            $link =~ s/%S/$accessor/g if $accessor; # is this always the case? %S?
            # one would imagine $link = sprintf($link, $accessor);
        }

        # it's possible to not have a link, but still label the source
        $source = $label && {
            text => $label,
            link => $link,
        };
    }

    return {
        description => 'Information to link to the source of this picture',
        data        => $source,
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

__PACKAGE__->meta->make_immutable;

1;

