package WormBase::API::Object::Phenotype;

use Moose;
use JSON;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Phenotype

=head1 SYNPOSIS

Model for the Ace ?Phenotype class.

=head1 URL

http://wormbase.org/species/phenotype

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

############################################################
#
# The Details widget
#
############################################################

=head2 Details

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 synonym

This method will return a data structure synonyms for the phenotype.

=over

=item PERL API

 $data = $model->synonym();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/synonym

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub synonym {
    my $data = {
        description => 'The synonym name of the phenotype ',
        data        => shift ~~ '@Synonym',
    };
    return $data;
}

=head3 is_dead

This method will return a data structure noting that the phenotype is retired and replaced by another.

=over

=item PERL API

 $data = $model->is_dead();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/is_dead

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub is_dead {
    my $object = shift->object;
    my $alternate = $object->Dead->right if $object->Dead(0);
    return {
        description =>
"The Note of the phenotype when it's retired and replaced by another.",
        data => {
            id    => $alternate,
            label => $alternate,
            class => 'Phenotype',
        },
    };
}

############################################################
#
# The Ontology Browser widget
#
############################################################

=head2 Ontology Browser

=cut

############################################################
#
# The Related Information widget
#
############################################################

=head2 Related Information

=cut

=head3 related_phenotypes

This method will return a data structure providing the generalize and specialized terms for the phenotype in the ontology.

=over

=item PERL API

 $data = $model->related_phenotypes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/related_phenotypes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub related_phenotypes {
    my $self      = shift;
    my $phenotype = $self->object;
    my $result;
    if ( $phenotype->Related_phenotypes(0) ) {
        foreach my $tag (qw/Specialisation_of Generalisation_of/) {
            ( my $type = $tag ) =~ s/_/ /g;
            my @entries;
            foreach my $ph ( $phenotype->$tag ) {
                push @entries,
                  {
                    id    => $ph,
                    label => $self->best_phenotype_name($ph),
                    class => 'Phenotype'
                  };
            }
            $result->{$type} = \@entries;
        }
    }
    return {
        description =>
"The generalized and specialized terms in the ontology for this phenotype.",
        data => $result,
    };
}

=head3 go_term

This method will return a data structure go terms annotating the phenotype.

=over

=item PERL API

 $data = $model->go_term();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/go_term

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub go_term {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->GO_term;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data'        => \@data_pack,
        'description' => 'go terms associated with phenotype'
    };
}

=head3 rnai

This method will return a data structure rnai experiments in which the phenotype was observed.

=over

=item PERL API

 $data = $model->rnai();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/rnai

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub rnai {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_rnai('RNAi');
    return {
        'data'        => $data_pack,
        'description' => 'rnais associated with this phenotype'
    };
}

=head3 rnai_not

This method will return a data structure with RNAi experiments in which the phenotype was not observed.

=over

=item PERL API

 $data = $model->rnai_not();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/rnai_not

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub rnai_not {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_rnai('Not_in_RNAi');
    return {
        'data'        => $data_pack,
        'description' => 'rnais not associated with this phenotype'
    };
}

=head3 variation

This method will return a data structure with variations in which the phenotype was observed.

=over

=item PERL API

 $data = $model->variation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/variation

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub variation {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_variation('Variation');
    return {
        'data'        => $data_pack,
        'description' => 'variations associated with this phenotype'
    };
}

=head3 variation_not

This method will return a data structure with variations in which the phenotype was not observed.

=over

=item PERL API

 $data = $model->variation_not();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/variation_not

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub variation_not {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_variation('Not_in_Variation');
    return {
        'data'        => $data_pack,
        'description' => 'variations not associated with this phenotype'
    };
}

=head3 transgene

This method will return a data structure with transgene experiments in which the phenotype was observed.

=over

=item PERL API

 $data = $model->transgene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/transgene

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transgene {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_transgene('Transgene');
    return {
        'data'        => $data_pack,
        'description' => 'transgenes associated with this phenotype'
    };
}

=head3 transgene_not

This method will return a data structure transgene experiments in which the phenotype was not observed.

=over

=item PERL API

 $data = $model->transgene_not();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/transgene_not

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transgene_not {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_transgene('Not_in_Transgene');
    return {
        'data'        => $data_pack,
        'description' => 'transgenes not associated with this phenotype'
    };
}

=head3 anatomy_ontology

This method will return a data structure anatomy_ontology terms associated with the phenotype via anatomy_function.

=over

=item PERL API

 $data = $model->anatomy_ontology();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Phenotype id (eg WBPhenotype:0000643)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/phenotype/WBPhenotype:0000643/anatomy_ontology

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub anatomy_ontology {
    my @anatomy_fns = shift ~~ 'Anatomy_function';
    my @data_pack;
    foreach my $anatomy_fn (@anatomy_fns) {
        my $anatomy_fn_name = $anatomy_fn->Involved  if $anatomy_fn;
        my $anatomy_term    = $anatomy_fn_name->Term if $anatomy_fn_name;
        my $anatomy_term_id = $anatomy_term->Name_for_anatomy_term
          if $anatomy_term;
        my $anatomy_term_name = $anatomy_term_id->Term if $anatomy_term_id;
        next unless ($anatomy_term_id);
        my $class = $anatomy_term_id->class;
        push @data_pack,
          {
            id    => "$anatomy_term_id",
            label => "$anatomy_term_name",
            class => "$class"
          };
    }
    return {
        'description' => "The Anatomy Ontology of the phenotype ",
        'data'        => \@data_pack
    };
}

sub rnai_json {
    return {
        description => 'RNAi experiments in which Phenotype is observed',
        data        => shift->_get_json_data('RNAi'),
    };
}

sub rnai_not_json {
    return {
        description => 'RNAi experiments in which Phenotype is not observed',
        data        => shift->_get_json_data('Not_in_RNAi'),
    };
}

sub variation_json {
    my $self = shift;
    return {
        description => "The related variation of the phenotype",
        data        => shift->_get_json_data('Variation'),
    };
}

sub variation_not_json {
    my $self = shift;
    return {
        description => "Variations in which the phenotype is not observed",
        data        => shift->_get_json_data('Not_in_Variation'),
    };
}

sub go_term_json {
    return {
        description => "The related Go term of the phenotype",
        data        => shift->_format_objects('GO_term'),
    };
}

sub transgene_json {
    return {
        description => "The related transgene of the phenotype ",
        data        => shift->_get_json_data('Transgene'),
    };
}

sub transgene_not_json {
    return {
        description =>
          "Transgene experiments in which phenotype is not observed ",
        data => shift->_get_json_data('Not_in_Transgene'),
    };
}

############################################################
#
# The Private Methods
#
############################################################

sub _transgene {
    my $self   = shift;
    my $tag    = shift;
    my $object = $self->object;
    my @data_pack;
    my @tag_objects = $object->$tag;

    foreach my $tag_object (@tag_objects) {
        my $tag_info = $self->_pack_obj($tag_object);
        push @data_pack, $tag_info;
    }
    return \@data_pack;
}

sub _variation {
    my $self   = shift;
    my $tag    = shift;
    my $object = $self->object;
    my @data_pack;
    my @tag_objects = $object->$tag;

    foreach my $tag_object (@tag_objects) {
        my $tag_info       = $self->_pack_obj($tag_object);
        my $variation_type = $tag_object->Variation_type;
        my $gene_info      = $self->_pack_obj( $tag_object->Possibly_affects )
          if $tag_object->Possibly_affects;
        my $species_info = $self->_pack_obj( $tag_object->Species )
          if $tag_object->Species;
        push @data_pack,
          {
            variation => $tag_info,
            gene      => $gene_info,
            type      => $tag_object->Variation_type,
            species   => $species_info
          };
    }
    return \@data_pack;
}

sub _rnai {
    my $self   = shift;
    my $tag    = shift;
    my $object = $self->object;
    my @data_pack;
    my @tag_objects = $object->$tag;

    foreach my $tag_object (@tag_objects) {
        my $tag_info      = $self->_pack_obj($tag_object);
        my $sequence      = $tag_object->Sequence;
        my $sequence_info = $self->_pack_obj( $tag_object->Sequence )
          if $tag_object->Sequence;
        my $species_info = $self->_pack_obj( $tag_object->Species )
          if $tag_object->Species;
        push @data_pack,
          {
            rnai     => $tag_info,
            sequence => $sequence_info,
            species  => $species_info
          };
    }
    return \@data_pack;
}

sub _get_json_data {
    my ( $self, $tag ) = @_;
    my $result;
    my $file = $self->tmp_acedata_dir() . "/" . $self->object . ".$tag.txt";
    if ( -s $file ) {
        open( F, "<$file" );
        $result = from_json(<F>);
        close F;
    }
    else {
        $result = $self->_format_objects($tag);
        open( F, ">$file" );
        print F to_json($result);
        close F;
    }
    return $result;
}

sub _format_objects {
    my ( $self, $tag ) = @_;
    my $phenotype = $self->object;
    my %result;
    my $is_not;
    my @items = $phenotype->$tag;
    my @content_array;
    my @content_array_not;
    foreach (@items) {
        my @array;
        my $str = $_;
        if ( $tag =~ m/rnai/i ) {
            my $cds  = $_->Predicted_gene || "";
            my $gene = $_->Gene;
            my $cgc  = eval { $gene->CGC_name } || "";
            if ($gene) {
                push @array,
                  {
                    id    => "$gene",
                    label => "$cgc",
                    class => $gene->class,
                  };
            }
            else { push @array, ""; }
            if ($cds) {
                push @array,
                  {
                    id    => "$cds",
                    label => "$cds",
                    class => $cds->class,
                  };
            }
            else {
                push @array, "";
            }
            if ( my $sp = $_->Species ) {
                $sp =~ /(.*) (.*)/;
                push @array,
                  {
                    genus   => $1,
                    species => $2,
                  };
            }
            else { push @array, ""; }

            #$is_not = _is_not($_,$phenotype);
            if ( $tag =~ m/not/i ) {
                $is_not = 0;
            }
            else {
                $is_not = 1;
            }
        }
        elsif ( $tag eq 'GO_term' ) {
            my $joined_evidence;
            my $desc = $_->Term || $_->Definition;
            $str =
                ( ($desc) ? "$desc" : "$str" )
              . ( ($joined_evidence) ? "; $joined_evidence" : '' );
        }
        elsif ( $tag =~ m/variation/i ) {    ##eq 'Variation'
                                             # $is_not = _is_not($_,$phenotype);
            if ( $tag =~ m/not/i ) {
                $is_not = 0;
            }
            else {
                $is_not = 1;
            }
            my $gene = $_->Gene;
            if ($gene) {
                push @array,
                  {
                    id    => "$gene",
                    label => $gene->Public_name->name,
                    class => $gene->class,
                  };
            }
            else { push @array, ""; }
            $str = $_->Public_name;
            if ( my $sp = $_->Species ) {
                $sp =~ /(.*) (.*)/;
                push @array,
                  {
                    genus   => $1,
                    species => $2,
                  };
            }
            else { push @array, ""; }
        }
        elsif ( $tag =~ m/transgene/i ) {    ## eq 'Transgene'
            my $genotype = $_->Summary || "";
            push @array, "$genotype";
            if ( $tag =~ m/not/i ) {
                $is_not = 0;
            }
            else {
                $is_not = 1;
            }
        }
        my %real_tags = (
            'Not_in_Variation' => 'Variation',
            'Not_in_Transgene' => 'Transgene'
        );
        my $real_tag;
        if ( $real_tags{$tag} ) {
            $real_tag = $real_tags{$tag};
        }
        else {
            $real_tag = $tag;
        }
        my $hash = {
            label => "$str",
            class => $real_tag,
            id    => "$_",
        };

        unshift @array, $hash;

        if ($is_not) {
            push @content_array_not, \@array;
        }
        else {
            push @content_array, \@array;
        }
    }
    if ( defined $is_not ) {
        $result{0}{"aaData"} = \@content_array;
        $result{1}{"aaData"} = \@content_array_not;
    }
    else {
        $result{"aaData"} = \@content_array;
    }
    return \%result;
}

sub _is_not {
    my ( $obj, $phene ) = @_;
    my @phenes = $obj->Phenotype;
    foreach (@phenes) {
        next unless $_ eq $phene;
        my %keys = map { $_ => 1 } $_->col;
        return 1 if $keys{Not};
        return 0;
    }
}

1;
