package WormBase::API::Role::Object;

use Moose::Role;
use File::Path 'mkpath';
use WormBase::API::ModelMap;

# I should have an abstract method for id():
# provided with a class and a name, return the internal ID, if different.

# TODO:
# Synonym (other_name?)
# DONE (mostly): Database and DB_Info parsing
# Titles / description / definition
# Phenotypes observed/not_observed
# Where do hashtables (used for decisions) go? See _common_name()

#######################################################
#
# Attributes. Some of these aren't really Object Roles.
#
#######################################################

# NECESSARY?
#has 'MAX_DISPLAY_NUM' => (
#    is      => 'ro',
#    default => 10,
#);

has 'object' => (
    is  => 'rw',
    isa => 'Ace::Object',
);

has 'dsn' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

has 'log' => (
    is => 'ro',
);

has 'tmp_base' => (
    is => 'ro',
);


has 'pre_compile' => (
    is => 'ro',
);


# Set up our temporary directory (typically outside of our application)
sub tmp_dir {
    my $self = shift;
    my @sub_dirs = @_;
    my $path = File::Spec->catfile($self->tmp_base, @sub_dirs);

    mkpath($path, 0, 0777) unless -d $path;
    return $path;
}



#######################################################
#
# Generic methods, shared across Ace classes.
#
#######################################################

################
#  Names
################

=head3 name

This method will return a data structure of the
name and ID of the requested object.

=over

=item PERL API

 $data = $model->name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/name

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% name %]

has 'name' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_name',
);

sub _build_name {
    my ($self) = @_;
    my $object = $self->object;
#    my $class  = $object->class;
    return {
        description => "The name and WormBase internal ID of $object",
        data        =>  $self->_pack_obj($object),
    };
}

has '_common_name' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build__common_name',
);

sub _build__common_name {
    my ($self) = @_;
    return $self->_make_common_name($self->object);
}

sub _make_common_name {
    my ($self, $object) = @_;
    my $class  = $object->class;

	my $name;

    my $WB2ACE_MAP = WormBase::API::ModelMap->WB2ACE_MAP;
    if (my $tag = $WB2ACE_MAP->{common_name}->{$class}) {
        $tag = [$tag] unless ref $tag;
        foreach my $tag (@$tag) {
            last if $name = eval{ $object->$tag };
        }
    }

    if (!$name and
        my $wbclass = WormBase::API::ModelMap->ACE2WB_MAP->{fullclass}->{$class}) {
        if ($wbclass->meta->get_method('_build__common_name')
            ->original_package_name ne __PACKAGE__) {
            # this has potential for circular dependency...
            $self->log->debug("$class has overridden _build_common_name");
            $name = $self->_wrap($object)->_common_name;
        }
    }

	$name //= $object->name;
    return "$name";
}

=head3 other_names

This method will return a data structure containing
other names that have been used to refer to the object.

=over

=item PERL API

 $data = $model->other_names();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and an object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/other_names

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% other_names %]

has 'other_names' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_other_names',
);

sub _build_other_names {
    my ($self) = @_;
    my $object = $self->object;
    my @names  = $object->Other_name;

    # We will just stringify other names; no sense in linking them.
    @names = map { "$_" } @names;
    return {
        description => "other names that have been used to refer to $object",
        data        => @names ? \@names : undef
    };
}

=head3 best_blastp_matches

This method returns a data structure containing
the best BLASTP matches for the current gene or protein.

=over

=item PERL API

 $data = $model->best_blastp_matches();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class of gene or protein and a gene
or protein ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[GENE|PROTEIN]/[OBJECT]/best_blastp_matches

=head5 Response example

=cut

# Template: [% best_blastp_matches %]

has 'best_blastp_matches' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_best_blastp_matches',
);

# Fetch all of the best_blastp_matches for a list of proteins.
# Used for genes and proteins
sub _build_best_blastp_matches {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;

    my $proteins;
    # Only for genes or proteins.
    if ($class eq 'Gene') {
        $proteins = $self->all_proteins;
    }
    elsif ($class eq 'Protein') {
        # current_object might already be a protein.
        $proteins = [$self->object] unless $proteins;
    } else { }

#        return {
#            description => 'no proteins found, no best blastp hits to display',
#            data        => undef,
#        };
#    }
    
    if (@$proteins == 0) {
	return { description => 'no proteins found, no best blastp hits to display',
		 data        => undef,
	};
    }
    
    my ($biggest) = sort {$b->Peptide(2)<=>$a->Peptide(2)} @$proteins;

    my @pep_homol = $biggest->Pep_homol;
    my $length    = $biggest->Peptide(2);

    my @hits;

    # find the best pep_homol in each category
    my %best;
    return "" unless @pep_homol;
    for my $hit (@pep_homol) {
        # Ignore mass spec hits
        #     next if ($hit =~ /^MSP/);
        next if $hit eq $biggest;    # Ignore self hits
        my ($method, $score) = $hit->row(1) or next;

        my $prev_score = (!$best{$method}) ? $score : $best{$method}{score};
        $prev_score = ($prev_score =~ /\d+\.\d+/) ? $prev_score . '0'
                                                  : "$prev_score.0000";
        my $curr_score = ($score =~ /\d+\.\d+/) ? $score . '0'
                                                : "$score.0000";

        $best{$method} =
          {score => $score, hit => $hit, adjusted_score => $curr_score}
          if !$best{$method} || $prev_score < $curr_score;
    }

    foreach (values %best) {
        my $covered = $self->_covered($_->{score}->col);
        $_->{covered} = $covered;
    }

    # NOT HANDLED YET
    # my $links = Configuration->Protein_links;

    my %seen;  # Display only one hit / species

    # I think the perl glitch on x86_64 actually resides *here*
    # in sorting hash values.  But I can't replicate this outside of a
    # mod_perl environment
    # Adding the +0 forces numeric context
    my $id = 0;
    foreach (sort {$best{$b}{adjusted_score} + 0 <=> $best{$a}{adjusted_score} + 0} keys %best)
    {
        my $method = $_;
        my $hit    = $best{$_}{hit};

        # Try fetching the species first with the identification
        # then method then the embedded species
        my $species = $self->id2species($hit);
        $species ||= $self->id2species($method);

        # Not all proteins are populated with the species
        $species ||= $best{$method}{hit}->Species;
        $species =~ s/^(\w)\w* /$1. /;
        my $description = $best{$method}{hit}->Description
          || $best{$method}{hit}->Gene_name;
        my $class;

       # this doesn't seem optimal... maybe there should be something in config?
        if ($method =~ /worm|briggsae|remanei|japonica|brenneri|pristionchus/) {
            $description ||= eval {
                $best{$method}{hit}->Corresponding_CDS->Brief_identification;
            };

            # Kludge: display a description using the CDS
            if (!$description) {
                for my $cds (eval {$best{$method}{hit}->Corresponding_CDS}) {
                    next if $cds->Method eq 'history';
                    $description ||= "gene $cds";
                }
            }
            $class = 'protein';
        }
        next if ($hit =~ /^MSP/);
        $species =~ /(.*)\.(.*)/;
        my $taxonomy = {genus => $1, species => $2};

        #     next if ($seen{$species}++);
        my $id;
        if ($hit =~ /(\w+):(.+)/) {
            my $prefix    = $1;
            my $accession = $2;
            $id    = $accession unless $class;
            $class = $prefix    unless $class;

            # Try fetching accessions directly from the protein object
            #       my @dbs = $hit->Database;
            #       foreach my $db (@dbs) {
            # 	if ($db eq 'FLYBASE') {
            # 	  foreach my $col ($db->col) {
            # 	    if ($col eq 'FlyBase_gn') {
            # 	      $accession = $col->right;
            # 	      last;
            # 	    }
            # 	  }
            # 	}
            #       }

	    # NOT HANDLED YET!
#      my $link_rule = $links->{$prefix};
#       my $link_rule = '%s';
#       my $url       = sprintf($link_rule,$accession);
	    # TH: 1/2006 - remanei not yet in the database but blast hits available
	    # Generate links to the remanei browser
	    # This will not work for mirror sites, of course...
#       if ($species =~ /remanei/) {
# 	$accession =~ s/^RP://;
# 	$hit = qq{<a href="http://dev.wormbase.org/db/seq/gbrowse/remanei/?name=$accession"</a>$accession</a>};
# 	$hit .= qq{<br><i>Note: <b>C. remanei</b> predictions are based on an early assembly of the genome. Predictions subject to possibly dramatic revision pending final assembly. Sequences available on the <a href="ftp://ftp.wormbase.org/pub/wormbase/genomes/remanei">WormBase FTP site</a>.};
#       } else {
# 	$hit = qq{<a href="$url" -target="_blank">$hit</a>};
#       }
	}

#       $hits{$hit}{species}=$species;
#       $hits{$hit}{hit}=$hit;
#       $hits{$hit}{description}=$description;
#       $hits{$hit}{evalue}=sprintf("%7.3g",10**-$best{$_}{score});
#       $hits{$hit}{plength}=sprintf("%2.1f",100*($best{$_}{covered})/$length);
=pod
	    $hits{species}{$id}=$species;
        $hits{hit}{$id}={label=>$hit,id=>$hit,class=>'protein'};
        $hits{description}{$id}=$description;
        $hits{evalue}{$id}=sprintf("%7.3g",10**-$best{$_}{score});
        $hits{plength}{$id}=sprintf("%2.1f%%",100*($best{$_}{covered})/$length);
	$id++;

=cut

        push @hits, {
            taxonomy => $taxonomy,
            hit      => {
                label => "$hit",
                id    => ($id ? "$id" : "$hit"),
                class => $class
            },
            description => "$description",
            evalue      => sprintf("%7.3g", 10**-$best{$_}{score}),
            percent     => sprintf("%2.1f%%", 100 * ($best{$_}{covered}) / $length),
        };

#[$taxonomy,{label=>"$hit",id=>($id ? "$id" : "$hit"),class=>$class},"$description",
#  		sprintf("%7.3g",10**-$best{$_}{score}),
# 		sprintf("%2.1f%%",100*($best{$_}{covered})/$length)];
    }

    return {
        description => 'best BLASTP hits from selected species',
        data        => @hits ? \@hits : undef
    };
}



=head3 central_dogma

This method will return a data structure containing
the central dogma from the perspective of the supplied
(gene|transcript|cds|protein)

=over

=item PERL API

  $data = $model->central_dogma();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/central_dogma

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% central_dogma %]

has 'central_dogma' => (
    is         => 'ro',
    lazy_build => 1,
);


sub _build_central_dogma {
    my $self   = shift;
    my $object = $self->object;
    my $class  = $object->class;
   
    # Need to get the root element, a gene.
    my $gene;
    if ($class eq 'Gene') {
	$gene = $object;
    } elsif ($class eq 'CDS') {
	$gene = $object->Gene;
    } elsif ($class eq 'Protein') {
	my %seen;
	my @cds = grep { $_->Method ne 'history' } $object->Corresponding_CDS;
	$gene = $cds[0]->Gene if $cds[0];
    } else {
    }
    unless ($gene) {
    return { description => 'the central dogma from the perspective of this protein',
         data        => undef };
    }

    my $gff = $self->gff_dsn || return { description => 'the central dogma from the perspective of this protein',
         data        => undef };
        
    my %data;    
    $data{gene} = $self->_pack_obj($gene);

    foreach my $cds ($gene->Corresponding_CDS) {
	my $protein = $cds->Corresponding_protein;

	my $transcript = $cds->Corresponding_transcript;
	
	# Fetch the intron/exon sequences from GFF
#	my ($seq_obj) = sort {$b->length<=>$a->length}
#	grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => $transcript);
	
    eval {$gff->fetch_group()}; return if $@;
	my ($seq_obj) = $gff->fetch_group(Transcript => $transcript);
	
#	$self->log->debug("seq obj: " . $seq_obj);
	$seq_obj->ref($seq_obj); # local coordinates
	# Is the genefinder specific formatting cruft?
	my %seenit;
	my @features =
	    sort {$a->start <=> $b->start}
	grep { $_->info eq $cds && !$seenit{$_->start}++ }
	$seq_obj->features(qw/five_prime_UTR:Coding_transcript exon:Pseudogene coding_exon:Coding_transcript three_prime_UTR:Coding_transcript/);
	my @exons;
	foreach (@features) {
	    push @exons, { start => $_->start,
			   stop  => $_->stop,
			   seq   => $_->dna };
	}
	
	push @{$data{gene_models}},{ cds     => $self->_pack_obj($cds),
				     exons   => \@exons,
				     protein => $self->_pack_obj($protein)
	};
    }
    
    return { description => 'the central dogma from the perspective of this protein',
	     data        => \%data };
}




# the following is a candidate for retrofitting with ModelMap
sub _build_central_dogma2 {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $data;

    my $gene;
    # Need to get the root element, a gene.
    if ($class eq 'Gene') {
	$gene = $object;
    } elsif ($class eq 'CDS') {
	$gene = $object->Gene;
    } elsif ($class eq 'Protein') {
	my %seen;
	my @genes = grep { ! $seen{%_}++ } map { $_->Gene } grep{ $_->Method ne 'history'}  $object->Corresponding_CDS;
	$gene = $genes[0];
    }
    
    # Transcripts
    my @transcripts = $gene->Corresponding_transcript;
    
    # Each transcript has one or more CDS
    foreach my $transcript (@transcripts) {
	my @cds = $transcript->Corresponding_CDS;

	foreach my $cds (@cds) {
	    my @proteins = map { $self->_pack_obj($_) } $cds->Corresponding_protein;
	    push @{$data->{transcripts}},{ transcript => $self->_pack_obj($transcript),
					   cds        => $self->_pack_obj($cds),
					   proteins   => \@proteins,
	    };
	}
    }
    
    $data->{gene} = $self->_pack_obj($gene);

    return {
        description => "the central dogma of the current object",
        data        => $data,
    };
}


=head3 description

This method will return a data structure containing
a brief description of the object.

=over

=item PERL API

  $data = $model->description();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/description

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% description %]

has 'description' => (
    is         => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_description',
);

# the following is a candidate for retrofitting with ModelMap
sub _build_description {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $tag;
    if ($class eq 'Sequence') {
        $tag = 'Title';
    }
    elsif ($class eq 'Expr_pattern') {
        $tag = 'Pattern'; # does nto handle Mohler movies (~~ 'Author' =~ /Mohler/)
    }
    else {
        $tag = 'Description';
    }
    # do many models have multiple description values?
    my $description = eval {join(' ', $object->$tag)} || undef;

    return {
        description => "description of the $class $object",
        data        => $description && "$description",
    };

    ## deal with evidence... ?
    #    my $data = { description => "description of the $class $object",
    #		 data        => { description => $description ,
    #				  evidence    => { check=>$self->check_empty($description),
    #						   tag=>"Description",
    #				  },
    #		 }
    #    };
    #   return $data;

}

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

    foreach ($object->Expr_pattern) {
        my $author = $_->Author;
        my @patterns = $_->Pattern
            || $_->Subcellular_localization
            || $_->Remark;

	my $gene      = $_->Gene;
	my $transgene = $_->Transgene; 
        push @data, {
            expression_pattern => $self->_pack_obj($_),
            description        => join("<br />", @patterns) || undef,
            author             => $author && "$author",
	    gene               => $self->_pack_obj($gene),
#	    transgene          => $self->_pack_obj($transgene);
        };
    }

    return {
        description => "expression patterns associated with the $class:$object",
        data        => @data ? \@data : undef
    };
}

=head3 laboratory

This method returns a data structure containing
the lab affiliation or origin of the requested object,
as well as the current lab representative.

=over

=item PERL API

 $data = $model->laboratory();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/laboratory

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% laboratory %]

has 'laboratory' => (
    is         => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_laboratory',
);

# laboratory: Whenever a cross-ref to lab is needed.
# Returns the lab as well as the current representative.
# Used in: Person, Gene_class, Transgene
# template: shared/fields/laboratory.tt2
sub _build_laboratory {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;    # Ace::Object class, NOT ext. model class

    my $WB2ACE_MAP = WormBase::API::ModelMap->WB2ACE_MAP->{laboratory};

    my $tag = $WB2ACE_MAP->{$class} || 'Laboratory';
    my $data; # trick: $data is undef until following code derefs it like hash (or not)!
    if (my $lab = eval {$object->$tag}) {
        $data->{laboratory} = $self->_pack_obj($lab);

        my $representative = $lab->Representative;
        my $name           = $representative->Standard_name;
        my $rep            = $self->_pack_obj($representative, $name);
        $data->{representative} = $rep if $rep;
    }

    return {
        description => "the laboratory where the $class was isolated, created, or named",
        data        => $data,
    };
}

=head3 method

This method will return a data structure containing
the method used to describe or determine the object.

=over

=item PERL API

 $data = $model->method();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/method

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% method %]

has 'method' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_method',
);

# The method used to describe the object
sub _build_method {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $method = $object->Method; # TODO: expand on this by pulling data from ?Method?

    return {
        description => "the method used to describe the $class",
        data        => $method && "$method",
    };
}

=head3 phenotypes

This method will return phenotypes associated with the object.

=over

=item PERL API

 $data = $model->phenotypes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/phenotypes

B<Response example>

<div class="response-example"></div>

=back

=cut 

has 'phenotypes' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_phenotypes',
);

## method to build data

sub _build_phenotypes {	
	my $self = shift;
	my $data = $self->_build_phenotypes_data('Phenotype'); 	
	return {
		data => $data,
		description =>'phenotypes annotated with this term',
	};
}

=head3 phenotypes_not_observed

This method will return a data structure containing
phenotypes specifically NOT observed in the object (RNAi, Variation, etc).

=over

=item PERL API

 $data = $model->phenotypes_not_observed();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001), a Variation ID (eg WBVar001441331), etc.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/phenotypes_not_observed

B<Response example>

<div class="response-example"></div>

=back

=cut 

has 'phenotypes_not_observed' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_phenotypes_not_observed',
);


sub _build_phenotypes_not_observed {
	my $self = shift;
	my $data = $self->_build_phenotypes_data('Phenotype_not_observed'); 	
	return {
		data => $data,
		description =>'phenotypes NOT observed or associated with this object' };
}

sub _build_phenotypes_data {
    my $self = shift;
    my $tag = shift;
    my $object = $self->object;
    my @data;
    foreach my $phenotype ($object->$tag) {
        my $description = $phenotype->Description;
	my $remarks     = $phenotype->Remark;
	push @data, { 
	    phenotype   => $self->_pack_obj($phenotype),
	    description => "$description", 
	    remarks     => "$remarks" };
    }
    return @data ? \@data : undef;
}


# TH: This was pulled (and still exists) in Variation.pm.
# It should be folded into _build_phenotypes_data above.
# Once complete, the varaition/phenotypes.tt2 template can (probably) be deleted.
# See also the phenotype processing in Gene.pm
sub _pull_phenotype_data {
    my ($self, $phenotype_tag) = @_;
    my $object = $self->object;

    my @phenotype_data; ## return data structure contains set of : not, phenotype_id; array ref for each characteristic in each element

        #my @phenotype_tags = ('Phenotype', 'Phenotype_not_observed');
        #foreach my $phenotype_tag (@phenotype_tags) {
    my @phenotypes = $object->$phenotype_tag;

    foreach my $phenotype (@phenotypes) {
        my %p_data; ### data holder for not, phenotype, remark, and array ref of characteristics, loaded into @phenotype_data for each phenotype related to the variation.
        my @phenotype_subtags = $phenotype->col ; ## 0

        my @psubtag_data;
        my @ps_data;

        my %tagset = (
            'Paper_evidence' => 1,
            'Remark' => 1,
            #                   'Person_evidence' => 1,
            #             'Phenotype_assay' => 1,
            #             'Penetrance' => 1,
            #             'Temperature_sensitive' => 1,
            #             'Anatomy_term' => 1,
            #             'Recessive' => 1,
            #             'Semi_dominant' => 1,
            #             'Dominant' => 1,
            #             'Haplo_insufficient' => 1,
            #             'Loss_of_function' => 1,
            #             'Gain_of_function' => 1,
            #             'Maternal' => 1,
            #             'Paternal' => 1

	    ); ### extra data commented out off data pull system 20090922 to simplify table build and data pull

        my %extra_tier = (
            Phenotype_assay       => 1,
            Temperature_sensitive => 1,
            # Penetrance => 1,
	    );

        my %gof_set = (
            Gain_of_function => 1,
            Maternal         => 1,
            # Paternal => 1,
	    );

        my %no_details = (
            Recessive          => 1,
            Semi_dominant      => 1,
            Dominant           => 1,
            Haplo_insufficient => 1,
            Paternal           => 1,
            # Loss_of_function => 1,
            # Gain_of_function => 1,
	    );

        foreach my $phenotype_subtag (@phenotype_subtags) {
	    if (!($tagset{$phenotype_subtag})) {
		next;
	    }
	    else {
		my @ps_column = $phenotype_subtag->col;

                                ## data to be incorporated into @ps_data;

		my $character;
		my $remark;
		my $evidence_line;

                                ## process Penetrance data
		if ($phenotype_subtag =~ m/Penetrance/) {
                    foreach my $ps_column_element (@ps_column) {
                        if ($ps_column_element =~ m/Range/) {
                            next;
                        }
                        else {
                            my ($char,$text,$evidence) = $ps_column_element->row;
                            my @pen_evidence = $evidence-> col;
                            $character = "$phenotype_subtag"; #\:
                            $remark = $char;                  #$text

                            my @pen_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @pen_evidence}; # ;

                            $evidence_line =  join "; ", @pen_links;
                        }
                    }
		}
		elsif ($phenotype_subtag =~ m/Remark/) { # get remark
                    my @remarks = $phenotype_subtag->col;
                    my $remarks = join "; ", @remarks;
                    my $details_url = "/db/misc/etree?name=$phenotype;class=Phenotype";
                    my $details_link = qq(<a href="$details_url">[Details]>);
                    $remarks = "$remarks\ $details_link";
                    $p_data{'remark'} = $remarks; #$phenotype_subtag->right
                    next;
		}
		elsif ($phenotype_subtag =~ m/Paper_evidence/) { ## get evidences
                    my @phenotype_paper_evidence = $phenotype_subtag->col;
                    my @phenotype_paper_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @phenotype_paper_evidence}; #;
                    $p_data{'paper_evidence'} = join "; ", @phenotype_paper_links;
                    next;
		}
		elsif ($phenotype_subtag =~ m/Anatomy_term/) { ## process Anatomy_term data
                    my ($char,$text,$evidence) = $phenotype_subtag ->row;
                    my @at_evidence = $phenotype_subtag -> right -> right -> col;

                    # my $at_link;
                    my $at_term = $text->Term;
                    my $at_url = "/db/ontology/anatomy?name=" . $text;
                    my $at_link = a({-href => $at_url}, $at_term);

                    $character = $char;
                    $remark = $at_link; #$text

                    my @at_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @at_evidence}; #;

                    $evidence_line = join "; ", @at_links;

		}
		elsif ($phenotype_subtag =~ m/Phenotype_assay/) { ## process extra tier data
                    foreach my $character_detail (@ps_column) {
                        my $cd_info = $character_detail->right; # right @cd_info
                        my @cd_evidence = $cd_info->right->col;
                        $character = "$character_detail"; #$phenotype_subtag\:
                        # = $cd_info->col;
                        $remark =  $cd_info; # join "; ", @cd_info;

                        my @cd_links= eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @cd_evidence }; #  ;

                        $evidence_line = join "; ", @cd_links;

                        my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
                        push  @ps_data, $phenotype_st_line ;
                    }
                    next;
		}
		elsif ($phenotype_subtag =~ m/Temperature_sensitive/) {
		    foreach my $character_detail (@ps_column) {
                        my $cd_info = $character_detail->right;
                        my @cd_evidence = $cd_info->right->col;

                        my @cd_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @cd_evidence }; #  ;

                        $character = "$character_detail"; #$phenotype_subtag\:
                        $remark = $cd_info;
                        $evidence_line = join "; ", @cd_links ;

                        my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
                        push  @ps_data, $phenotype_st_line ;
                    }

                    next;
		}
		elsif ( $phenotype_subtag =~ m/Gain_of_function/) { # $gof_set{}
                    my ($char,$text,$evidence) = $phenotype_subtag->row;
                    my @gof_evidence;

                    eval{
                        @gof_evidence = $evidence-> col;
                    };
                    #\:
                    $remark = $text; #$char

                    if (!(@gof_evidence)) {
                        $character = $phenotype_subtag;
                        $remark = '';
                        $evidence_line = $p_data{'paper_evidence'};
                    }
                    #my @pen_links = map {format_reference(-reference=>$_,-format=>'short');} @pen_evidence;
                    else {
                        $character = $phenotype_subtag;
                        $remark = $char;
                        my @gof_paper_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @gof_evidence}; #  ;

                        $evidence_line =  join "; ", @gof_paper_links;
                    }
                    my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
                    push  @ps_data, $phenotype_st_line ;
                    next;
		}
		elsif ( $phenotype_subtag =~ m/Loss_of_function/) { # $gof_set{}
                    my ($char,$text,$evidence) = $phenotype_subtag->row;
                    my @lof_evidence;

                    eval{
                        @lof_evidence = $evidence-> col;
                    };
                    #\:
                    $remark = $text; #$char

                    if (!(@lof_evidence)) {
                        $character = $phenotype_subtag;
                        $remark = $text;
                        $evidence_line = $p_data{'paper_evidence'};
                    }
                    #my @pen_links = map {format_reference(-reference=>$_,-format=>'short');} @pen_evidence;
                    else {
                        $character = $phenotype_subtag;
                        $remark = $text;
                        my @lof_paper_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @lof_evidence}; ; #

                        $evidence_line =  join "; ", @lof_paper_links;
                    }
                    my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
                    push  @ps_data, $phenotype_st_line ;
                    next;

		}
		elsif ( $phenotype_subtag =~ m/Maternal/) { # $gof_set{}
                    my ($char,$text,$evidence) = $phenotype_subtag->row;

                    my @mom_evidence;

                    eval {

                        @mom_evidence = $evidence->col;

                    };

                    if (!(@mom_evidence)) {
                        $character = $phenotype_subtag;
                        $remark = '';
                        $evidence_line = $p_data{'paper_evidence'};
                    }
                    else {
                        $character = $phenotype_subtag;
                        $remark = '';
                        my @mom_paper_links = eval{map {format_reference(-reference=>$_,-format=>'short') if $_;} @mom_evidence} ; #;
                        $evidence_line =  join "; ", @mom_paper_links;

                    }

                    my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
                    push  @ps_data, $phenotype_st_line ;
                    next;
		}
		elsif ($no_details{$phenotype_subtag}) { ## process no details data
                    my @nd_evidence;
                    eval {
                        @nd_evidence = $phenotype_subtag->right->col;
                    };

                    $character = $phenotype_subtag;
                    $remark = "";
                    if (@nd_evidence) {

                        my @nd_links = eval{map {format_reference(-reference=>$_,-format=>'short') if $_;} @nd_evidence ; }; #

                        $evidence_line = join "; ", @nd_links;
                    }
		}

		my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
		push  @ps_data, $phenotype_st_line ; ## let @ps_data evolve to include characteristic; remarks; and evidence line
	    }

        }

        #my $phenotype_url = Object2URL($phenotype);
        #my $phenotype_link = b(a({-href=>$phenotype_url},$phenotype_name));


        if ($phenotype_tag eq 'Phenotype_not_observed') {
            $p_data{not} = 1;
        }

        $p_data{phenotype} = $self->_pack_obj($phenotype);

        $p_data{ps} = @ps_data ? \@ps_data : undef;

        push @phenotype_data, \%p_data;
    }

    return {
        description => 'Phenotypes for this variation',
        data        => @phenotype_data ? \@phenotype_data : undef,
    };
}








=head3 references

Currently, the WormBase web app uses a custom search
to retrieve references. This method will return 
references directly cross-referenced to the current
object.

=over

=item PERL API

 $data = $model->references();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/references

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: Currently none. Method provided for API users.

has 'references' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_references',
);


sub _build_references {
    my $self   = shift;
    my $object = $self->object;
    # Could also use ModelMap...
    my $tag = (eval {$object->Reference}) ? 'Reference' : 'Paper';
    my $data = $self->_pack_objects($object->$tag);
    return { description => 'references associated with this object',
	     data        => %$data ? $data : undef };
}

=head3 remarks

This method will return a data structure containing
curator remarks about the requested object.

=over

=item PERL API

 $data = $model->remarks();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/remarks

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% remarks %]

has 'remarks' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_remarks',
);

sub _build_remarks {
    my ($self) = @_;
    my $object = $self->object;

    #    my @remarks = grep defined, map { $object->$_} qw/Remark/;
    my @remarks = $object->Remark;
    my $class   = $object->class;

    # Need to add in evidence handling.
    my @evidence = map {$_->col} @remarks;

    @remarks = map {"$_"} @remarks; # stringify them

    # TODO: handling of Evidence nodes
    return {
        description => "curatorial remarks for the $class",
        data        => @remarks ? \@remarks : undef,
    };
}

=head3 summary

This method will return a data structure containing
a brief summary of the requested object.

=over

=item PERL API

 $data = $model->summary();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/summary

B<Response example>

<div class="response-example"></div>

=back

=back

=cut

# Template: [% summary %]

has 'summary' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_summary',
);

sub _build_summary {
    my ($self)  = @_;
    my $object  = $self->object;
    my $class   = $object->class;
    my $summary = $object->Summary;

    return {
        description => "a brief summary of the $class:$object",
        data        => $summary && "$summary",
    };
}

=head3 status

This method will return a data structure containing
the current status of the object.

=over

=item PERL API

 $data = $model->status();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/status

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% status %]

has 'status' => (
    is       => 'ro',
    lazy     => 1,
    required => 1,
    builder  => '_build_status',
);

sub _build_status {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $status = $class eq 'Protein' ? ($object->Live ? 'live' : 'history')
	: (eval{$object->Status} ? $object->Status : 'unverified');

    return {
        description => "current status of the $class:$object",
        data        => $status && "$status",
    };
}

=head3 taxonomy

This method will return a data structure containing
the genus and species of the requested object.

=over

=item PERL API

 $data = $model->taxonomy();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a class and object ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/taxonomy

B<Response example>

<div class="response-example"></div>

=back

=cut

# Template: [% taxonomy %]

has 'taxonomy' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_taxonomy',
);

# Parse out species "from a Genus species" string.
sub _build_taxonomy { # this overlaps with parsed_species
    my ($self) = @_;

    my ($genus, $species) = (($self ~~ 'Species') =~ /(.*) (.*)/);
    # TODO: what if $self ~~ 'Species' is undef?

    return {
        description => 'the genus and species of the current object',
        data        => $genus && $species && {
            genus   => $genus,
            species => $species,
        },
    };
}

=head3 xrefs

This method will return a data structure containing
external database cross-references for the requested object.

=over

=item Perl API

 $data = $model->xrefs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A class and object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/CLASS/OBJECT/xrefs

B<Response example>

<div class="response-example"></div>

=cut

# template [% xrefs %]

has 'xrefs' => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_xrefs',
);

# XREFs are stored under the Database tag.
sub _build_xrefs {
    my ($self) = @_;
    my $object = $self->object;

    my @databases = $object->Database;
    my %dbs;
    foreach my $db (@databases) {	
        my $name            = $db->Name || "$db";
        my $description     = $db->Description;
        my $url             = $db->URL;
        my $url_constructor = $db->URL_constructor;
        my $email           = $db->Email;
        my $remote_text     = $db->right(1);

        # Possibly multiple entries for a single DB
        my @ids = map {
            my @types = $_->col;
            @types ? map { "$_" } @types : eval { $_->right->name } ;
        } $db->col;

        $dbs{$db} = {
            name            => "$name",
            description     => "$description",
            url             => "$url",
            url_constructor => "$url_constructor",
            email           => "$email",
            ids             => \@ids,
            label           => "$remote_text"
        };
    }

    # ?Analysis has a separate URL tag.
    #    my $url = $object->URL if eval { $object->URL } ;

    return {
        description => 'external databases and IDs containing additional information on the object',
        data => %dbs ? \%dbs : undef,
    };
}







#################################################
#
#   Convenience methods
#
################################################


sub mysql_dsn {
    my ($self, $source) = @_;
    return $self->dsn->{"mysql_" . $source};
}

sub gff_dsn {
    my ($self, $species) = @_;
    $species ||= $self->_parsed_species;
    $self->log->debug("geting gff database species $species");
    return $self->dsn->{"gff_" . $species};
}

sub ace_dsn {
    my ($self) = @_;
    return $self->dsn->{"acedb"};
}



sub tmp_image_dir {
    my $self = shift;

# 2010.08.18: hostname no longer required in URI; tmp images stored in NFS mount
# Include the hostname for images. Necessary for proxying and apache configuration.
#    my $host = `hostname`;
#    chomp $host;
#    $host ||= 'local';
#    my $path = $self->tmp_dir('media/images',$host,@_);

    my $path = $self->tmp_dir('media/images', @_);
    return $path;
}

# Create a URI to a temporary image.
# Routing will be handled by Static::Simple in development
# and apache in production.
sub tmp_image_uri {
    my ($self, $path_and_file) = @_;

#    # append the hostname so that I can correctly direct traffic through the proxy
#    my $host = `hostname`;
#    chomp $host;
#    $host ||= 'local';

    my $tmp_base = $self->tmp_base;

# Purge the temp base from the path_and_file
# pre-NFS: eg /tmp/wormbase/images/wb-web1/00/00/00/filename.jpg -> images/wb-web1/00/00/00/filename.jpg
# eg /tmp/wormbase/images/00/00/00/filename.jpg -> images/00/00/00/filename.jpg
    $path_and_file =~ s/$tmp_base//;

    # URI (pre-NFS): /images/wb-web1/00/00/00...
    # URI: /images/00/00/00...
    my $uri = '/' . $path_and_file;
    return $uri;
}

sub tmp_acedata_dir {
    my $self = shift;
    return $self->tmp_dir('acedata', @_);
}

# A simple array would probably suffice instead of a hash
# (whcih is used in the view for sorting).
# We could sort objects in view according to name key 
# supplied by _pack_obj but might be messy to change now.
sub _pack_objects {
    my ($self, $objects) = @_;
#    $objects = ref $objects ? $objects : [ $objects ];
    return {map {$_ => $self->_pack_obj($_)} @$objects} if $objects;
}

sub _pack_obj {
    my ($self, $object, $label, %args) = @_;
    return undef unless $object; # this method shouldn't expect a list.
    return {
        id       => "$object",
        label    => $label // $self->_make_common_name($object),
        class    => $object->class,
        taxonomy => $self->_parsed_species($object),
        %args,
    };
}

sub _parsed_species {
    my ($self, $object) = @_;
    $object ||= $self->object;
    my $genus_species = eval {$object->Species} or return 'c_elegans';
    my ($species) = $genus_species =~ /.*[ _](.*)/o;
    return lc(substr($genus_species, 0, 1)) . "_$species";
}

# Take a string of Genus species and return a 
# data structure suitable for marking up species in the view.

sub _split_genus_species {
    my ($self,$string) = @_;
    my ($genus,$species) = split(/\s/,$string);
    return { genus => $genus, species => $species };
}



############################################################
#
# Private Methods
#
############################################################


# Description: checks data returned by extenral model for standards
#              compliance and fixes the data if necessary and possible.
#              the fixing is very rudimentary and can be bypassed by intra-model
#              invocations of methods. do not depend on it. fix your model code.
#              WARNING: modifies data directly if passed data is reference
# Usage: if (my ($fixed, @problems) = $self->_check_data($data)) { ... }
# Returns: () if all is well, otherwise array with fixed data and
#          description(s) of compliance problem(s).
sub _check_data {
    my ($self, $data, $class) = @_;
    $class ||= '';
    my @compliance_problems;

    if (ref($data) ne 'HASH') {   # no data pack
        $data = {
            description => 'No description available',
            data        => $data,
        };
        push @compliance_problems,
          'Did not return in hashref datapack with description and data entry.';
    }
    elsif (!$data->{description} && !exists $data->{data}) { # it's probably a data hash but not packed
        $data = {
            description => 'No description available',
            data        => $data,
        };
        push @compliance_problems,
          'Returned hashref, but no data & description entries. Perhaps forgot to pack the data?';
    }
    elsif (!$data->{description}) { # data value is there, but no description
        $data->{description} = 'No description available';
        push @compliance_problems,
          'Datapack does not have description.';
    }

    if (!exists $data->{data}) {    # no data entry
        $data->{data} = undef;
        push @compliance_problems, 'No data entry in datapack.';
    }
    elsif (my ($tmp, @problems) = $self->_check_data_content($data->{data}, $class))
    {
        $data->{data} = $tmp;
        push @compliance_problems, @problems;
    }

    return @compliance_problems ? ($data, @compliance_problems) : ();
}

# Description: helper to recursively checks the content of data for standards
#              compliance and fixes the data if necessary and possible
# Usage: FOR INTERNAL USE.
#        if(my ($tmp) = $self->_check_data_content($datum)) { ... }
# Returns: if all is well, (). otherwise, 2-array with fixed data and
#          description(s) of compliance problem(s).
sub _check_data_content {
    my ($self, $data, @keys) = @_;
    my $ref = ref($data) || return ();

    my @compliance_problems;
    my ($tmp, @problems);

    if ($ref eq 'ARRAY') {
        foreach (@$data) {
            if (($tmp, @problems) = $self->_check_data_content($_, @keys))
            {
                $_ = $tmp;
                push @compliance_problems, @problems;
            }
        }
        unless (@$data) {
            push @compliance_problems,
              join('->', @keys)
              . ': Empty arrayref returned; should be undef.';
        }
    }
    elsif ($ref eq 'HASH') {
        foreach my $key (keys %$data) {
            if (($tmp, @problems) =
                $self->_check_data_content($data->{$key}, @keys, $key))
            {
                $data->{$key} = $tmp;
                push @compliance_problems, @problems;
            }
        }
        unless (%$data) {
            push @compliance_problems,
              join('->', @keys)
              . ': Empty hashref returned; should be undef.';
        }
    }
    elsif ($ref eq 'SCALAR' || $ref eq 'REF') {

        # make sure scalar ref doesn't refer to something bad
        if (($tmp, @problems) = $self->_check_data_content($$data, @keys))
        {
            $data = $tmp;
            push @compliance_problems, @problems;
        }
        else {
            $data =
              $$data;    # doesn't refer to anything bad -- just dereference it.
            push @compliance_problems,
              join('->', @keys)
              . ': Scalar reference returned; should be scalar.';
        }

    }
    elsif (eval {$data->isa('Ace::Object')}) {
        push @compliance_problems,
            join('->', @keys)
          . ": Ace::Object (class: "
          . $data->class
          . ", name: $data) returned.";
        $data =
          $data->name;  # or perhaps they wanted a _pack_obj... we'll never know
    }
    else {    # don't know what the data is, but try to stringify it...
        push @compliance_problems,
            join('->', @keys)
          . ": Object (class: "
          . ref($data)
          . ", value: $data) returned.";
        $data = "$data";
    }

    return @compliance_problems ? ($data, @compliance_problems) : ();
}



############################################################
#
# Methods provided as a convenience for API users.
# Not used directly as part of the webapp.
#
############################################################

################################################
#   REFERENCES
################################################

sub _get_references {
  my ($self,$filter) = @_;
  my $object = $self->object;
  
  # References are not standardized. They may be under the Reference or Paper tag.
  # Dynamically select the correct tag - this is a kludge until these are defined.
  my $tag = (eval {$object->Reference}) ? 'Reference' : 'Paper';
  
  my $dbh = $self->dbh_ace;
  
  my $class = $object->class;
  my @references;
  if ( $filter eq 'all' ) {
      @references = $object->$tag;
  } elsif ( $filter eq 'gazette_abstracts' ) {
      @references = $dbh->fetch(
	  -query => "find $class $object; follow $tag WBG_abstract",
	  -fill  => 1);
  } elsif ( $filter eq 'published_literature' ) {
      @references = $dbh->fetch(
	  -query => "find $class $object; follow $tag PMID",
	  -fill => 1);
      
      #    @filtered = grep { $_->CGC_name || $_->PMID || $_->Medline_name }
      #      @$references;
  } elsif ( $filter eq 'meeting_abstracts' ) {
      @references = $dbh->fetch(
	  -query => "find $class $object; follow $tag Meeting_abstract",
	  -fill => 1
	  );
  } elsif ( $filter eq 'wormbook_abstracts' ) {
      @references = $dbh->fetch(
	  -query => "find $class $object; follow $tag WormBook",
	  -fill => 1
	  );
      # Hmm.  I don't know how to do this yet...
      #    @filtered = grep { $_->Remark =~ /.*WormBook.*/i } @$references;
  }
  return \@references;
}

# This is a convenience method for returning all methods. It
# isn't a field itself and is not included in the References widget.
sub all_references {
    my $self = shift;
    my $references = $self->_get_references('all');
    my $result = { description => 'all references for the object',
		   data        => $references,
    };
    return $result;
}

sub published_literature {
    my $self = shift;
    my $references = $self->_get_references('published_literarture');
    my $result = { description => 'published references only, no abstracts',
		   data        => $references,
    };
    return $result;
}

sub meeting_abstracts {
    my $self = shift;
    my $references = $self->_get_references('meeting_abstracts');
    my $result = { description => 'meeting abstracts',
		   data        => $references,
    };
    return $result;
}

sub gazette_abstracts {
    my $self = shift;
    my $references = $self->_get_references('gazette_abstracts');
    my $result = { description => 'gazette abstracts',
		   data        => $references,
    };
    return $result;
}

sub wormbook_abstracts {
    my $self = shift;
    my $references = $self->_get_references('wormbook_abstracts');
    my $result = { description => 'wormbook abstracts',
		   data        => $references,
    };
    return $result;
}




1;
