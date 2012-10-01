#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::WhatPulse' ) || print "Bail out!\n";
}

diag( "Testing Net::WhatPulse $Net::WhatPulse::VERSION, Perl $], $^X" );
