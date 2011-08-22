use strict;
use warnings;
use Test::More;

use Plack::Middleware::Static::Assets::Compiler;
use Plack::Middleware::Static::Assets::Resolver;

my $index;

subtest 'generate_index' => sub {
    my $resolver = Plack::Middleware::Static::Assets::Resolver->new;
    is_deeply(
        $resolver->generate_index,
        +{},
    );

    my $compiler = Plack::Middleware::Static::Assets::Compiler->new({
        load_path => [ 't/app/assets' ],
    });
    $resolver->add($compiler->publish('t/app/assets/hello.js'));

    $index = $resolver->generate_index;
    is_deeply(
        $index,
        +{ 't/app/assets/hello.js' => '7e051e23ce33463e49f82fecdc704540' },
    );
};

subtest 'resolve' => sub {
    my $resolver = Plack::Middleware::Static::Assets::Resolver->new({
        index => $index
    });
    is(
        $resolver->resolve('t/app/assets/hello.js'),
        't/app/assets/hello-7e051e23ce33463e49f82fecdc704540.js'
    );
};

done_testing;
