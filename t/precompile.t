use strict;
use warnings;
use Test::More;
use Path::Class;

use Plack::Middleware::Static::Assets::Compiler;

my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
    load_path => [ 't/app/assets' ],
});

my $file = $compiler->publish('t/app/assets/hello.js');
ok($file->content);
is($file->digest, '7e051e23ce33463e49f82fecdc704540');
is(
    $file->compiled_path,
    't/app/assets/hello-7e051e23ce33463e49f82fecdc704540.js'
);

done_testing;
