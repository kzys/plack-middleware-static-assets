package Plack::Middleware::Static::Assets::Compiler;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(load_path));

use List::Util qw(first);
use Path::Class;
use Plack::Middleware::Static::Assets::Resolver;
use Plack::Middleware::Static::Assets::File;
use File::Find;

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

sub _resolve_with {
    my ($self, $name, $load_path) = @_;

    first {
        -f $_
    } map {
        my $basename = $_;
        map {
            dir($_)->file($basename);
        } @{ $self->load_path };
    } ("$name", "$name.js", "$name.css");
}

sub _resolve {
    my ($self, $name) = @_;

    my $e = "Failed to resolve $name";

    if ($name =~ /^<(.*)>$/xms) {
        $self->_resolve_with($1, $self->load_path) || die $e;
    } elsif ($name =~ /^"(.*)"$/xms) {
        $self->_resolve_with($1, [ file($1)->dir ]) || die $e;
    } else {
        die $e;
    }
}

sub _process_require {
    my ($self, $name, $loaded_ref) = @_;

    my $file = file($name);

    if ($loaded_ref->{ "$file" }) {
        return qq{/* $file was already loaded. */\n};
    } else {
        $loaded_ref->{ "$file" } = 1;
    }

    my $content = $file->slurp;
    $content =~ s{^//=\s*require\s+(.*?)$}{
        $self->_process_require($self->_resolve($1), $loaded_ref)
    }xmsge;
    return $content;
}

sub compile {
    my ($self, $path) = @_;

    my %loaded;
    $self->_process_require($path, \%loaded);
}

=head2 compile_dir($src, $dst)

=cut

sub compile_dir {
    my ($self, $src, $dst) = @_;

    my $resolver = Plack::Middleware::Static::Assets::Resolver->new({
        root => $src
    });

    File::Find::find({
        no_chdir => 1,
        wanted => sub {
            my $relative = file($File::Find::name)->relative($src);
            if ($relative !~ /\.js$/) {
                return;
            }

            my $file = $self->publish($File::Find::name);
            $resolver->add($file);

            my $path = file($dst, file($file->compiled_path)->relative($src));
            $path->dir->mkpath;

            my $fh = $path->openw;
            print $fh $file->content;
            close($fh);
        },
    }, $src);

    return $resolver->generate_index;
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
        die "Failed to extract extension from $path.";
    }
}

1;
