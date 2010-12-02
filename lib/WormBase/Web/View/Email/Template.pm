package WormBase::Web::View::Email::Template;

use strict;
use base 'Catalyst::View::Email::Template';

__PACKAGE__->config(
    stash_key       => 'email',
    template_prefix => '',
    default => {
                content_type => 'text/html',
                charset => 'utf-8',
		view => "TT",
            },

);

=head1 NAME

WormBase::Web::View::Email::Template - Templated Email View for WormBase::Web

=head1 DESCRIPTION

View for sending template-generated email from WormBase::Web. 

=head1 AUTHOR

A clever guy

=head1 SEE ALSO

L<WormBase::Web>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
