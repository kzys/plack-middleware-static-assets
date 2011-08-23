use strict;
use warnings;
use Test::More;
use Path::Class;

use Plack::Middleware::Static::Assets::Compiler;
use Plack::Builder;
use Plack::Test;
use HTTP::Request::Common;
use File::Temp qw(tempdir);

sub _application {
    my ($static_dir, $index) = @_;

    my $resolver = Plack::Middleware::Static::Assets::Resolver->new({
        index => $index
    });

    my $asset_file = sub {
        $resolver->resolve('hello.js');
    };

    my $app = builder {
        enable 'Plack::Middleware::Static',
            path => sub { s{^/static/}{} }, root => $static_dir;
        sub {
            [ 200, [], [ '/static/' . $asset_file->('hello.js') ] ];
        };
    };
}

my $dir = tempdir(CLEANUP => 1);
my $index;

subtest 'Compiler should write a file' => sub {
    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => [ 't/app/assets' ],
    });
    $index = $compiler->compile_dir('t/app/assets', $dir);
    ok(-f "$dir/hello-7e051e23ce33463e49f82fecdc704540.js")
};

subtest 'An application can serve compiled files like so' => sub {
    test_psgi _application($dir, $index), sub {
        my $cb = shift;

        my $resp_app = $cb->(GET '/app');
        is(
            $resp_app->content,
            '/static/hello-7e051e23ce33463e49f82fecdc704540.js'
        );

        my $resp_subresource = $cb->(GET $resp_app->content);
        like(
            $resp_subresource->content,
            qr{^function\sCommon\(\)}
        );
    };
};

done_testing;
