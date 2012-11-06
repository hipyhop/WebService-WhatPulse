#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WebService::WhatPulse' ) || print "Bail out!\n";
}

diag( "Testing WebService::WhatPulse $WebService::WhatPulse::VERSION, Perl $], $^X" );
