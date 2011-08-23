package Plack::Middleware::Static::Assets;
use strict;
use warnings;
use base qw(Plack::Middleware);
use Plack::Util::Accessor qw(root load_path);
use Plack::Middleware::Static::Assets::Compiler;
use File::Spec;

=head1 NAME

Plack::Middleware::Static::Assets

=head1 DESCRIPTION

Plack::Middleware::Static::Assets provides Rails 3 style
JavaScript precompilation and distribution.

This class provides Plack::Middleware that serves JavaScript files on
in-development application. You should not use it on a production environment.

=cut

our $VERSION = 0.1;

sub call {
    my ($self, $env) = @_;

    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => $self->load_path,
    });

    my $path = File::Spec->catfile($self->root, $env->{PATH_INFO});
    my $content = $compiler->compile_content($path);
    if (defined $content) {
        return [ 200, [], [ $content ] ];
    } else {
        return $self->app->call($env);
    }
}

1;

=head1 AUTHOR

Kato Kazuyoshi E<lt>kato.kazuyoshi@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=head2 Asset Pipeline

Asset Pipeline introduced in Rails 3.1.

L<http://ryanbigg.com/guides/asset_pipeline.html>

=head2 Sprockets

L<http://getsprockets.org/>

=cut
