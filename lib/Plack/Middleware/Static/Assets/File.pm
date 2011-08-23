package Plack::Middleware::Static::Assets::File;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(path content));

use Digest::MD5 qw(md5_hex);

=head1 NAME

Plack::Middleware::Static::Assets::File

=head1 INSTANCE METHODS

=head2 digest

=cut

sub digest {
    my ($self) = @_;
    md5_hex($self->content);
}

=head2 compiled_path

=cut

sub compiled_path {
    my ($self) = @_;
    path_with_digest($self->path, $self->digest);
}

=head1 UTILITY FUNCTIONS

=head2 path_with_digest

=cut

sub path_with_digest {
    my ($path, $digest) = @_;

    if ($path =~ /^(.*)\.(.*)$/) {
        "$1-$digest.$2";
    } else {
        "$path-$digest";
    }
}

1;
