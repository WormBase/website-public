package WormBase::API::Service::rserve;

use IPC::Run3;

use Moose;
with 'WormBase::API::Role::Object';

has 'plot' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        return $self->rserve_image;
    }
);

sub rserve_image {
    my $r_program = <<EOP
library("Defaults")
setDefaults(q, save="no")
useDefaults(q)

library("ggplot2")
ggplot(mtcars, aes(factor(cyl))) + geom_bar()
EOP
;
    run3([ 'ruby', 'script/rserve_client.rb' ], \$r_program);

    return {
        uri => 'data from controller'
    };
}

1;

