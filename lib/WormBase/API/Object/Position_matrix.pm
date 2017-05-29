package WormBase::API::Object::Position_matrix;

use Moose;
use File::Spec::Functions qw(catfile catdir);
use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod

=head1 NAME

WormBase::API::Object::Position_matrix

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/species/*/position_matrix

=cut

has 'pm_datadir' => (
    is  => 'ro',
    lazy => 1,
    default  => sub {
		my $self= shift;
        return catdir($self->pre_compile->{base}, $self->ace_dsn->version,
                      'position_matrix');
    }
);

# has 'data_directory' => (
#     is      => 'ro',
#     lazy    => 1,
#     default => sub {
#         my $self        = shift;
#         my $ace_service = $self->ace_dsn();
#         my $version     = $ace_service->dbh->version;
#         return "/usr/local/wormbase/databases/$version/position_matrix";
#     }
# );
#
# has 'image_directory' => (
#     is      => 'ro',
#     lazy    => 1,
#     default => sub {
#         return "../../html/images/position_matrix";
#     }
# );

# has 'name2consensus_hr' => (
#     is      => 'ro',
#     lazy    => 1,
#     default => sub {
#         my $self           = shift;
#         my $data_dir       = $self->data_directory;
#         my $datafile       = $data_dir . "/pm_id2consensus_seq.txt";
#         my %name2consensus = _build_hash($datafile);
#
#         return \%name2consensus;
#     }
# );
#
# has 'image_pointer_file' => (
#     is      => 'ro',
#     lazy    => 1,
#     default => sub {
#         my $self          = shift;
#         my $data_dir      = $self->data_directory;
#         my $datafile      = $data_dir . "/pm_id2source_pm.txt";
#         my %image_pointer = _build_hash($datafile);
#
#         return \%image_pointer;
#     }
# );


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

#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# description { }
# Supplied by Role

# remarks {}
# Supplied by Role

# type { }
# This method will return a data structure with the type
# of position matrix (frequency | weight).
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/type

sub type {
    my $self    = shift;
    my $object  = $self->object;
    my $data    = $self->Type;
    return { data        => "$data" || undef,
	     description => 'the type of position matrix', };
}

# associated_feature { }
# This method will return a data structure with features
# associated with the requested position matrix.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/associated_feature

sub associated_feature {
    my $self    = shift;
    my $object  = $self->object;
    my $data    = $self->_pack_obj($object->Associated_feature);
    return { data        => $data || undef,
	     description => 'feature associated with motif' };
}

# associated_position_matrix { }
# This method will return a data structure with other matrices
# associated with the current matrix.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/associated_position_matrix

sub associated_position_matrix {
    my $self     = shift;
    my $object   = $self->object;
    my $data     = $self->_pack_obj($object->Associated_with_Position_Matrix);
    return {data        => $data || undef,
	    description => 'other matrix associated with motif' };
}

# consensus { }
# This method will return a data structure with the
# consensus sequence for the requested position matrix.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/consensus

sub consensus {
    my $self    = shift;
    my $object  = $self->object;

    # Why is this hard-coded here? Why isn't this an attribute or in configuration? How/Where is this file created?
    my %name2consensus;# = _build_hash(catfile($self->pm_datadir, 'pm_id2consensus_seq.txt'));
    my $data           = $name2consensus{$object};
    return {
        data        => $data || undef,
        description => 'consensus sequence for motif',
    };
 }


# bound_by_gene_product { }
# This method will return a data structure containing
# a list of genes that to bind to the motif;
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/bound_by_gene_product

sub bound_by_gene_product {
    my $self   = shift;
    my $object = $self->object;
    my @data = map { $self->_pack_obj($_) } $object->Bound_by_gene_product;

    return { data => @data ? \@data : undef,
	     description => 'gene products that bind to the motif' };
}


# transcription_factors { }
# This method will return a data structure containing
# the transcription factors that associate with this motif.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001transcription_factors

sub transcription_factor {
    my $self   = shift;
    my $object = $self->object;

    return { description => 'Transcription factor of the feature',
	     data        => $self->_pack_obj($object->Transcription_factor),
    }
}


############################
## logo
############################

#############################
## position data
#############################

# position_data { }
# This method will return a data structure with the position data for the requested position matrix.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/position_data

sub position_data {
    my $self   = shift;
    my $object = $self->object;
    my @data;

    foreach my $nucl ($object->Site_values) {
	my %ndata;
	$ndata{Type} = "$nucl" || undef;

	my $ind = "00";
	foreach my $val ( $nucl->row(1)) {
	    $ndata{$ind++} = "$val" || undef;
	}
	push @data, \%ndata;
    }

    return {
        data        => @data ? \@data : undef,
        description => 'data for individual positions in motif',
    };
}

###########################
## internal methods
###########################

# OMG another flat file data slurp? Really?
sub _build_hash {
    my ($file_name) = @_;
    open FILE, "<$file_name" or die "Cannot open the file: $file_name\n";
    my %hash;
    foreach my $line (<FILE>) {
        chomp($line);
        my ( $key, $value ) = split '=>', $line;
        $hash{$key} = $value;
    }
    return %hash;
}

__PACKAGE__->meta->make_immutable;

1;
