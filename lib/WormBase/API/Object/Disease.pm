package WormBase::API::Object::Disease; 
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

### data

has 'omim_id' => (
	is  => 'rw',
	isa => 'Str',
);

has 'orthology_datadir' => ( ## temp
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my $version = $self->ace_dsn->version;
	return $self->pre_compile->{base} . $version . "/orthology/";
    }
);



has 'omim2all_ortholog_data' => (
    is  => 'ro',
    lazy => 1,
    default => sub {		
		my $self = shift;
		my  %omim2all_ortholog_data = build_hash($self->orthology_datadir . "omim_id2all_ortholog_data.txt");
		return \%omim2all_ortholog_data;
    } 
);

has 'name2id' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
    
    my $self = shift;
    my  %name2id = build_hash($self->orthology_datadir . "name2id.txt");
	return \%name2id;
    } 
);


has 'omim_id2disease_desc' => (
    is  => 'ro',
    lazy => 1,
    default => sub {		
		my $self = shift;
		my  %omim_id2disease_desc = build_hash($self->orthology_datadir . "omim_id2disease_desc.txt");
		return \%omim_id2disease_desc;
    } 
);


has 'omim_id2txt_notes' => (
    is  => 'ro',
    lazy => 1,
    default => sub {		
		my $self = shift;
		my  %omim_id2txt_notes = build_hash($self->orthology_datadir . "omim_id2disease_notes.txt");
		return \%omim_id2txt_notes;
    } 
);

has 'omim2disease_name' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my $self = shift;
		my  %omim2disease_name = build_hash($self->orthology_datadir . "omim_id2disease_name.txt");
		return \%omim2disease_name;
    } 
);



has 'id2name' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
    
    my $self = shift;
    my  %id2name = build_hash($self->orthology_datadir . "id2name.txt");
	return \%id2name;
    } 
);


has 'genes_ar' => (
	is => 'ro',
	lazy => 'lazy',
	default => sub {
		my $self = shift;
		my @associations = split "%", $self->omim2all_ortholog_data->{$self->id};
		my $dbh = $self->dbh;
		my @genes;
		foreach my $association (@associations) {
			my ($disease,$omim_id,$wb_id,$db,$ens_id,$sp,$analysis,$method,$phenotype,$bp,$mf) = split /\|/,$association;
			my $gene_obj = $dbh->fetch(-class=>'Gene',-name=>$wb_id);
			push @genes, $gene_obj;
		}
	return \@genes;
	}
); 


### methods

sub id {
	my $self = shift;
	return $self->omim_id;
}

sub name {
	my $self = shift;
	my $id = $self->omim_id;
	my $name = $self->omim2disease_name->{$id};
	return $name;
}

sub description {
	my $self = shift;
	my $id = $self->omim_id;
	my $description = $self->omim_id2disease_desc->{$id};
	return $description;

}

sub genes {
	my $self = shift;
	my @associations = split "%", $self->omim2all_ortholog_data->{$self->id};
	my @genes;
	my $dbh = $self->dbh;
	foreach my $association (@associations) {
		my ($disease,$omim_id,$wb_id,$db,$ens_id,$sp,$analysis,$method,$phenotype,$bp,$mf) = split /\|/,$association;
		my $gene_obj = $dbh->fetch(-class=>'Gene',-name=>$wb_id);
		push @genes, $gene_obj;
	}
	return \@genes;
}


sub build_hash{  ##temp
	my ($file_name) = @_;
	open FILE, "< $file_name" or die "Cannot open the file: $file_name\n";
	my %hash;
	foreach my $line (<FILE>) {
		chomp ($line);
		my ($key, $value) = split '=>',$line;
		$hash{$key} = $value;
	}
	return %hash;
}



1;