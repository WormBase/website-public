package WormBase::API::Object::Paper;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



sub name {
    my $self = shift;
    my $data = { description => 'The object name of the paper',
		 data        =>  $self ~~ 'name',
    };
    return $data;

}

sub common_name {
    my $data = { description => 'The public name of the paper',
		 data        => shift ~~ 'name',
    };
    return $data;
}

############################################################
#
# The Overview widget
#
############################################################
sub identity {
   my $self = shift;
   my $print = eval{ join(', ', @{$self->genes});};
   my $iden = $self ~~ 'Brief_identification' ;
   if($iden) {
    if($print) {
	$print.=", ".$iden;
    }
    else {
      $print=$iden;
    }
   }
   return unless $print;
    my $data = { description => 'The identity of the sequence',
		 data        => "Identified as ". $print. $self->type eq 'pseudogene' ? ' (pseudogene)' : '',
    };
    return $data;
}

sub description {
    my $self = shift;
    my $title = eval {$self ~~ 'Title'} || return;
    my $data = { description => 'The description of the sequence',
		 data        => $title,
    };
    return $data;    
}


############################################################
#
# The Search widget
#
############################################################

sub title {
    my $self = shift;
    my $title = eval {$self ~~ 'Title'} || return;
    $title =~ s/\.*$//;
    my $data = { description => 'The title of the paper',
		 data        => $title,
    };
    return $data;    
}

sub journal {
    my $self = shift;
    my $journal = eval {$self ~~ 'Journal'} || return;
    $journal =~ s/\.*$//;
    my $data = { description => 'The journal the paper was published in',
		 data        => $journal,
    };
    return $data;    
}

sub page {
    my $self = shift;
    my $page = eval {$self ~~ 'Page'} || return;
    $page =~ s/\.*$//;
    my $data = { description => 'The page numbers of the paper',
		 data        => $page,
    };
    return $data;    
}

sub volume {
    my $self = shift;
    my $volume = eval {$self ~~ 'Volume'} || return;
    $volume =~ s/\.*$//;
    my $data = { description => 'The volume teh paper was published in',
		 data        => $volume,
    };
    return $data;    
}

sub year {
    my $self = shift;
    my $year = $self->_parse_year($self ~~ 'Publication_date');
    return unless $year;
    my $data = { description => 'The title of the paper',
		 data        => $year,
    };
    return $data;    
}

sub authors {
    my $self = shift;
  # this is the long form of author
    my @authors;
    foreach my $author (@{$self ~~ '@Author'}) {
	  my $obj = $author;
	  foreach my $col ($author->col) {
	    if($col eq 'Person') {
	      $obj = $col->right;
	    }
	  }
	  push(@authors,{
			  id=>$obj,
			  link=>$obj->class,
			  label =>$author ,
		      });
    }
    my $data = { description => 'The authors of the paper',
		 data        => \@authors,
    };
    return $data;    
}

sub abstract {
    my $self = shift;
    my $abs = $self ~~ 'Abstract';
    my $abstext = $self->ace_dsn->fetch(LongText=>$abs);
    my $text = "";
    if ($abstext) { 
	 $text = $abstext->right;
	 $text=~s/^\n+//gs;
	 $text=~s/\n+$//gs;
    }
     
    my $data = { description => 'The abstract of the paper',
		 data        => $text,
    };
    return $data;    
}




############################################################
#
# PRIVATE METHODS
#
############################################################





1;
