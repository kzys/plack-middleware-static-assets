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
    my $resp = $cb->(GET '/public/assets/recursive.js');
    ok($resp->is_success);

    like($resp->content, qr/\swas\salready\sloaded\./);
};

done_testing;
