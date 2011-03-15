package WormBase::API::Role::Object;

use Moose::Role;
use File::Path 'mkpath';

# I should have an abstract method for id():
# provided with a class and a name, return the internal ID, if different.

# TODO:
# Synonym (other_name?)
# DONE (mostly): Database and DB_Info parsing
# Titles / description / definition
# Phenotypes observed/not_observed
# Where do hashtables (used for decisions) go? See _common_name()

has 'MAX_DISPLAY_NUM' => (
    is      => 'ro',
    default => 10,
);

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

#######################################################
#
# Generic methods
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
#    default => sub {
#        my ($self) = @_;
#        my $object = $self->object;
#	return { } unless $object;
#        my $class  = $object->class;
    is         => 'ro',
    lazy_build => 1,
    );

sub _build_name {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    return {
        description => "The name and WormBase internal ID of a $class object",
        data        =>  $self->_pack_obj($object),
    };
}

# should be for internal use only
# external use, see 'name' attr.
has 'common_name' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_common_name {
    my ($self) = @_;
    return $self->_common_name($self->object);
}

sub _common_name {
    my ($self, $object) = @_;
    my $class  = $object->class;

    my %taghash = (
        Person     => 'Standard_name',
        Gene       => [qw(Public_name CGC_name Molecular_name)],
        # for gene, still missing $gene->Corresponding_CDS->Corresponding_protein
        # to fully handle this, an exception may have to be made OR this method
        # could be made more robust to do recursive checks... seems unnecessary
        Feature    => 'Public_name',
        Variation  => 'Public_name',
        Phenotype  => 'Primary_name',
        Gene_class => 'Main_name',
        Species    => 'Common_name',
    );

    my $name;
    if (my $tag = $taghash{$class}) {
        $tag = [$tag] unless ref $tag;
        foreach my $tag (@$tag) {
            last if $name = $object->$tag;
        }
    }

    return ($name && "$name") || $object->name;
}

# deprecated in favour of _common_name
sub bestname {
    my ($self, $gene) = @_;
    return unless $gene && $gene->class eq 'Gene';
    my $name =
         $gene->Public_name
      || $gene->CGC_name
      || $gene->Molecular_name
      || eval {$gene->Corresponding_CDS->Corresponding_protein}
      || $gene;
    return $name;
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
    is         => 'ro',
    lazy_build => 1,
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

=head4 PERL API

 $data = $model->best_blastp_matches();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

A class of gene or protein and a gene
or protein ID.

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/[GENE|PROTEIN]/[OBJECT]/best_blastp_matches

=head5 Response example

=cut

# Template: [% best_blastp_matches %]

has 'best_blastp_matches' => (
    is         => 'ro',
    lazy_build => 1,
);

# Fetch all of the best_blastp_matches for a list of proteins.
# Used for genes and proteins
sub _build_best_blastp_matches {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;

    my $proteins;
    if ($class eq 'Gene') {
        $proteins = $self->all_proteins;
    }
    elsif ($class eq 'Protein') {
        # current_object might already be a protein.
        $proteins = [$self->object] unless $proteins;
    }
    else {
        return {
            description => 'no proteins found, no best blastp hits to display',
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
    lazy_build => 1,
);

sub _build_description {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $tag;
    if ($class eq 'Sequence') {
        $tag = 'Title';
    }
    else {
        $tag = 'Description';
    }
    my $description = eval {$object->$tag};    # TODO!!! : fix
    return {
        description => "description of the $class $object",
        data        => "$description" || undef,
    };

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
    lazy_build => 1,
);

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
    lazy_build => 1,
);

# laboratory: Whenever a cross-ref to lab is needed.
# Returns the lab as well as the current representative.
# Used in: Person, Gene_class, Transgene
# template: shared/fields/laboratory.tt2
sub _build_laboratory {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;    # Ace::Object class, NOT ext. model class

    # Ugh. Model inconsistencies.
    my %taghash = (
        Gene_class  => 'Designating_laboratory',
        PCR_product => 'From_laboratory',
        Sequence    => 'From_laboratory',
        CDS         => 'From_laboratory',
        Transgene   => 'Location',
        Strain      => 'Location',
        Antibody    => 'Location',
    );

    my $tag = $taghash{$class} || 'Laboratory';
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
    is         => 'ro',
    lazy_build => 1,
);

# The method used to describe the object
sub _build_method {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $method = $object->Method;

    return {
        description => "the method used to describe the $class",
        data        => $method && "$method",
    };
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
    is         => 'ro',
    lazy_build => 1,
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
    is         => 'ro',
    lazy_build => 1,
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
    is         => 'ro',
    lazy_build => 1,
);

sub _build_status {
    my ($self) = @_;
    my $object = $self->object;
    my $class  = $object->class;
    my $status = $class eq 'Protein' ? ($object->Live ? 'live' : 'history')
                                     : $object->Status;

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
    is         => 'ro',
    lazy_build => 1,
);

# Parse out species "from a Genus species" string.
sub _build_taxonomy { # this overlaps with parsed_species
    my ($self) = @_;

    my ($genus, $species) = (($self ~~ 'Species') =~ /(.*) (.*)/);

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

=head4 PERL API

 $data = $model->xrefs();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

A class and object ID.

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/CLASS/OBJECT/xrefs

=head5 Response example

<div class="response-example"></div>

=cut

# template [% xrefs %]

has 'xrefs' => (
    is         => 'ro',
    lazy_build => 1,
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
            @types ? map { "$_" } @types : $_->right->name;
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

sub mysql_dsn {
    my ($self) = @_;
    my $source = shift;
    return $self->dsn->{"mysql_" . $source};
}

sub gff_dsn {
    my ($self) = @_;
    my $species = shift || $self->parsed_species;
    $self->log->debug("geting gff database species $species");
    return $self->dsn->{"gff_" . $species} || $self->dsn->{"gff_c_elegans"};
}

sub ace_dsn {
    my ($self) = @_;
    return $self->dsn->{"acedb"};
}

# Set up our temporary directory (typically outside of our application)
sub tmp_dir {
    my ($self) = @_;
    my @sub_dirs = @_;
    my $path = File::Spec->catfile($self->tmp_base, @sub_dirs);

    mkpath($path, 0, 0777) unless -d $path;
    return $path;
}

sub tmp_image_dir {
    my ($self) = @_;

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
    my ($self) = @_;
    return $self->tmp_dir('acedata', @_);
}

sub _pack_objects {
    my ($self, $objects) = @_;
    return {map {$_ => $self->_pack_obj($_)} @$objects};
}

sub _pack_obj {
    my ($self, $object, $label, %args) = @_;
    return unless $object;
    return {
        id       => "$object",
        label    => $label // $self->_common_name($object),
        class    => $object->class,
	taxonomy => $self->parsed_species($object),
        %args,
    };
}

sub parsed_species {
    my ($self, $object) = @_;
    $object ||= $self->object;
    my $genus_species = eval {$object->Species} or return 'c_elegans'; # is this default correct?
    my ($species) = $genus_species =~ /.* (.*)/;
    return lc(substr($genus_species, 0, 1)) . "_$species";
}


# Description: checks data returned by extenral model for standards
#              compliance and fixes the data if necessary and possible.
#              the fixing is very rudimentary and can be bypassed by intra-model
#              invocations of methods. do not depend on it. fix your model code.
#              WARNING: modifies data directly if passed data is reference
# Usage: if (my ($fixed, @problems) = $self->check_data($data)) { ... }
# Returns: () if all is well, otherwise array with fixed data and
#          description(s) of compliance problem(s).
sub check_data {
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
# Private Methods
#
############################################################

1;
