package WormBase::API::Role::ThirdParty::OMIM;

use Moose::Role;
use HTTP::Request;
use JSON;


has 'known_omims' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },  # reinitialized for individual objects
);

# takes a hashRef of options (parameters of REST api request) and put it into a string
sub _stringfy_options {
    my ($self, $opts) = @_;
    my $result = '';
    foreach my $key (keys %$opts){
        my $val = $opts->{$key};
        if (ref($val) eq 'ARRAY') {
            my @valArr = @{$val};
            $val = join(',', @{$val});
        }
        $result = $result . "$key=$val&";
    }
    return $result;
}

# takes json response and produces a hash on selected fields
# key 'raw' contains the unmodified json response
sub _extract {
    my ($self, $response_json) = @_;
    my $result = {};
    my $json = new JSON;

    my $parsed = $json->allow_nonref->utf8->relaxed->decode($response_json);
    my $entries = $parsed->{'omim'}->{'entryList'};
    foreach my $entry (@{$entries}){
        $entry = $entry->{'entry'};
        my $omim_id = $entry->{'mimNumber'};
        my $omim_title = $entry->{'titles'} && $entry->{'titles'}->{'preferredTitle'};
        $result->{$omim_id} = {
            title => $omim_title,
            raw => $entry
        };

        if (exists $entry->{'textSectionList'}){
            # deals with extracting other text sections list later, if needed
        }
    }
    return $result;
}

#return ids that Haven't been requested through external API
sub _select_unknown {
    my ($self, $omim_ids) = @_;
    my @unknowns = ();
    foreach my $id (@{$omim_ids}){
        unless (exists $self->known_omims->{$id}){
            push @unknowns, $id;
        }
    }
    return @unknowns ? \@unknowns : undef;
}

# call external api and update the local hash of previously requested items
sub _omim_external {
    my ($self, $omim_ids) = @_;
    my $unknown_omim_ids = $self->_select_unknown($omim_ids);
    return $self->known_omims unless $unknown_omim_ids;

    my $path = WormBase::Web->path_to('/') . '/credentials';
    my $api_key = `cat $path/omim_apikey.txt`;
    chomp $api_key;
    return unless $api_key;

    my $header_opts = {
        mimNumber => $unknown_omim_ids,
        include => 'text:description',
        format => 'json',
    };

    my $opt_str = $self->_stringfy_options($header_opts);
    my $url = "http://api.omim.org/api/entry?$opt_str";
    my $req = HTTP::Request->new(GET => $url);
    $req->header(
        'ApiKey' => $api_key,
        'Content-Type' =>'application/json',
    );
    my $lwp       = LWP::UserAgent->new;
    my $response  = $lwp->request($req);
    my $response_content = $response->content;
    my $omim_data_map = $self->_extract($response_content);
    foreach my $omim_id (keys %$omim_data_map){
        $self->known_omims->{$omim_id} = $omim_data_map->{$omim_id};
    }
    return $self->known_omims;
}

# get short title of omim from the preferredTitle field
sub short_title {
    my ($self, $orig_title) = @_;
    my @titles = split(/;\s*/, $orig_title);
    return @titles? pop(@titles) : undef;
}

# for each ID in a list of omim IDs, create special label (that include data requested from external API)
sub markup_omims {
    my ($self, $omim_ids) = @_;
#    $omim_ids = ['300494', '300497'];  # for texting
    $self->_omim_external($omim_ids);
    my @data = ();
    foreach my $oid (@{$omim_ids}){
        next unless exists $self->known_omims->{$oid};  # move on
        my $name = $self->known_omims->{$oid}->{'title'};
        $name = $self->short_title($name);
        my $dat = {id => $oid, 
                   class => 'OMIM',
                   label=> "OMIM:$oid($name)",
               };
        push @data, $dat;
    }
    return @data ? \@data : undef;
}


1;
