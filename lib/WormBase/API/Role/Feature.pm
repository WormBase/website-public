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
        (my $method = $feature->Method) =~ s/_/ /g;
        my @bound_by = map { $self->_pack_obj($_) } $feature->Bound_by_product_of;
        my $tf = $self->_pack_obj($feature->Transcription_factor);

        my @interactions = map { $self->_pack_obj($_) } $feature->Associated_with_Interaction;

        my @expr_pattern = map {
            my @anatomy = $self->_pack_list([$_->Anatomy_term], sort => 1);
            {
                text => \@anatomy,
                evidence => { by => $self->_pack_obj($_) }
            } if @anatomy;
        } $feature->Associated_with_expression_pattern;

        push @data, {
            name => $self->_pack_obj($feature),
            description => $description && "$description",
            method => $method && "$method",
            interaction => \@interactions,
            expr_pattern => \@expr_pattern,
            bound_by => \@bound_by,
            tf => $tf
        };
    }
    return @data;

}


1;
