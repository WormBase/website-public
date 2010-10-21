package WormBase::API::Object::Paper;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



sub name {
    my $self = shift;
    my $title = eval {$self ~~ 'Title'} || $self ~~ 'name';
    $title =~ s/\.*$//;
    my $data = { description => 'The object name of the paper',
		 data        =>  { id    => $self ~~ 'name',
				   label => $title,
				   class => $self ~~ 'class'
		 },
    };
    return $data;
}


############################################################
#
# The Overview widget
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
    my $data = { description => 'The volume the paper was published in',
		 data        => $volume,
    };
    return $data;    
}

sub year {
    my $self = shift;
    my $year = $self->_parse_year($self ~~ 'Publication_date');
    return unless $year;
    my $data = { description => 'The publication year of the paper',
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
			  class=>$obj->class,
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

    if ($abstext =~ /WBPaper/i ) { 
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
