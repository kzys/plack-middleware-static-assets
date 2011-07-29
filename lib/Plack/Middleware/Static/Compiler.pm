package Plack::Middleware::Static::Assets::Compiler;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);

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

sub compile {
    my ($self, $path) = @_;
    my %loaded;
    $self->_process_require($path, \%loaded);
}


1;
