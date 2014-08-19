package WormBase::API::Role::ThirdParty::OMIM;

use Moose::Role;
use HTTP::Request;
use JSON;


# stores locally OMIM objects that has been requested
has 'known_omims' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },  # reinitialized for individual objects
);

# minutes wait if external resource responds with an error
has 'min_wait_time' => (
    is      => 'ro',
    isa     => 'Int',
    default => 10,
);

our $_resource_error = {};  # initialized for the class
has 'resource_error' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { return $_resource_error },
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

# Ensure that if an resource_error has occured, a minimum waiting time has passed
# After which the resource_error field is reset, and a True value is returned by the subroutine
sub waited {
    my ($self) = @_;
    return 1 unless (exists $self->resource_error->{'error_time'});

    my $seconds_passed = time() - $self->resource_error->{'error_time'};
    my $ok_to_proceed = $seconds_passed >= (60 * $self->min_wait_time);
    if ($ok_to_proceed){
        for (keys %{$self->resource_error}) {
            delete $self->resource_error->{$_};
        }
    }
    return $ok_to_proceed;
}

# process http response based on the response code
# unless code equals 200, the $resource_error field is updated
sub _process_response {
    my ($self, $response) = @_;
    my $omim_data_map;
    if ($response->code eq '200'){
        my $response_content = $response->content;
        $omim_data_map = $self->_extract($response_content);
        foreach my $omim_id (keys %$omim_data_map){
            $self->known_omims->{$omim_id} = $omim_data_map->{$omim_id};
        }
    } else {
        my $time;
        my $external_source = __PACKAGE__;
        $self->resource_error->{'error_time'} = time();
        $self->resource_error->{'error_code'} = $response->code;
        $self->resource_error->{'message'} = "$external_source resource abuse";
        $self->resource_error->{'external_resource'} = "$external_source";
        die 'Failed to retrieve external data';
    }
    return $omim_data_map;
}

# call external api and update the local hash of previously requested items
sub _omim_external {
    # die '!!! Automatically dead for testing !!!';  # uncomment to simulate the behavior when the external resource is down
    my ($self, $omim_ids) = @_;
    my $unknown_omim_ids = $self->_select_unknown($omim_ids);
    return unless $unknown_omim_ids;

    die 'Request stopped until some time has passed' unless $self->waited();

    my $path = WormBase::Web->path_to('/') . '/credentials';
    my $api_key = `cat $path/omim_apikey.txt`;
    chomp $api_key;
    die 'No API key' unless $api_key;

    my $header_opts = {
        mimNumber => $unknown_omim_ids,
   #     include => 'text:description',
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

    return $self->_process_response($response);
}

# get short title of omim from the preferredTitle field
sub short_title {
    my ($self, $orig_title) = @_;
    my @titles = split(/;\s*/, $orig_title);
    return @titles? shift(@titles) : undef;
}

# for each ID in a list of omim IDs, create special label (that include data requested from external API)
sub markup_omims {
    my ($self, $omim_ids) = @_;

    my $err;
    eval {
        $self->_omim_external($omim_ids);
        1;
    } || do {
        $err = $@;
    };
    my @data = ();
    foreach my $oid (@{$omim_ids}){
        my $name;  #base on external info
        if ($self->known_omims->{$oid}){
            $name = $self->known_omims->{$oid}->{'title'};
            $name = $self->short_title($name);
        }

        my $label;
        if ($name){
            $label = $name;
        }else{
            $label = "OMIM:$oid";
        }

        my $dat = {id => $oid,
                   class => 'OMIM',
                   label=> $label,
               };
        push @data, $dat;
    }

    return ($err, @data ? \@data : undef);
}

# helper function
# For an array of hashes, aggregates all errors stored under the key 'error',
# and put them in an array
sub summarize_error {
    my ($self, $data) = @_;
    my @errors;
    my $err;
    foreach (@$data){
        push(@errors, $_->{'error'}) if $_->{'error'};
    }
    return @errors ? \@errors : undef;
}

1;
