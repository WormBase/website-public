package WormBase::API::Role::Feature;

use Moose::Role;

#######################################################
#
# Attributes
#
#######################################################

has 'features' => (
    is  => 'ro',
    lazy => 1,
    builder => '_build_features',
);

#######################################
#
# The Feature Widget
#   template: classes/gene/feature.tt2
#
#######################################

sub _build_features {
    my $self = shift;
    my $feature_tag_name = 'Associated_feature';
    my @data = $self->_get_feature_associations($feature_tag_name);

    return {
        description => 'Features associated with this ' . $self->object->class,
        data        => @data ? \@data : undef,
    };
}


#######################################
#
# helper functions for subclasses
#
#######################################

# Identify associated features by a tag_name (that may differ among subclasses)
# and store their information in a hash
sub _get_feature_associations {
    my ($self, $feature_tag_name) = @_;
    my $gene = $self->object;
    my @data;
    foreach my $feature ($gene->$feature_tag_name){
        my $description = $feature->Description;
        my $method = $feature->Method;
        my @bound_by = map { $self->_pack_obj($_) } $feature->Bound_by_product_of;
        my $tf = $feature->Transcription_factor;

        # create a list of associations
        my @associations;
        foreach my $as_tag ($feature->Associations){
            push @associations, map {
                my ($type) = "$as_tag" =~ /Associated_with_(\w+)/;
                $type =~ s/_/ /g;
                my $packed_as = $self->_pack_obj($_);
                my $label = $packed_as->{label};
                $packed_as->{label} = "$type: " . $label unless $label =~ /$type/i;
                $packed_as;
            } $as_tag->col();

            # (my $type = "$as_tag") =~ s/_/ /g;
            # my @as = map { $self->_pack_obj($_) } $as_tag->col();
            # push @associations, {
            #     text => \@as,
            #     evidence => { type => $type },
            # };
        }
        sub priority {
            # a greater priority value is considered high priority
            my $as = shift;
            return $as->{label} =~ /^(Interaction|expression pattern)/i;
        }
        @associations = sort { priority($b) cmp priority($a) } @associations;  #sort by descending priority


        push @data, {
            name => $self->_pack_obj($feature),
            description => $method && "$description",
            method => $method && "$method",
            association => \@associations,
            bound_by => \@bound_by,
            tf => $tf && "$tf"
        };
    }
    return @data;

}

1;
