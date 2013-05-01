package WormBase::API::Role::Expr_pattern;

use Moose::Role;

#######################################################
#
# Attributes
#
#######################################################


has 'certainty_ev' => (
    is  => 'ro',
    isa => 'HashRef',
    default => sub(){ return {    Certain => ' was observed to be expressed in ',
                    Partial => ' was observed to be expressed in some cells of a group of cells that include ',
                    Uncertain => ' was sometimes observed to be expressed in / was observed to be expressed in a cell that could be '};},
);

=head3 expression_patterns

This method will return a data structure containing
a list of expresion patterns associated with the object.

=over

=item PERL API

 $data = $model->expression_patterns();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/expression_patterns

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% expression_patterns %]

has 'expression_patterns' => (
    is         => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_expression_patterns',
);

# TODO: use hash instead; make expression_patterns macro compatibile with hash
sub _build_expression_patterns {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my @data;
    my $obj_label = $self->_common_name;

    foreach ($object->Expr_pattern) {
        my $author = $_->Author;
        my @patterns = $_->Pattern
            || $_->Subcellular_localization
            || $_->Remark;
        my $gene      = $self->_pack_obj($_->Gene);

        my $certainty = $_->fetch()->at("Expressed_in.$class.$object");
        $certainty = $certainty->right if $certainty;
        my $c_ev = $self->_get_evidence($certainty);
        $c_ev->{$certainty} = $gene->{label} . $self->certainty_ev->{$certainty} . $obj_label if $certainty;

        push @data, {
            expression_pattern => $self->_pack_obj($_),
            description        => join("<br />", @patterns) || undef,
            author             => $author && "$author",
            gene               => $gene,
            certainty          => $c_ev ? { evidence => $c_ev, text => "$certainty"} : ($certainty && "$certainty"),
        };
    }

    return {
        description => "expression patterns associated with the $class:$object",
        data        => @data ? \@data : undef
    };
}
1;
