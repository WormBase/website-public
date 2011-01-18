package WormBase::API::Object::Expr_pattern;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



sub name {
    my $self = shift;
    my $data = {
					description => 'The object name of the paper',
					data => {
								id		=> $self ~~ 'name',
								label	=> $self ~~ 'name',
								class	=> $self ~~ 'class'
					},
	};
    return $data;
}


############################################################
#
# The Overview widget
#
############################################################
sub print_summary {
  my $self = shift;
  my $ep = $self->object;
  my @desc;
  my $hash;
  # TOTAL HACK FOR THE MOHLER MOVIES
  # These are handled elsewhere because he wants his own custom formatting

  unless ($ep->Author =~ /Mohler/) {
    @desc = $ep->Pattern;

    if ($ep->Remark) {
      my $remark = add_href($ep->Remark);
#       push(@desc,"Remark: ".$remark);
      $hash->{remark}=$remark;
    }
 $hash->{check_bc} = check_for_bc($ep);
=pod
    if (check_for_bc($ep)) {
    
       push @desc,"GFP constructs were generated as part of the " .
            a({-href=>"http://elegans.bcgsc.ca/home/ge_consortium.html"},
 	     'BC <i>C. elegans</i> Gene Expression Consortium');
    }
=cut
  }

  if (my (@sl) = $ep->Subcellular_localization) {
    $hash->{Subcellular} = \@sl;
#     push(@desc,"Subcellular location:" . join(p,@sl));
  }

    
   my $data = {
					description	=> 'The description of the expression pattern',
					data		=> { desc=>\@desc,
							     other=>$hash,
							  }
    };
    return $data;
}
############################################################
#
# PRIVATE METHODS
#
############################################################

=head2 add_href

 Title   : add_href
 Usage   : add_href($obj->Remark)
 Function: Adds hyperlink to correctly formated links
 Returns : string
 Args    : array of strings

=cut

sub add_href {
    my (@result) = @_;
    foreach (@result) {
        s!(http:/[a-zA-Z/0-9+?&%.-]+)!$1!eg;
    }
    return join( ' ', @result );
}


=head2 check_for_bc

 Title   : check_for_bc
 Usage   : check_for_bc($obj)
 Function: checks if this is a BC consortium strain
 Returns : integer
 Args    : expression pattern object

=cut

# Is this a BC strain?
sub check_for_bc {
    my $ep = shift;
    my $bcflag = undef;

    # VC abd BC are the Baiilie and Moerman labs
    my @labs = $ep->Laboratory;
    $bcflag = grep {$_ eq 'BC' || $_ eq 'VC'} @labs;
}

1;
