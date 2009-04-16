package WormBase::Model::Laboratory;

use strict;
use warnings;
use base 'WormBase::Model';


# This is like Erik Jorgensen for EG, NOT the object name itself;
sub principal_investigator {
    my ($self) = @_;
    my $object = $self->current_object;
    my ($name,@address) = $object->Address(2);
    my %data = ( name => $name,
		 fax   => $object->Fax,
		 phone => $object->Phone,
		 email => $object->Email);
    return \%data;
}

sub other_representatives {
    my ($self) = @_;
    my $object = $self->current_object;
    my @representatives = $object->Representative;
    my @data;
    foreach (@representatives) {
	my $email = $_->get('E_mail' => 1);
	$email = $email->right if $email->right; #AtDB damnation
	
	my %person = ( name   => $_->Standard_name,
		       address => $_->Address(2),
		       email   => $email,
	    );
	push @data,\%person;
    }
    return \@data;
}

sub lab_url {
    my ($self) = @_;
    my $object = $self->current_object;
    return $object->URL;
}

sub responsible_for_gene {
    my ($self) = @_;
    my $object = $self->current_object;
    my @genes = $object->get('Gene_classes');
    return \@genes;
}

sub responsible_for_alleles {
    my ($self) = @_;
    my $object = $self->current_object;
    my @alleles = $object->get('Allele_designation');
    return \@alleles;
}

# Array of arrays. Inner array contains object and link text
# I could push this onto the template
sub registered_lab_members {
    my ($self) = @_;
    my $object = $self->current_object;
    my @data;
    if (my @group = $object->Registered_lab_members) {
	push (@data,[ $_,$_->Full_name]);
    }
    return \@data;
}

sub past_lab_members {
    my ($self) = @_;
    my $object = $self->current_object;
    my @data;
    if (my @group = $object->Past_lab_members) {
	push (@data,[ $_,$_->Full_name]);
    }
    return \@data;
}



=head1 NAME

WormBase::Model::Laboratory - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

Original CGI was not yet in section/subsection layout. I created my own.

Original CGI had a summary display of all labs.

Remarks code (now using generic remarks()) had code that marked up URLs

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
