package WormBase::API::Service::rserve;

use File::Basename;
use File::Copy;
use File::Spec::Functions qw(catfile);
use File::Path qw(make_path remove_tree);
use IPC::Run3;
use Data::UUID;
use Digest::MD5 qw(md5);

use Moose;
use Statistics::R::IO;

with 'WormBase::API::Role::Object';


has 'version' => (
    is => 'ro',
);

sub init_chart {
    my ($self, $filename, $data, $format) = @_;

    # Setup output file:
    my $image_tmp_path = undef;
    if (defined $filename) {
        $image_tmp_path = "/tmp/" . $filename;
    } else  {
        my $uuid_generator = new Data::UUID;
        my $image_basename = $uuid_generator->create_str();
        $image_tmp_path = "/tmp/" . $image_basename . "." . $format;
    }
    my $image_filename = basename($image_tmp_path);

    my @labels = ();
    my @values = ();
    my @projects = ();
    my @life_stages = ();

    foreach my $datum (@$data) {
        push(@labels, '"' . $datum->{label} . '"');
        push(@values, $datum->{value});
        push(@projects, '"' . $datum->{project_info}->{id} . '"');
        push(@life_stages, '"' . $datum->{life_stage}->{label} . '"');
    }
    my $label_list = join(",\n", @labels);
    my $value_list = join(",\n", @values);
    my $project_list = join(",\n", @projects);
    my $life_stage_list = join(",\n", @life_stages);

    return ($image_tmp_path, $image_filename, $label_list, $value_list, $project_list, $life_stage_list);
}

# execute the R program, locate the output in $output_tmp_path, and
# relocate the output to $rel_dir, relative to
# WormBase::Web->config->{rplots} . $self->version
# NOTE: $output_tmp_path can be BOTH a file path or dir path;
#       $rel_dir can ONLY be a dir path
sub execute_r_program {
    my ($self, $r_program, $output_tmp_path, $rel_dir) = @_;

    # name of the output file (can be a directory)
    my $output_tmp_name = $self->_file_name($output_tmp_path);

    my $destination_dir = catfile(WormBase::Web->config->{rplots},
                                  $self->version,
                                  $rel_dir);
    my $destination_file = catfile($destination_dir, $output_tmp_name);

    # if (WormBase::Web->config->{installation_type} eq 'development') {
    #     remove_tree($destination_file);
    # }

    if  ( (! -e ($destination_file)) ||
         WormBase::Web->config->{installation_type} eq 'development') {

    #    run3([ 'ruby', 'script/rserve_client.rb' ], \$r_program);
        my $r = Statistics::R::IO::Rserve->new();
        $r->eval("
            dir.create('$output_tmp_path', recursive=TRUE)
            dir.create('$destination_file', recursive=TRUE)
            Sys.chmod(c('$output_tmp_path', '$destination_dir', '$destination_file'), mode = '0775', use_umask = FALSE)
        ");  #directory owner & group = jenkins, but allow everyone r_x permision
     #   $r->eval("setwd('$output_tmp_path')");
        $r->eval("setwd('$destination_file')");
        $r->eval($r_program);
        $r->close();

        # # An accessible directory on the web-server, the output will eventually go
        # # Create if not already exists
        # my $umask_old = umask;
        # umask 0000;  #needs permision for deleting $destination_file
        # make_path($destination_dir);
        # umask $umask_old;  # reset permissions

        # Relocate the plot to accessible places on the server
#        system('mv', $output_tmp_path, $destination_dir);
        # Without right permission, mv here becomes cp and the tmp dir fills with images.
    }

    my @files = glob(catfile($destination_file, '*'));

    # Return the absolute URI (relative to the server) of the generated image:
    return {
        uri_base => catfile(WormBase::Web->config->{rplots_url_suffix},
                            $self->version,
                            $rel_dir,
                            $output_tmp_name),
        filenames => [map {$self->_file_name($_) } @files],
    };
}

# Take customization parameters and return values that can be used in an R command:
sub barboxchart_parameters {
    my ($self, $customization) = @_;

    my $height = $customization->{height};
    if ($customization->{adjust_height_for_less_than_X_facets}) {
        my $normally_assumed_facets = $customization->{adjust_height_for_less_than_X_facets};
        my $actual_num_facets = 'length(levels(factor(projects)))';
        $height = "min($height, $height * $actual_num_facets / $normally_assumed_facets )";
    }

    # Pretty-ization:
    return ($customization->{filename},
            $customization->{xlabel},
            $customization->{ylabel},
            $customization->{width},
            $height,
            $customization->{rotate} ? " + coord_flip()" : "",
            $customization->{bw} ? "scale_fill_manual(values = rep(\"white\", length(projects))" : "scale_fill_brewer(palette = \"Dark2\"",
            $customization->{facets} ? ", guide = FALSE" : "",
            $customization->{facets} ? " + facet_grid(projects ~ .)" : "");
}


# Plots a boxplot with the given values and labels. This implementation
# is currently tailored to work with data that also provides information
# about project and life stage association.
#
# Format example:
#
#  [
#    {
#      'value'      => '3.97874',
#      'label'      => 'RNASeq_Hillier.L4_larva_Male_cap2_Replicate2',
#      'project'    => 'RNASeq_Hillier',
#      'life_stage' => 'WBls:0000024'
#    },
#    {
#      'value'      => '1e-10',
#      'label'      => 'RNASeq.elegans.SRP015688.L4.linker-cells.nhr-67.4',
#      'project'    => 'RNASeq_Hillier',
#      'life_stage' => 'WBls:0000024'
#    },
#    {
#      'value'      => '5.7759',
#      'label'      => 'RNASeq_Hillier.L4_Larva_Replicate1',
#      'project'    => 'RNASeq_Hillier',
#      'life_stage' => 'WBls:0000024'
#    },
#    ...
sub boxplot {
    my ($self, $data, $customization) = @_;

    # Pretty-ization:
    my ($filename, $xlabel, $ylabel, $width, $height, $rotate, $coloring, $facets_guides, $facets_grid) = $self->barboxchart_parameters($customization);
    ($width, $height) = (5, 2.5);
    my $dpi = 120;

    my $format = "png";
    my ($image_tmp_path, $image_filename, $label_list, $value_list, $project_list, $life_stage_list) = $self->init_chart($filename, $data, $format);
    my ($dirname) = $filename =~ /(.+)\.\w+/;

    $image_tmp_path = catfile('/tmp', $dirname);

    # Run the R program that plots the barchart:
    my $r_program = <<EOP
library("Defaults");
setDefaults(q, save="no");
useDefaults(q);

library("ggplot2");
library("plyr");

labels = c($label_list);
values = c($value_list);
projects = c($project_list);
life_stages = c($life_stage_list);
data = data.frame(labels, values, projects, life_stages);

# Preserve ordering:
data\$life_stages = factor(life_stages, levels = life_stages, ordered = TRUE);

fpkm_summary <- function(data, fileDir=''){

    reduced <- ddply(data, ~projects, function(jDat){
        g <- ggplot(jDat, aes(x = life_stages, y = values)) + geom_boxplot() + coord_flip()
        g <- g + labs(x = "$xlabel", y = "$ylabel") + ggtitle(jDat\$projects[1])
        g <- g + theme(
            text = element_text(size = 11),
            axis.text = element_text(colour = 'black'),
            panel.background = theme_rect(fill = 'transparent',colour = NA),
            panel.grid.minor = theme_line(color='gray'),
            panel.grid.major = theme_line(color='darkgray'),
            plot.background = theme_rect(fill = "transparent",colour = NA)

        )
        fileName <- paste(jDat\$projects[1], '$format', sep='.')
        ggsave(fileName, width=$width, height=$height, dpi=$dpi, bg='transparent')
        return(data.frame(
            num = nrow(jDat),
            as.list(quantile(jDat\$values))
        ))
    })
    return(reduced)
}

# # #sDat = subset(data, projects=="Hillier modENCODE deep sequencing")
fpkm_summary(data, "$image_tmp_path")

EOP
;

    # Return the absolute URI (relative to the server) of the generated image:
    my $exe_r_summary = $self->execute_r_program($r_program,
                                                 $image_tmp_path,
                                                 $self->_rplot_subdir($filename));
    my $uri_base = $exe_r_summary->{uri_base};

    my @plots = map {
        my ($project_id) = $_ =~ /(.+)\.\w+$/;
        {
            project_id => $project_id,
            uri => catfile($uri_base, $_),
        }
    } @{$exe_r_summary->{filenames}};
    return @plots ? \@plots : undef;
}

sub _rplot_subdir {
    my ($self, $filekey) = @_;
    # # If sub-dir usage is configured to spread image files over multiple directories,
    # # then check whether the directory exists or not. If not, well, create it!
    # if (defined WormBase::Web->config->{rplots_subdirs} && WormBase::Web->config->{rplots_subdirs}){
    if (defined WormBase::Web->config->{rplots_subdirs} && WormBase::Web->config->{rplots_subdirs} > 0) {
        return unpack('L', md5($filekey)) % WormBase::Web->config->{rplots_subdirs} . '/';
    }

    return '';
}

sub _file_name {
    my ($self, $path) = @_;
    my ($filename) = $path =~ /([^\/]+)\/?$/;
    return $filename;
}

1;
