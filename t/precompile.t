use strict;
use warnings;
use Test::More;
use Path::Class;

use Plack::Middleware::Static::Assets::Compiler;

my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
    base_dir => 't/app/assets',
});

my ($filename, $content) = $compiler->publish('hello.js');
is($filename, 'hello-7e051e23ce33463e49f82fecdc704540.js');

done_testing;
