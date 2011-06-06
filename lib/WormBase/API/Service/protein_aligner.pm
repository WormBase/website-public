package WormBase::API::Service::protein_aligner;

use Bio::Graphics::Browser2::PadAlignment;
use Bio::Graphics::Browser2::Markup;

 
use Moose;
with 'WormBase::API::Role::Object'; 


# color table based on malign, but changed for the colour blind
our %colours = ( 
'*'       =>  '666666',         #mismatch          (dark grey)
'.'       =>  '999999',         #unknown           (light grey)
 A        =>  '33cc00',         #hydrophobic       (bright green)
 B        =>  '666666',         #D or N            (dark grey)
 C        =>  '2c5197',         #cysteine          (st.louis blue)
 D        =>  '0033ff',         #negative charge   (bright blue)
 E        =>  '0033ff',         #negative charge   (bright blue)
 F        =>  '009900',         #large hydrophobic (dark green)
 G        =>  '33cc00',         #hydrophobic       (bright green)
 H        =>  '009900',         #large hydrophobic (dark green)
 I        =>  '33cc00',         #hydrophobic       (bright green)
 K        =>  'cc0000',         #positive charge   (bright red)
 L        =>  '33cc00',         #hydrophobic       (bright green)
 M        =>  '380474',         #hydrophobic       (blue deep)
 N        =>  '6600cc',         #polar             (purple)
 P        =>  '33cc00',         #hydrophobic       (bright green)
 Q        =>  '6600cc',         #polar             (purple)
 R        =>  'cc0000',         #positive charge   (bright red)
 S        =>  '0099ff',         #small alcohol     (dull blue)
 T        =>  '0099ff',         #small alcohol     (dull blue)
 V        =>  '33cc00',         #hydrophobic       (bright green)
 W        =>  '009900',         #large hydrophobic (dark green)
 X        =>  '666666',         #any               (dark grey)
 Y        =>  '009900',         #large hydrophobic (dark green)
 Z        =>  '666666',         #E or Q            (dark grey)
);

 
sub index {
   my ($self) = @_;
   my $data = {};
   return $data;
}


sub run {
    my ($self,$param) = @_;
    my $peptide_id = $param->{"sequence"};
    my $protRecord = $self->ace_dsn->fetch("Protein"=> $peptide_id);
    return {msg=>"Sorry, 0 results found for this protein"} unless $protRecord  ;
    my $dbh = $self->mysql_dsn("clustal")->dbh;
    $self->log->debug("prepare the query to clustal db for protein $peptide_id");
    my $sql = qq{ SELECT peptide_id, alignment FROM clustal WHERE peptide_id LIKE "$peptide_id"}; 
    my $sth = $dbh->prepare( $sql );
    $sth->execute();

    my @data;

    my @results;
    while (@data = $sth->fetchrow_array){
	    my $coloured_data = $self->_postprocess(join('', @data));
	    push @results, $coloured_data;
    }

    return {data=>\@results, sequence=>$peptide_id};
}
  

sub _postprocess{
     my ($self,$raw_al)=@_;
     my @line=split("\n",$raw_al);
     my @coloured;
     foreach my $l(@line) {
	 #some hack converting the url to use new site structure
	 $l =~ s/http:\/\/www\.wormbase\.org//g;
	 $l =~ s/db\/seq\/protein\?name=/species\/protein\//g;
	 $l =~ s/db\/gene\/gene\?name=/species\/gene\//g;
         my @cols=split(//,$l);
         my $flip=0;
         for(my $position=0;$position < scalar(@cols);$position++){
           next if $l=~/CLUSTAL/;
           $flip=1 if $cols[$position]=~/\s/;
           next unless $flip;
           $cols[$position]="<font color=\"#$colours{$cols[$position]}\">$cols[$position]</font>"
            if $colours{$cols[$position]};
         }
        push @coloured,(join('',@cols)."\n");
         
     }
     return \@coloured; 
}


 
 

1;
