use strict;
use warnings;
use Test::More;

use_ok 'Plack::Middleware::Static::Assets::Compiler';

my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
    base_dir => 't/app/assets'
});
my $content = $compiler->compile('hello.js');

like($content, qr/^var\s+Hello\s+=/xms);

done_testing;
