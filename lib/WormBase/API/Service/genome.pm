package WormBase::API::Service::genome;

use Moose;
with 'WormBase::API::Role::Object';

use Data::Dumper;

# Redirects to the URI set in the configuration under 'gbrowse_base_uri'.
sub gbrowse {
    my ($self, $param, $c) = @_;
    my $tool_parameter = substr($c->req->uri->path, length("/tools/genome/gbrowse/"));

    my $gbrowse_uri = $c->config->{gbrowse_base_uri} . '/' . $tool_parameter;
    if ($c->req->uri->query) {
        $gbrowse_uri .= '?' . $c->req->uri->query;
    }

    return {redirect=>$gbrowse_uri, redirect_as_is=>1};
}
