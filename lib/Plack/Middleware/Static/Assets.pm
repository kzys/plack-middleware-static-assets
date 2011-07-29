package Plack::Middleware::Static::Assets;
use strict;
use warnings;
use base qw(Plack::Middleware);
use Plack::Util::Accessor qw(dir);
use Plack::Middleware::Static::Assets::Compiler;

our $VERSION = 0.1;

sub call {
    my ($self, $env) = @_;

    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        base_dir => $self->dir,
    });
    my $content = $compiler->compile($env->{PATH_INFO});
    if (defined $content) {
        return [ 200, [], [ $content ] ];
    } else {
        return $self->app->call($env);
    }
}

1;
