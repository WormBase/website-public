package WormBase::API::Service::print;

use File::Temp;
use Moose;
with 'WormBase::API::Role::Object'; 

has 'file_dir' => (
    is => 'ro',
    lazy => 1,
    default => sub {
	return shift->tmp_dir('print');
    }
);

sub run {
    my ($self,$path) = @_;
    $self->log->debug("print the page into pdf");
    my $temp_file = File::Temp->new(
        TEMPLATE => "wormbase_XXXXX",
        DIR      => $self->file_dir,
        SUFFIX   => ".pdf",
        UNLINK   => 0,
    );
 
    my $out_file = $temp_file->filename;
    my $command_line = $self->pre_compile->{PRO_EXEC}.qq{ --url='}.$path.qq{' --out=}.$out_file;
    $self->log->debug($command_line);
    my $result = `$command_line`;
    
    return $result ? 0:$out_file;
}
 
sub error {
  return 0;

}
sub message {
  return 0;

}

1;
