package WormBase::Web::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
		     CATALYST_VAR => 'Catalyst',
		     INCLUDE_PATH => [
#				      WormBase::Web->path_to( 'root', 'templates', 'src'    ),
#				      WormBase::Web->path_to( 'root', 'templates', 'lib'    ),
#				      WormBase::Web->path_to( 'root', 'static',    'css'    ),
				      WormBase::Web->path_to( 'root', 'templates' ),
				      WormBase::Web->path_to( 'root', 'templates' , 'config'),
				      WormBase::Web->path_to( 'root', 'static',    'css'    ),
				      WormBase::Web->path_to( 'root', 'static',    'css', 'flora'    ),
				     ],
		     PRE_PROCESS  => 'config/main',
		     WRAPPER      => 'boilerplate/wrapper',
		     ERROR        => 'error',
		     TEMPLATE_EXTENSION => '.tt2',
		     RECURSION    => 1,
		     # Automatically pre- and post-chomp to keep
		     # templates simpler and output cleaner.
		     # Might want to use "2" instead, which collapses.
		     PRE_CHOMP    => 1,
		     POST_CHOMP   => 1,
		     # NOT CURRENTLY IN USE!
		     PLUGIN_BASE  => 'WormBase::Web::View::Template::Plugin',
		     PLUGINS      => {
				      url    => 'WormBase::Web::View::Template::Plugin::URL',
				      image  => 'Template::Plugin::Image',
				      format => 'Template::Plugin::Format',
				      util   => 'WormBase::Web::View::Template::Plugin::Util',
				     },
#		     TIMER        => 1,
#		     DEBUG        => 1,
		     CONSTANTS    => {
				      acedb_version => sub {
					WormBase::Web->model('Model::AceDB')->version
					}
				     },
		    });






=head1 NAME

WormBase::Web::View::TT - Catalyst View

=head1 SYNOPSIS

See L<WormBase>

=head1 DESCRIPTION

Catalyst View.

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

