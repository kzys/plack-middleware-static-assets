package Plack::Middleware::Static::Assets::Compiler;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(load_path));

use List::Util qw(first);
use Path::Class;
use Plack::Middleware::Static::Assets::File;

sub new {
    my ($class, @rest) = @_;
    my $self = $class->SUPER::new(@rest);
    $self->{load_path} ||= [ '.' ];
    return $self;
}

sub _find_file {
    my ($self, $name) = @_;

    first {
        -f $_
    } map {
        my $basename = $_;
        map {
            dir($_)->file($basename);
        } @{ $self->load_path };
    } ("$name", "$name.js", "$name.css");
}

sub _process_require {
    my ($self, $name, $loaded_ref) = @_;

    my $file = $self->_find_file($name) || die "Failed to find file: $name";

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

sub publish {
    my ($self, $path) = @_;

    my $content = $self->compile($path);

    if ($path =~ /^(.*)\.(.*)$/) {
        return Plack::Middleware::Static::Assets::File->new({
            path => $path,
            content => $content,
        });
    } else {
        die;
    }
}

1;
