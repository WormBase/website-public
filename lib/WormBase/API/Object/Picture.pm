package WormBase::API::Object::Picture;

use Moose;

with 'WormBase::API::Role::Object';
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
    if (my $expr_patterns = $self->expression_patterns->{data}) {
        if (@$expr_patterns > 1) { # according to curator, this won't happen...
            $name = "Multiple expression patterns";
        }
        else { # should be 1 item
            my $exprname = $expr_patterns->[0]->{expression_pattern}->{label};
            $name = "$exprname";
        }
    }

    return $name // $self->object->name;
}

#######################################
#
# CLASS METHODS
#
#######################################

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

=head3 cropped_from

Returns a datapack containing the picture (parent) that the picture is cropped from.

=over

=item PERL API

 $data = $model->cropped_from();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Picture ID (eg WBPicture0000007416)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/cropped_from

B<Response example>

<div class="response-example"></div>

=back

=cut

sub cropped_from {
	my ($self) = @_;

	return {
		description => 'Picture that this picture was cropped from',
		data		=> $self->_pack_obj($self ~~ 'Cropped_from'),
	};
}

=head3 cropped_pictures

Returns a datapack containing pictures cropped from the [parent] picture.

=over

=item PERL API

 $data = $model->cropped_pictures();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Picture ID (eg WBPicture0000007416)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/cropped_pictures

B<Response example>

<div class="response-example"></div>

=back

=cut

sub cropped_pictures {
	my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Crop_picture');
	return {
		description => 'Picture(s) that were cropped from this picture',
		data        => %$data ? $data : undef,
	};
}

=head3 image

Returns a datapack containing information related to rendering the image via "/draw"

=over

=item PERL API

 $data = $model->image();

B<Usage Example>

 ($format, $class, $name) = ($data->{format}, $data->{class}, $data->{$name});
 $image_url = "http://www.wormbase.org/draw/$format?class=$class&id=$name"

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Picture ID (eg WBPicture0000007416)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/image

B<Response example>

<div class="response-example"></div>

=back

=cut

sub image {
	my ($self) = @_;

	my $datapack = {
        description => 'Information pertaining to the underlying image of the picture',
        data        => undef,
    };

    my $reference = $self->reference->{data} || $self->contact->{data}
        or return $datapack;
    $reference = $reference->{id}; # we only need the id;

    my $filename = $self ~~ 'Name'
        or return $datapack;

    my $file = $self->pre_compile->{picture} . '/'
             . $reference. '/' . $filename;
    return $datapack unless -e $file && !-z $file;

    $filename =~ /^(.+)\.(.+)$/ or return $datapack; # greedy . will match 'a.b.c.jpg' properly
    $datapack->{data} = {
        name   => $reference . '/' . $1 || $self->object->name,
        format => $2 || '',
        class  => 'picture',
    };

    return $datapack;
}

=head3 external_source

Returns a datapack containing the acknowledgement (i.e. source of picture) data.

=over

=item PERL API

 $data = $model->external_source();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Picture ID (eg WBPicture0000007416)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/external_source

B<Response example>

<div class="response-example"></div>

=back

=cut

sub external_source {
    my ($self) = @_;
    my $obj    = $self->object;

    my $source;
    if (my $template = $obj->Template) {
        my $publication_year = $obj->Publication_year || '';
        $template =~ s/\<Publication_year\>/$publication_year/g;
        $source = { template => "$template" };

        foreach my $dbtag (qw(Journal_URL Publisher_URL)) {
            my $db = $obj->$dbtag;
            my $text = $db->Name || $db->name;
            my $url = $db->URL;

            $source->{template_items}->{$dbtag} = {
                text => $text && "$text",
                url  => $url && "$url",
            };
        }


        if (my ($dbnode) = $obj->Article_URL) {
            my ($db, $field, $accessor) = $dbnode->row;
            my $url   = $db->URL_constructor;
            $url   =~ s/%S/$accessor/g if $accessor; # is this always the case? %S?
            # one would imagine $url = sprintf($url, $accessor);
            $url ||= $db->URL;

            my $ref = $self->reference->{data};
            my $text = $ref && $ref->{label}; # try this for now
            # what if there's no text?
            $source->{template_items}->{Article_URL} = {
                text => $text,
                url  => $url,
            };
        }
    }

    return {
        description => 'Information to link to the source of this picture',
        data        => $source,
    };
}

=head3 go_terms

Returns a datapack containing the GO terms depicted in the picture.

=over

=item PERL API

 $data = $model->go_terms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Picture ID (eg WBPicture0000007416)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/go_terms

B<Response example>

<div class="response-example"></div>

=back

=cut

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub expression_patterns { }
# Supplied by Role; POD will automatically be inserted here.
# << include expression_patterns >>

sub go_terms {
    my ($self) = @_;

    my $go_terms = $self->_pack_objects($self ~~ '@Cellular_component');

    return {
        description => 'GO terms for this picture',
        data        => %$go_terms ? $go_terms : undef,
    };
}

=head3 anatomy_terms

Returns a datapack containing the anatomy terms depicted in the picture.

=over

=item PERL API

 $data = $model->anatomy_terms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Picture ID (eg WBPicture0000007416)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/picture/WBPicture0000007416/anatomy_terms

B<Response example>

<div class="response-example"></div>

=back

=cut

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

