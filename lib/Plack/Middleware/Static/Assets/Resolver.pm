package Plack::Middleware::Static::Assets::Resolver;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(root index _files));

use Plack::Middleware::Static::Assets::File;
use Path::Class;

=head1 NAME

Plack::Middleware::Static::Assets::Resolver

=head1 CLASS METHODS

=head2 new({ root => $root, index => $index })

=cut

sub new {
    my ($class, @rest) = @_;
    my $self = $class->SUPER::new(@rest);

    if (! $self->_files) {
        $self->{_files} = [];
    }

    return $self;
}

=head1 INSTANCE METHODS

=head2 add($file)

=cut

sub add {
    my ($self, $file) = @_;
    push @{$self->_files}, $file;
}

=head2 generate_index

=cut

sub generate_index {
    my ($self) = @_;

    my %result = map {
        file($_->path)->relative($self->root) => $_->digest;
    } @{ $self->_files };

    return \%result;
}

=head2 resolve($path)

=cut

sub resolve {
    my ($self, $path) = @_;

    Plack::Middleware::Static::Assets::File::path_with_digest(
        $path,
        $self->index->{$path},
    );
}

1;
