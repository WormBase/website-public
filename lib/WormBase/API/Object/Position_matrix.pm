package WormBase::API::Object::Position_matrix;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod  

=head1 NAME

WormBase::API::Object::Position_matrix

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/species/position_matrix

=head1 METHODS/URIs

=cut

has 'pm_datadir' => (
    is  => 'ro',
    lazy => 1,
    default  => sub {
		my $self= shift;
		my $version = $self->ace_dsn->version;
		return $self->pre_compile->{base} . $version . "/position_matrix/";
		#$self->pre_compile->{position_matrix};
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
# The Overview Widget
#
#######################################

=head2 Overview

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

=head3 associated_feature

This method will return a data structure with the associated feature to the requested position matrix.

=over

=item PERL API

 $data = $model->associated_feature();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Postion_matrix ID WBPmat00000001

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/associated_feature

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub associated_feature {
    my $self               = shift;
    my $object             = $self->object;
    my $associated_feature = $object->Associated_feature;
    my $data_pack          = $self->_pack_obj($associated_feature);
    return {
        'data'        => $data_pack,
        'description' => 'feature associated with motif'
    };
}

=head3 associated_position_matrix

This method will return a data structure with the associated position_matrix to the requested position matrix.

=over

=item PERL API

 $data = $model->associated_position_matrix();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Postion_matrix ID WBPmat00000001

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/associated_position_matrix

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub associated_position_matrix {
    my $self          = shift;
    my $object        = $self->object;
    my $associated_pm = $object->Associated_with_Position_Matrix;
    my $data_pack     = $self->_pack_obj($associated_pm);
    return {
        'data'        => $data_pack,
        'description' => 'other motif associated with motif'
    };
}

=head3 consensus

This method will return a data structure with the consensus sequence for the requested position matrix.

=over

=item PERL API

 $data = $model->consensus();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Postion_matrix ID WBPmat00000001

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/consensus

B<Response example>

<div class="response-example"></div>

=back

=cut 

 sub consensus {
    my $self              = shift;
    my $object            = $self->object;
    my %name2consensus = _build_hash($self->pm_datadir . "pm_id2consensus_seq.txt");
    ## $self->pre_compile->{pm_id2consensus_seq_file}
    my $data_pack         = $name2consensus{$object};
    return {
        'data'        => $data_pack,
        'description' => 'consensus sequence for motif'
    };
 }

############################
## logo
############################

#############################
## position data
#############################

=head3 position_data

This method will return a data structure with the position data for the requested position matrix.

=over

=item PERL API

 $data = $model->position_data();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Postion_matrix ID WBPmat00000001

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/position_data
B<Response example>

<div class="response-example"></div>

=back

=cut 

sub position_data {
    my $self   = shift;
    my $object = $self->object;
    my $sv     = $object->Site_values;

    my @row_1 = $sv->row;
    my @row_2 = $sv->down->row;
    my @row_3 = $sv->down->down->row;
    my @row_4 = $sv->down->down->down->row;

    my $base_r1 = shift @row_1;
    my $base_r2 = shift @row_2;
    my $base_r3 = shift @row_3;
    my $base_r4 = shift @row_4;

    my $data = {
        $base_r1 => \@row_1,
        $base_r2 => \@row_2,
        $base_r3 => \@row_3,
        $base_r4 => \@row_4
    };

    return {
        'data'        => $data,
        'description' => 'data for individual positions in motif'
    };
}

###########################
## internal methods
###########################

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

