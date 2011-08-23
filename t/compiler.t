use strict;
use warnings;
use Test::More;

use_ok 'Plack::Middleware::Static::Assets::Compiler';

subtest 'Compiler should return a "compiled" script file.' => sub {
    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => [ 't/app/assets' ],
    });
    my $content = $compiler->compile_content('t/app/assets/hello.js');

    like($content, qr/^var\s+Hello\s+=/xms);
};

subtest 'Compiler should return a script file with a digest value.' => sub {
    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => [ 't/app/assets' ],
    });

    my $file = $compiler->compile('t/app/assets/hello.js');
    ok($file->content);
    is($file->digest, '7e051e23ce33463e49f82fecdc704540');
    is(
        $file->compiled_path,
        't/app/assets/hello-7e051e23ce33463e49f82fecdc704540.js'
    );
};

subtest 'Compiler should take an argument "filter" for minify.' => sub {
    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => [ 't/app/assets' ],
        filter => sub {
            my $s = shift;
            $s =~ s/[\r\n]+/;/xmsg;
            $s =~ s/;+/;/xmsg;
            $s;
        }
    });

    my $file = $compiler->compile('t/app/assets/hello.js');
    is($file->content, 'function Common() {;};var Hello = new Common;');
};

done_testing;
