package Plack::Middleware::Static::Assets;
use strict;
use warnings;
use base qw(Plack::Middleware);
use Plack::Util::Accessor qw(root load_path);
use Plack::Middleware::Static::Assets::Compiler;
use File::Spec;

our $VERSION = 0.1;

sub call {
    my ($self, $env) = @_;

    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => $self->load_path,
    });

    my $path = File::Spec->catfile($self->root, $env->{PATH_INFO});
    my $content = $compiler->compile($path);
    if (defined $content) {
        return [ 200, [], [ $content ] ];
    } else {
        return $self->app->call($env);
    }
}

1;
