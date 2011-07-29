package Plack::Middleware::Static::Assets;
use strict;
use warnings;
use base qw(Plack::Middleware);
use Plack::Util::Accessor qw(dir);
use Path::Class qw();
use List::Util qw(first);

our $VERSION = 0.1;

sub _find_file {
    my ($self, $name) = @_;

    first {
        -f $_
    } map {
        Path::Class::dir($self->dir)->file($_);
    } ("$name", "$name.js", "$name.css");
}

sub _process_require {
    my ($self, $name, $loaded_ref) = @_;

    my $file = $self->_find_file($name) || return;

    if ($loaded_ref->{ "$file" }) {
        return qq{/* $file was already loaded. */\n};
    } else {
        $loaded_ref->{ "$file" } = 1;
    }

    my $content = $file->slurp;
    $content =~ s{^//=\s*require\s+(.*?)$}{
        $self->_process_require($1, $loaded_ref)
    }xmsge;
    return $content;
}

sub call {
    my ($self, $env) = @_;

    my %loaded;

    my $content = $self->_process_require($env->{PATH_INFO}, \%loaded);
    if (defined $content) {
        return [ 200, [], [ $content ] ];
    } else {
        return $self->app->call($env);
    }
}

1;
