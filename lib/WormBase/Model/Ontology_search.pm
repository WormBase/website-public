package WormBase::Model::Ontology_search;

use strict;
use warnings;
use base 'WormBase::Model';

=head1 NAME

WormBase::Web::Model::Ontology_search - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Norie  de la Cruz

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

=pod

NB:

=cut

###################################
### template
#####################################

=pod

NB:
Takes ($self,<object>) and returns a <data type> containing.

=cut

# sub <sub_name> {
#     my ($self,$c,$go_term) = @_;
#     my $data = $go_term-><tag>;
#     return <type>data;  ## returns text
# }


#### end template #####

#####################################

#####################################

=pod

NB: searches for string in data file of precompiled from obo and associations file
Takes $self and query instructions and returns a hash reference containing lines from the data file containing query string grouped via ontologies Keys: 'biological_process','cellular_component','molecular_function','anatomy','phenotype' as requested.

=cut


sub run_search {

    my %search_results;
    my ($self,$data_file_name, $query,$ontology_list,$annotations_only,$string_modification) = @_;
    my $search_data;

    my @ontologies = split '&',$ontology_list;
    sort @ontologies;

    if ($annotations_only == 1) {
	if ($string_modification eq 'stand_alone'){
	    $search_data = `grep -iw \'$query\' \.\/$data_file_name \| grep \-v \'\|0\'`;
	}
	else{
	    $search_data = `grep \'$query\' \.\/$data_file_name \| grep \-v \'\|0\'`;
	}
    }
    else {

		if($string_modification eq 'stand_alone'){
	    #$search_data = `grep -w \'\\\<$query\\\>\' \.\/$data_file_name`;
	    $search_data = `grep -iw \'$query\' \.\/$data_file_name`;
		}
		else{
	    $search_data = `grep  \'$query\' \.\/$data_file_name`;
		}
    }

    $search_data =~ s/$query/\<font color\=\'red\'\>$query\<\/font\>/g;
    my @search_data_lines = split '\n', $search_data;
   
    foreach my $ontology (@ontologies){
        my $ontology_specific_line = '';
        foreach my $search_data_line (@search_data_lines){
            my @split_data = split(/\|/, $search_data_line);
            if($ontology eq $split_data[3]){
                $ontology_specific_line = $ontology_specific_line."$search_data_line\n";
            }
            else {
                next;
            }
        }
        if ($ontology_specific_line =~ m/\|/){
            $search_results{$ontology} = $ontology_specific_line;
        }
        else
        {
            $search_results{$ontology} = 0;
        }
    }
    return \%search_results;
}


1;
