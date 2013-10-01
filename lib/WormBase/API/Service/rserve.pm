package WormBase::API::Service::rserve;

use File::Basename;
use File::Copy;
use IPC::Run3;
use Data::UUID;

use Moose;
with 'WormBase::API::Role::Object';

# Plots a barchart with the given values and labels.
#
# Format example:
#
#  [
#    {
#      'value' => '3.97874',
#      'label' => 'RNASeq_Hillier.L4_larva_Male_cap2_Replicate2'
#    },
#    {
#      'value' => '1e-10',
#      'label' => 'RNASeq.elegans.SRP015688.L4.linker-cells.nhr-67.4'
#    },
#    {
#      'value' => '5.7759',
#      'label' => 'RNASeq_Hillier.L4_Larva_Replicate1'
#    },
#    ...
sub barchart {
    my ($self, $data, $customization) = @_;


    # Setup output file:
    my $format = "png";
    my $uuid_generator = new Data::UUID;
    my $image_basename = $uuid_generator->create_str();
    my $image_tmp_path = "/tmp/" . $image_basename . "." . $format;
    my $image_filename = basename($image_tmp_path);

    my @labels = ();
    my @values = ();
    foreach my $datum (@$data) {
        push(@labels, '"' . $datum->{label} . '"');
        push(@values, $datum->{value});
    }
    my $label_list = join(", ", @labels);
    my $value_list = join(", ", @values);

    # Pretty-ization:
    my $xlabel = $customization->{xlabel};
    my $ylabel = $customization->{ylabel};
    my $width  = $customization->{width};
    my $height = $customization->{height};


    # Run the R program that plots the barchart:
    my $r_program = <<EOP
library("Defaults");
setDefaults(q, save="no");
useDefaults(q);

library("ggplot2");
labels = c($label_list);
values = c($value_list);
data = data.frame(labels, values);
$format("$image_tmp_path", width = $width, height = $height);
print(ggplot(data, aes(labels, values, fill = values)) + geom_bar(stat="identity") + coord_flip() + labs(x = "$xlabel", y = "$ylabel"));
dev.off();
EOP
;
    run3([ 'ruby', 'script/rserve_client.rb' ], \$r_program);

    # Relocate the plot into an accessible directory of the web-server:
    copy($image_tmp_path, "/usr/local/wormbase/website-shared-files/html/img-static/rplots/" . $image_filename);

    # Return the absolute URI (relative to the server) of the generated image:
    return {
        uri => "/img-static/rplots/" . $image_filename
    };
}

1;

