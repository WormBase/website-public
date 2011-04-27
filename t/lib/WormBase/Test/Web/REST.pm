package WormBase::Test::Web::REST;

use strict;
use warnings;
use Carp;
use Readonly;
use Config::General;
use Test::Builder;

use namespace::autoclean;

use base 'WormBase::Test::Web';

my $Test = Test::Builder->new;

# WormBase REST tester

=head1 NAME

WormBase::Test::Web::REST

=head1 SYNOPSIS


    $tester = WormBase::Test::Web::REST->new({ class => $class });
    $mech = $tester->mech;

    %obj_widgets = $tester->check_all_widgets({ names => $obj_names });
    like($obj_widgets{$obj_name}->{$widget}, $regex);

    # testing that a widget simply works
    $tester->get_widget_ok({ name => $obj_name, widget => $widget });

    # using local server to test RESTful interface with data straight from API
    if ($tester->is_local_server) {
        $api_tester = $tester->api_tester;
        $obj = $api_tester->fetch_object({ name => $name, class => $class });

        # check that some part of the data makes it to the view
        $data = $obj->$field->{data};
        like($obj_widgets{$obj_name}->{$widget}, qr/$data/);
    }


    # more detailed information
    $section = $tester->get_section($class); # config section for the class
    $section->{search} ...;


=head1 DESCRIPTION

Tester class for the WormBase RESTful interface. This is a subclass of
WormBase::Test::Web and makes use of its encapsulated convenience methods.
This class aids in testing the RESTful interface by providing some
common tests and class- and server-aware methods.

=head1 CONSTANTS

Constants related to testing and running the WormBase web application.
These can be accessed as either interpolated variables or
subroutines/methods.

    $WormBase::Test::Web::REST::CONSTANT
    WormBase::Test::Web::REST::CONSTANT

=over

=item B<WIDGET_BASE>

The REST URL base for retrieving widgets.

=cut

Readonly our $WIDGET_BASE => '/rest/widget';
sub WIDGET_BASE() { return $WIDGET_BASE };

=back

=cut

=head1 METHODS

=cut

################################################################################
# Methods
################################################################################

=over

=item B<new($arghash)>

    $tester = WormBase::Test::Web::REST->new({
        conf_file => $filename, # optional on a local server
        class     => $class, # optional but if provided, must be in config
    });

Creates a new tester object with configuration given in the conf_file.

=cut

sub new {
    my $class = shift;
    my $args  = shift;

    my $self = $class->SUPER::new($args);

    if (my $conf_file = $args->{conf_file}) {
        croak "$conf_file does not exist" unless -e $conf_file;

        # not doing further searches for _local or support multiple conf files
        # because sections should be in one place and unchanged on local dev
        # machines. can support in future but will require refactoring from
        # WormBase::Test::API
        my %config = Config::General->new(-ConfigFile => $conf_file)->getall;
        $self->{remote_sections} = $config{sections}
            or croak 'Config does not have "sections" section';
    }
    elsif ($self->is_remote_server) {
        croak "Must provide conf_file to run against a remote server";
    } # else handle config seamlessly

    $self->class($args->{class}) if $args->{class};

    return bless $self, $class;
}

=item B<class([$class])>

    $tester->class($class); # $class must be found in sections or will croak
    $class = $tester->class;

=cut

# resembles Test::API::Object but web interface is not aware of internal,
# fully qualified names
sub class { # accessor/mutator
    my ($self, $param) = @_;
    if ($param) {
        $param = $self->_canonical_class($param); # canonical lowercase
        croak "Class must be string!" if ref $param;
        $self->get_section($param); # will croak if cannot find section
        return $self->{class} = $param;
    }
    return $self->{class};
}

=item B<get_section([$section_name)>

    $all_sections = $tester->get_section;
    $section      = $tester->get_section($class);

Retrieve either all sections present in the config (under the <sections>
block) or a particular one two levels deep (e.g. sections->species->variation).

=cut

sub get_section {
    my ($self, $section) = @_;

    my $sections = $self->is_local_server
                 ? $self->context->config->{sections}
                 : $self->{remote_sections};

    return $sections unless $section;

    foreach my $section_type (keys %$sections) {
        if (exists $sections->{$section_type}->{$section}) {
            return $sections->{$section_type}->{$section};
        }
    }
    croak "Cannot find $section section in config!";
}

=item B<has_section>

    # same arguments as get_section
    $section = $tester->has_section($section_name);

Convenience method for checking whether a section exists in the config.
Returns the hash of the section config if it exists, otherwise false.
This behaves like L<get_section> but returns false instead of an exception.

=cut

sub has_section {
    my $self = shift;

    return eval { $self->get_section(@_) };
}

=item B<get_widget($argshash)>

    $widget = $tester->get_widget({
        name   => $obj_name,
        class  => $class, # optional if already set
        widget => $widget_name,
    });

Retrieves the content of the specified widget via the RESTful interface.
If there are any problems in the retrieval process, returns undef.

=cut

sub get_widget {
    my ($self, $args) = @_;
    croak 'Argument hash required' unless $args && ref $args eq 'HASH';

    my $class = $self->_canonical_class($args->{class} || $self->class)
        or croak 'Class needs to be set or provided as an arg';
    my $obj = $args->{name}
        or croak 'Object name needs to be provided as an arg';
    my $widget = $args->{widget}
        or croak 'Widget needs to be provided as an arg';

    # can make use of $c->uri_for(...) if local server
    my $url = "$WIDGET_BASE/$class/$obj/$widget";

    if ($args->{_test}) {
        my $testname = "GET $widget from $obj " . ucfirst $class;
        return $self->mech->get_ok($url, $testname);
    }

    my $res = $self->mech->get($url);
    return $res->is_success ? $res->decoded_content : undef;
}

=back

=cut

################################################################################
# Test methods
################################################################################

=head2 Test Methods

Methods that emit TAP compatible output.

=over

=item B<get_widget_ok>

Same interface as L<get_widget> but emits TAP output and returns true on
success and false on failure.

=cut

sub get_widget_ok {
    my ($self, $args) = @_;
    croak 'Argument hash required' unless $args && ref $args eq 'HASH';

    return $self->get_widget({%$args, _test => 1});
}

=item B<check_all_widgets>

    $tester->check_all_widgets({
        names => $obj_names, # arrayref of names or single name
        class => $class, # optional if already set
    });

Checks all the widgets of the given objects of the given class. In scalar
context, returns true or false indicating success or failure. In list context,
returns a nested hash of object name => widget => widget content.

=cut

sub check_all_widgets {
    my ($self, $args) = @_;
    croak 'Argument hash required' unless $args && ref $args eq 'HASH';

    my $class = $self->_canonical_class($args->{class} || $self->class)
        or croak 'Class needs to be set or provided as an arg';
    my $uclass = ucfirst $class;
    my $objs = $args->{name} || $args->{names};
    $objs = [$objs] if ref $objs ne 'ARRAY';

    my $section = $self->has_section($class)
        or croak "$class not found in config file";
    my $widgets = $section->{widgets};
    unless ($widgets and %$widgets) {
        croak "No widgets found for $class";
    }


    my $ok = 1;
    my %objwidgets;
    foreach my $obj (@$objs) {
        $ok &&= $Test->subtest(
            "All widgets ok for $obj $uclass", sub {
                foreach my $widget (keys %$widgets) {
                    my $widget_data = $self->get_widget({name   => $obj,
                                                         class  => $class,
                                                         widget => $widget});
                    if ($Test->ok($widget_data,"GET $widget from $obj $uclass")) {
                        $objwidgets{$obj}->{$widget} = $widget_data;
                    }
                }
            }
        );
    }
    return wantarray ? %objwidgets : $ok;
}

=back

=cut

################################################################################
# Private methods
################################################################################

sub _canonical_class {
    my $self = shift;
    return lc shift;
}

=head1 AUTHOR

=head1 BUGS

=head1 SEE ALSO

L<WormBase::Test>, L<WormBase::Test::API>,  L<Test::WWW::Mechanize>,
L<Catalyst::Test>

=head1 COPYRIGHT

=cut

1;
