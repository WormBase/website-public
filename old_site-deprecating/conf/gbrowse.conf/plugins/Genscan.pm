package Bio::Graphics::Browser::Plugin::Genscan;
use strict;

use lib '/home/simonf/scripts';

use CGI qw(:standard *table);
use IO::File;
use POSIX qw(tmpnam);
use CGI qw(:standard *pre);

use Bio::Graphics::Glyph::genscan_transcript;

use Bio::Graphics::Browser::Plugin;
use Bio::SeqFeature::Generic;
use Bio::Tools::Genscan;

use vars '$VERSION','@ISA';
$VERSION = '0.1';

@ISA = qw(Bio::Graphics::Browser::Plugin);

sub name { "Genscan" }

sub description {
    p("The Genscan plugen runs the Genscan program by Chris Burge that predicts the locations and exon-intron structures of genes (requires the genscan binary).");
    p("This plugin was written by Simon Ilyushchenko.");
}

sub type { 'annotator' }

sub init { }

sub config_defaults {
    my $self = shift;
    return { 
        parameters => 'HumanIso',
        location => '/usr/local/genscan/',
    };
}

sub reconfigure {
  my $self = shift;
  my $current_config = $self->configuration;

  my $objtype = $self->objtype();

  foreach my $p ( param() ) {
        my ($c) = ( $p =~ /$objtype\.(\S+)/) or next;
        $current_config->{$c} = param($p);
  }
}



sub configure_form {
    my $self = shift;
    my $current_config = $self->configuration;
    my $objtype = $self->objtype();
  
    my @choices;
  
    push @choices, 
    TR({-class => 'searchtitle'},
    th({-align=>'RIGHT',-width=>'25%'},"Genscan location",
    td(textfield('-name'   => $objtype.".location",
                '-size' => 50,
                '-default'=> $current_config->{location} || $self->config_defaults->{location}))));
    push @choices,  
    TR({-class => 'searchtitle'},
    th({-align=>'RIGHT',-width=>'25%'},"Genscan parameter file",
    td(popup_menu('-name'   => $objtype.".parameters",
                  '-values' => [qw(Arabidopsis HumanIso Maize)],
                    '-default'=> $current_config->{parameters} || $self->config_defaults->{parameters}))));
    my $html= table(@choices);
    return $html;
}
  
sub annotate {
    my $self    = shift;
    my $segment = shift;
    my $dna     = $segment->seq;
    
    my $abs_start = $segment->start;
    my $abs_end   = $segment->end;
    my $length    = $segment->length;
    
    my $feature_list   = Bio::Graphics::FeatureFile->new;
    $feature_list->add_type( gene => {
                                glyph => 'genscan_transcript',
                                key   => 'Genscan',
                                bgcolor => 'green'
                        });
    
    my $genesRef = $self->runGenscan($dna);
    
    return unless $genesRef;

    foreach my $gene (@$genesRef) 
    {
        my $gene_start = $gene->start;
        my $gene_end =  $gene->end;
        my $feature       = Bio::SeqFeature::Generic->new(
                            -start=>$abs_start+$gene_start,
                            -end  =>$abs_start+$gene_end,
                            -strand => $gene->strand,
                            #-display_name => $gene->index,
                            -primary_tag=>'gene',
                            -tag => {});
    
        #warn "creating a gene from $gene_start to $gene_end\n";
    
        foreach my $exon ($gene->exons)
        {
                my $exon_start = $exon->start;
                my $exon_end = $exon->end;
            #warn "creating an exon from $exon_start to $exon_end\n";
    
            my $exon_feature = Bio::SeqFeature::Generic->new(
                                    -start=>$abs_start+$exon_start,
                                    -end  =>$abs_start+$exon_end,
                                    -strand => $exon->strand,
                                    -primary_tag => 'exon');
            $feature->add_SeqFeature($exon_feature,'EXPAND');
        }
    
        my $middleOfGene = 1;
    
        my $polyA = $gene->poly_A_site;
        if ($polyA)
        {
            $middleOfGene = 0;
    
            my $polyA_feature = Bio::SeqFeature::Generic->new(
                                    -start=>$abs_start+$polyA->start,
                                    -end  =>$abs_start+$polyA->end,
                                    -strand => $polyA->strand,
                                    -primary_tag => 'polyA',
                                    -glyph => 'dot');
                $feature->add_SeqFeature($polyA_feature,'EXPAND');
        }
    
        my @promoters = $gene->promoters;
        foreach my $prom (@promoters)
        {
            $middleOfGene = 0;
    
            my $prom_feature = Bio::SeqFeature::Generic->new(
                                    -start=>$abs_start+$prom->start,
                                    -end  =>$abs_start+$prom->end,
                                    -strand => $prom->strand,
                                    -primary_tag => 'prom');
                $feature->add_SeqFeature($prom_feature,'EXPAND');
        }
    
        #We have to store this in the tag to figure out whether to draw the strand arrow.
        #We only need the error if neither polyA nor promoter exons are found, so the direction would not be clear.
        if ($middleOfGene)
        {
            $feature->add_tag_value ("middleOfGene", 1);
        }
    
        $feature_list->add_feature($feature,'gene');
    }

    return $feature_list;
}

sub runGenscan
{
    my ($self, $dna) = @_;
    my ($inputFile, $inputFH, $outputFile, $outputFH);
    my $current_config = $self->configuration;
    
    do {$inputFile = tmpnam() }
    until $inputFH = IO::File->new($inputFile, O_RDWR|O_CREAT|O_EXCL);
    
    do {$outputFile = tmpnam() }
    until $outputFH = IO::File->new($outputFile, O_RDWR|O_CREAT|O_EXCL);
    
    $inputFH->autoflush(1);
    $outputFH->autoflush(1);
    print $inputFH ">gi Fake name\n";
    print $inputFH $dna;

    my $location = $current_config->{location}."/";

    unless (-e "$location/genscan" && -x "$location/genscan")
    {
        warn "Genscan executable not found in $location\n";
    }

    unless (-e "$location/".$current_config->{parameters}.".smat")
    {
        warn "Parameter file ". $current_config->{parameters} . ".smat not found in $location\n";
    }

    my $invocation = $location."genscan ".$location.$current_config->{parameters}.".smat $inputFile > $outputFile 2>&1";
    my $result = `$invocation`;

    #`cp $outputFile /tmp/aaa`;

    my $genscan = Bio::Tools::Genscan->new(-file => $outputFile);

    my $genesRef;

    # parse the results
    # note: this class is-a Bio::Tools::AnalysisResult which implements
    # Bio::SeqAnalysisParserI, i.e., $genscan->next_feature() is the same
    while(my $gene = $genscan->next_prediction()) {
        # $gene is an instance of Bio::Tools::Prediction::Gene, which inherits
        # off Bio::SeqFeature::Gene::Transcript.
        #
        # $gene->exons() returns an array of
        # Bio::Tools::Prediction::Exon objects
        # all exons:
        my @exon_arr = $gene->exons();
                        
        push @$genesRef, $gene;
    
    }

    # essential if you gave a filename at initialization (otherwise the file
    # will stay open)
    $genscan->close();
    
    return $genesRef;
    
    END {unlink($inputFile); unlink($outputFile);}


}

sub objtype {
    ( split(/::/,ref(shift)))[-1];
}


1;

