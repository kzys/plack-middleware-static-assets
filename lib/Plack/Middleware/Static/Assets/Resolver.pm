package Plack::Middleware::Static::Assets::Resolver;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(index _files));

use Plack::Middleware::Static::Assets::File;

sub new {
    my ($class, @rest) = @_;
    my $self = $class->SUPER::new(@rest);

    if (! $self->_files) {
        $self->{_files} = [];
    }

    return $self;
}

sub add {
    my ($self, $file) = @_;
    push @{$self->_files}, $file;
}

sub generate_index {
    my ($self, $path) = @_;

    my %result = map {
        $_->path => $_->digest;
    } @{ $self->_files };

    return \%result;
}

sub resolve {
    my ($self, $path) = @_;
    Plack::Middleware::Static::Assets::File::path_with_digest(
        $path,
        $self->index->{$path},
    );
}

1;
