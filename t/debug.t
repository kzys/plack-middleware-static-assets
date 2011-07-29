use strict;
use warnings;
use Test::More;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;

my $app = builder {
    mount '/public/assets/' => builder {
        enable 'Plack::Middleware::Static::Assets', dir => 't/app/assets';
    };
};

test_psgi $app, sub {
    my $cb = shift;
    my $resp = $cb->(GET '/public/assets/not-found.js');
    ok(! $resp->is_success);
};

test_psgi $app, sub {
    my $cb = shift;
    my $resp = $cb->(GET '/public/assets/hello.js');
    ok($resp->is_success);

    like($resp->content, qr/^var\s+Hello\s+/xms);
    like($resp->content, qr/^function\s+Common\(\)/xms);
};

done_testing;
