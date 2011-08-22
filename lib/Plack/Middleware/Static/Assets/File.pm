package Plack::Middleware::Static::Assets::File;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(path content));

use Digest::MD5 qw(md5_hex);

sub digest {
    my ($self) = @_;
    md5_hex($self->content);
}

sub path_with_digest {
    my ($path, $digest) = @_;

    if ($path =~ /^(.*)\.(.*)$/) {
        "$1-$digest.$2";
    } else {
        "$path-$digest";
    }
}

sub compiled_path {
    my ($self) = @_;
    path_with_digest($self->path, $self->digest);
}

1;
