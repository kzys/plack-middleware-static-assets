use inc::Module::Install;

name 'Plack-Middleware-Static-Assets';
all_from 'lib/Plack/Middleware/Static/Assets.pm';

requires 'Plack', 0.9;

test_requires 'Test::More', 0.88;

WriteAll;
