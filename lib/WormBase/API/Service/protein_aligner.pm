package WormBase::API::Service::protein_aligner;

use Bio::Graphics::Browser2::PadAlignment;
use Bio::Graphics::Browser2::Markup;


use Moose;
with 'WormBase::API::Role::Object';


# color table based on malign, but changed for the colour blind
our %colours = (
'*'       =>  'default',        #mismatch          (dark grey)
'.'       =>  'unknown',        #unknown           (light grey)
 A        =>  'hydrophobic',         #hydrophobic       (bright green)
 B        =>  'default',         #D or N            (dark grey)
 C        =>  'cysteine',         #cysteine          (st.louis blue)
 D        =>  'negative',         #negative charge   (bright blue)
 E        =>  'negative',         #negative charge   (bright blue)
 F        =>  'lg-hydrophobic',         #large hydrophobic (dark green)
 G        =>  'hydrophobic',         #hydrophobic       (bright green)
 H        =>  'lg-hydrophobic',         #large hydrophobic (dark green)
 I        =>  'hydrophobic',         #hydrophobic       (bright green)
 K        =>  'positive',         #positive charge   (bright red)
 L        =>  'hydrophobic',         #hydrophobic       (bright green)
 M        =>  'hydrophobic',         #hydrophobic       (blue deep)
 N        =>  'polar',         #polar             (purple)
 P        =>  'hydrophobic',         #hydrophobic       (bright green)
 Q        =>  'polar',         #polar             (purple)
 R        =>  'positive',         #positive charge   (bright red)
 S        =>  'alcohol',         #small alcohol     (dull blue)
 T        =>  'alcohol',         #small alcohol     (dull blue)
 V        =>  'hydrophobic',         #hydrophobic       (bright green)
 W        =>  'lg-hydrophobic',         #large hydrophobic (dark green)
 X        =>  'default',         #any               (dark grey)
 Y        =>  'lg-hydrophobic',         #large hydrophobic (dark green)
 Z        =>  'default',         #E or Q            (dark grey)
);


sub index {
   my ($self) = @_;
   my $data = {};
   return $data;
}


sub run {
    my ($self,$c,$param) = @_;
    my $peptide_id = $param->{"sequence"};
    my $protRecord = $self->ace_dsn->fetch("Protein"=> $peptide_id);
    return {msg=>"Sorry, 0 results found for this protein"} unless $protRecord;

#    my $dbh = $self->mysql_dsn("clustal")->dbh;
    my $dbh = $self->mysql_dsn("clustal")->dbh;

    $self->log->debug("prepare the query to clustal db for protein $peptide_id");
    my $sql = qq{ SELECT alignment FROM clustal WHERE peptide_id = "$peptide_id"};
    my $sth = $dbh->prepare( $sql );
    $sth->execute();

    my @data;

    my @results;
    while (@data = $sth->fetchrow_array){
	    my $coloured_data = $self->_postprocess(join('', @data));
	    push @results, $coloured_data;
    }

    return {msg=>"Sorry, no alignment data available"} unless @results;

    return {data=>\@results, sequence=>$peptide_id};
}


sub _postprocess{
     my ($self,$raw_al)=@_;
     my @line=split("\n",$raw_al);
     my @coloured;
     foreach my $l(@line) {
	 #some hack converting the url to use new site structure
	 $l =~ s/http:\/\/www\.wormbase\.org//g;
	 $l =~ s/db\/seq\/protein\?name=/species\/all\/protein\//g;
     $l =~ s/db\/gene\/gene\?name=([^\")]+)([^\s)]+)[\s]([^\b)]+)/species\/all\/gene\/$1\" class=\"locus\"\>$3\<\/a\>/g;
     $l =~ s/\(([^\)]+)\)/\(\<i\>$1\<\/i\>\)/g;
         my @cols=split(//,$l);
         my $flip=0;
         for(my $position=0;$position < scalar(@cols);$position++){
           next if $l=~/MUSCLE/;
           $flip=1 if $cols[$position]=~/\s/;
           next unless $flip;
           $cols[$position]="<span class=\"align-$colours{$cols[$position]}\">$cols[$position]</span>"
            if $colours{$cols[$position]};
         }
        push @coloured,(join('',@cols)."\n");
     }
     return \@coloured;
}





1;
