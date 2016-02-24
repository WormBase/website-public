package WormBase::API::Object::Wbprocess;

use XML::Simple;
use HTTP::Request;
use Moose;
use WormBase::API::Object::Gene qw/classification/;
use Switch;
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Interaction';
extends 'WormBase::API::Object';


=pod

=head1 NAME

WormBase::API::Object::WBProcess

=head1 SYNPOSIS

Model for the Ace ?WBProcess class.

=head1 URL

http://wormbase.org/species/*

=cut


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


#######################################
#
# The Genome Assemblies widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>




# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

#######################################
#
# The Overview widget
#
#######################################


sub related_process{
    my ($self) = @_;
    my $object = $self->object;

    my @topic_groups = $object->Related_topic;
    my %all_topics;

    foreach my $group (@topic_groups){

        my @topics = map {
        $self->_pack_obj($_)
        } $object->$group;

        $group =~ s/_/ /;
        $all_topics{ $group } = \@topics;
    }

    return {
        description => "Topics related to this record",
        data    => %all_topics ? \%all_topics : undef
    };
}

sub other_name{
    my ($self) = @_;
    my $object = $self->object;

    my $other_name = $object->Other_name;

    return {
        description => "Term alias",
        data => $other_name ? "$other_name" : undef
    };
}


# historical_gene { }
# This mehtod will return a data structure containing the
# historical reocrd of the dead gene originally associated with this Topic


sub historical_gene {
    my $self = shift;
    my $object = $self->object;

    my @historical_gene = map { {text => $self->_pack_obj($_),
                              evidence => $self->_get_evidence($_)} } $object->Historical_gene;
    return { description => 'Historical record of the dead genes originally associated with this topic',
             data        => @historical_gene ? \@historical_gene : undef,
    };
}

sub life_stage {
    my $self = shift;
    my $object = $self->object;

    my @life_stages = map { {text => $self->_pack_obj($_),
                              evidence => $self->_get_evidence($_)} } $object->Life_stage;
    return { description => 'Life stages associated with this topic',
             data        => @life_stages ? \@life_stages : undef,
    };
}

#######################################
#
# Genes widget
#
######################################

sub genes{
    my $self   = shift;
    my $object = $self->object;
    my @genes = $object->Gene;

    my @data;
    foreach my $gene (@genes) {
        my $type = WormBase::API::Object::Gene->
        classification($gene)->{data}->{type};

        unless ($gene->Anatomy_function){
            push @data, {
                name      => $self->_pack_obj($gene),
                type      => $type,
            };
        }
        foreach ($gene->Anatomy_function){
            my @bp_inv = map {
                my $ev = $self->_get_evidence($_);
                if ("$_" eq "$gene") {
                    my $term = $_->Term;
                    { text => $term && "$term", evidence => $ev};
                } else {
                    $ev ? { text => $self->_pack_obj($_), evidence => $ev} : $self->_pack_obj($_);
                }
            } $_->Involved;

            my @assay = map { my $as = $_->right;
                if ($as) {
                    my @geno = $as->Genotype;
                    {evidence => { genotype => join('<br /> ', @geno) },
                    text => "$_",}
                }
            } $_->Assay;

            my $pev = $self->_get_evidence($_->Phenotype);

            push @data, {
                name      => $self->_pack_obj($gene),
                type      => $type,
                phenotype => $pev ?
                    {    evidence => $pev,
                         text     => $self->_pack_obj(scalar $_->Phenotype)} : $self->_pack_obj(scalar $_->Phenotype),
                assay     => @assay ? \@assay : undef,
                bp_inv    => @bp_inv ? \@bp_inv : undef,
                reference => $self->_pack_obj(scalar $_->Reference),
            };
        }
    }

    return {
        description => 'genes found within this topic',
        data        => @data ? \@data : undef
    };
}

#######################################
#
# Expression Clusters Widget
#
#######################################

sub expression_cluster {
    my ($self) = @_;
    my $object = $self->object;
    my @e_clusters = $object->Expression_cluster;


    my @data;
    foreach my $e_cluster(@e_clusters){
        push @data, $self->_process_e_cluster($e_cluster);
    }

    return {
        description => "Expression cluster(s) related to this topic",
        data        => @data ? \@data : undef
    };

}
sub _process_e_cluster{
my ($self, $e_cluster) = @_;
my $desc = $e_cluster->Description;
my $evidence = $self->_get_evidence($e_cluster);

my %data = (
    id           => $self->_pack_obj($e_cluster),

    evidence        => {
            evidence => $evidence,
            text     => $desc
        }
);

return \%data;
}

#######################################
#
# Interactions widget
#
#######################################

sub interaction {
    my ($self) = @_;
    my $object = $self->object;
    my @interactions = $object->Interaction;


    my @data;
    foreach my $interaction (@interactions){
        push @data, $self->_process_interaction($interaction);
    }

    return {
        description => "Interactions relating to this topic",
        data        => @data ? \@data : undef
    };

}
sub _process_interaction{
    my ($self, $interaction) = @_;
    my $type = $interaction->Interaction_type;
    my $summary = $interaction->Interaction_summary;

    my $log = $self->log;

    # Interactors
    # Different case for each kind of interaction
    my @interactors;
    my $interactor_type = $interaction->Interactor;
    switch ($interactor_type->name) {
        case("Interactor_overlapping_gene"){
            my @interacting_genes = $interaction->Interactor_overlapping_gene;
            foreach my $gene_obj (@interacting_genes){
                push (@interactors, $self->_pack_obj($gene_obj));
            }
        }
    }


    my %data = (
        type        => $type,
        summary     => $summary,
        interactors => \@interactors
    );

    return \%data;
}


#######################################
#
# GO widget
#
#######################################



sub go_term{
    my ($self) = @_;
    my $object = $self->object;
    my @go_objs = $object->GO_term;

    my @data;

    foreach my $go_obj ( @go_objs ){
        my $type    = $go_obj->Type;
        my $def     = $go_obj->Definition;

        push @data, {
            name    => $self->_pack_obj($go_obj),
            type    => "$type",
            def     => "$def"
        };
    }

    return {
        description => "Gene Ontology Term",
        data => \@data
    };

}

#######################################
#
# Pathways widget
#
#######################################

sub pathway{
    my ($self) = @_;
    my $object = $self->object;
    my $pathway = $object->Pathway;
    my $data;
    my @data;

    if($pathway){
        my @row = $pathway->row;
        my @pathway_ids;

        @pathway_ids = $object->at('Pathway.DB_info.Database.WikiPathways.Pathway');

        foreach my $id (@pathway_ids){
            my $revision;
            my $url = "http://www.wikipathways.org/wpi/webservice/webservice.php/getCurationTagsByName?tagName=Curation:WormBase_Approved";
            my $req = HTTP::Request->new(GET => $url);
            my $lwp       = LWP::UserAgent->new;
            my $response  = $lwp->request($req);
            my $response_content = $response->content;

            my $xml_file = XMLin($response_content);
            my @tags = @{ ($xml_file->{'ns1:tags'})[0] };
            foreach(@tags){
                if($_->{'ns2:pathway'}->{'ns2:id'} eq "$id"){
                    $revision = $_->{'ns2:pathway'}->{'ns2:revision'};
                }
            }
            $data = {
                pathway_id      => "$id",
                revision        => $revision
            };

            push @data, $data;

        }

    }

    return {
        description => "Related wikipathway link",
        data => @data ? \@data : undef,
    };

}



#######################################
#
# Phenotypes widget
#
#######################################

# sub phenotypes { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>



#######################################
#
# Anatomy widget
#
#######################################

sub anatomy_term {
    my $self = shift;
    my $object = $self->object;
    my @data;
    foreach my $anatomy_term ($object->Anatomy_term){
        my $description = $anatomy_term->Definition;
        push @data, {
            anatomy_term => {text => $self->_pack_obj($anatomy_term), evidence => $self->_get_evidence($anatomy_term)},
            description => $description && "$description",
        }
    }
    return {
        description => "Anatomy terms related to this topic",
        data => @data ? \@data : undef
    }
}

#######################################
#
# Molecule widget
#
#######################################
sub molecules {
    my $self = shift;
    my $object = $self->object;
    my @data;
    foreach my $molecule ($object->Molecule){
        push @data, {text => $self->_pack_obj($molecule), evidence => $self->_get_evidence($molecule)};
    }
    return {
        description => "Molecules related to this topic",
        data => @data ? \@data : undef
    }
}

############################################################
#
# PRIVATE METHODS
#
############################################################

__PACKAGE__->meta->make_immutable;

1;
