package WormBase::Test::Web::REST;

use strict;
use warnings;
use Carp;
use Readonly;
use Config::General;
use Test::Builder;

use namespace::autoclean;

use WormBase::Test::Web;
use base 'WormBase::Test::Web';

my $Test = Test::Builder->new;

Readonly our $WIDGET_BASE => '/rest/widget';
sub WIDGET_BASE() { return $WIDGET_BASE };

sub new {
    my $class = shift;
    my $args  = shift;

    my $self = $class->SUPER::new($args);
    my $conf_file = $args->{conf_file}
        or croak 'Must provide conf_file';
    croak "$conf_file does not exist" unless -e $conf_file;

    my %config = Config::General->new(-ConfigFile => $conf_file)->getall
        or croak "$conf_file does not have sections block";
    $self->{sections} = $config{sections};

    $self->class($args->{class}) if $args->{class};

    return bless $self, $class;
}

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

sub sections { # accessor
    my $self = shift;
    # could use $c->config(...) if local server
    return $self->{sections};
}

# 1 level deep in sections hash; generalize to n-level deep?
sub get_section {
    my ($self, $section) = @_;

    my $sections = $self->sections;
    foreach my $section_type (keys %$sections) {
        if (exists $sections->{$section_type}->{$section}) {
            return $sections->{$section_type}->{$section};
        }
    }
    croak "Cannot find $section section in provided config file!\n";
}

# basically the non-exception form of get_section
sub has_section {
    my ($self, $section) = @_;

    return eval { $self->get_section($section) };
}

sub _canonical_class {
    my $self = shift;
    return lc shift;
}

sub check_all_widgets {
    my ($self, $args) = @_;
    croak 'Argument hash required' unless $args && ref $args eq 'HASH';

    my $class = $self->_canonical_class($args->{class} || $self->class)
        or croak 'Class needs to be set or provided as an arg';
    my $uclass = ucfirst $class;
    my $objs = $args->{object} || $args->{objects};
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
            "All widgets ok for $obj $uclass",
            sub {
                foreach my $widget (keys %$widgets) {
                    my $widget_data = $self->get_widget({object => $obj,
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

sub get_widget {
    my ($self, $args) = @_;
    croak 'Argument hash required' unless $args && ref $args eq 'HASH';

    my $class = $self->_canonical_class($args->{class} || $self->class)
        or croak 'Class needs to be set or provided as an arg';
    my $obj = $args->{object}
        or croak 'Object needs to be provided as an arg';
    my $widget = $args->{widget}
        or croak 'Widget needs to be provided as an arg';

    # can make use of $c->uri_for(...) if local server
    my $url = "$WIDGET_BASE/$class/$obj/$widget";

    if ($args->{_test}) {
        my $testname = "GET $widget widget from $obj " . ucfirst $class;
        return $self->mech->get_ok($url, $testname);
    }

    my $res = $self->mech->get($url);
    return $res->is_success ? $res->decoded_content : undef;
}

sub get_widget_ok {
    my ($self, $args) = @_;
    croak 'Argument hash required' unless $args && ref $args eq 'HASH';

    return $self->get_widget({%$args, _test => 1});
}

1;
