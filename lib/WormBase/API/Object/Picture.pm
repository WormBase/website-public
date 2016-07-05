package WormBase::API::Object::Picture;

use Moose;
use File::Spec;
use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Expr_pattern';
extends 'WormBase::API::Object';

=pod

=head1 NAME

WormBase::API::Object::Picture

=head1 SYNPOSIS

Model for the Ace ?Picture class.

=head1 URL

http://wormbase.org/resources/picture

=cut

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
		data		=> $self->_pack_obj($self ~~ 'Contact'),
	};
}

sub _build__common_name {
    my ($self) = @_;

    my $name;
    if (my @expr_patterns = $self->object->Expr_pattern) {
        if (@expr_patterns > 1) { # according to curator, this won't happen...
            $name = "Multiple expression patterns";
        }
        else { # should be 1 item
            $name = $self->_pack_obj($expr_patterns[0])->{label};
        }
    }

    return $name // $self->object->name;
}

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

# name { }
# Supplied by Role

# description { }
# Supplied by Role

# cropped_from { }
# Returns a datapack containing the picture (parent) that the picture is cropped from.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/cropped_from

sub cropped_from {
	my ($self) = @_;

	return {
		description => 'Picture that this picture was cropped from',
		data		=> $self->_pack_obj($self ~~ 'Cropped_from'),
	};
}

# cropped_pictures { }
# Returns a datapack containing pictures cropped from the [parent] picture.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/cropped_pictures

sub cropped_pictures {
	my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Crop_picture');
	return {
		description => 'Picture(s) that were cropped from this picture',
		data        => %$data ? $data : undef,
	};
}

# image { }
# Returns a datapack containing information related to rendering the image via "/draw"
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/image

sub image {
	my ($self) = @_;

	my $datapack = {
        description => 'Information pertaining to the underlying image of the picture',
        data        => undef,
    };

    my $reference = $self->_source();

    return $datapack unless $reference;

    $reference = $reference->{id}; # we only need the id;

    my $filename = $self ~~ 'Name'
        or return $datapack;

    $filename =~ /^(.+)\.(.+)$/ or return $datapack; # greedy . will match 'a.b.c.jpg' properly
    $datapack->{data} = {
        name   => $reference . '/' . $1 || $self->object->name,
        format => $2 || '',
        class  => $self->pre_compile->{picture},
    };

    return $datapack;
}

# external_source { }
# Returns a datapack containing the acknowledgement (i.e. source of picture) data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/external_source

sub external_source {
    my ($self) = @_;
    my $obj    = $self->object;

    my $source;
    if (my $template = $obj->Template) {
        my $publication_year = $obj->Publication_year || '';
        $template =~ s/\<Publication_year\>/$publication_year/g;
        $source = { template => "$template" };

        foreach my $dbtag (qw(Journal_URL Publisher_URL)) {
            my $db = $obj->$dbtag or next;
            my $text = $db->Name || $db->name;

            $source->{template_items}->{$dbtag} = {
                text => $text && "$text",
                db => "$db",
            };
        }

        if (my $person_name = $obj->Person_name) {
            $source->{template_items}->{Person_name}->{text} = "$person_name";
            # if it's a person and they are a WBPerson then... ?
        }

        if (my ($dbnode) = $obj->Article_URL) {
            my ($db, $field, $accessor) = $dbnode->row;

            my $ref = $self->reference->{data};
            my $text = $ref && $ref->{label}; # try this for now
            # what if there's no text?
            $source->{template_items}->{Article_URL} = {
                text => $text,
                db => "$db",
                id => "$accessor",
                dbt => "$field",
            };
        }
    }

    return {
        description => 'Information to link to the source of this picture',
        data        => $source,
    };
}

# _source {}
# used internally
# returns the paper of person source of the Picture
sub _source {
    my ($self) = @_;
    my $object = $self->object;

    my $reference;
    # decide whether the source is a Paper or a Person
    if ($object->Template =~ /Journal_URL/){
        $reference = $self->reference->{data};
    } else {
        $reference = $self->contact->{data};
    }
    return $reference;
}

# remarks {}
# Supplied by Role

# expression_patterns { }
# Supplied by Role

# go_terms { }
# Returns a datapack containing the GO terms depicted in the picture.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/go_terms

sub go_terms {
    my ($self) = @_;

    my $go_terms = $self->_pack_objects($self ~~ '@Cellular_component');

    return {
        description => 'GO terms for this picture',
        data        => %$go_terms ? $go_terms : undef,
    };
}

# anatomy_terms { }
# Returns a datapack containing the anatomy terms depicted in the picture.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/anatomy_terms

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
