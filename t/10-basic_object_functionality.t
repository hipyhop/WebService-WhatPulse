use strict;
use warnings;

use Test::More tests => 4;
use Data::Dumper;

use WebService::WhatPulse;

run();

sub run {

    subtest "Simple Constructor testing", \&simple_constructor;
    subtest "Named Paramaters Constructor ", \&params_constructor;

    subtest "Getter/Setter for username", \&get_set_user;
    subtest "Getter/Setter for team", \&get_set_team;
}

sub simple_constructor {
    Test::More::plan ( tests => 1 );

    my $wp = WebService::WhatPulse->new();
    Test::More::isa_ok ( $wp, 'WebService::WhatPulse', "Constructed with no arguments" );
}

sub params_constructor {
    Test::More::plan( tests => 4 );

    my $api_url = 'file:/tmp/';
    my $team_endpoint = 'team.json';
    my $foo = { 'bar' => 'baz' };

    my $wp = WebService::WhatPulse->new( {  'api_url'        => $api_url,
                                            'team_endpoint' => $team_endpoint,
                                            'foo'           => $foo } );

    Test::More::isa_ok ( $wp, 'WebService::WhatPulse', "Construct with named paramaters" );

    Test::More::is ( $wp->{'api_url'}, $api_url, "Set api_url from constructor" );
    Test::More::is ( $wp->{'team_endpoint'}, $team_endpoint, "Set team_endpoint from constructor" );
    Test::More::is_deeply ( $wp->{'foo'}, $foo, "Set arbitrary hash using constructor" );
}

sub get_set_user {
    Test::More::plan ( tests => 3 );

    #Set a dud api_url to prevent get_user_stats doing anything
    my $wp = WebService::WhatPulse->new( {'api_url' => 'file:/tmp/'});

    Test::More::is( $wp->user(), undef, "User undef if not set yet");

    my $username = "hipyhop";
    $wp->user( $username );
    Test::More::is( $wp->user(), $username, "Team getter returns expected value");

    my $username_2 = "phil";

    # Ignore any errors, we just care if the teamname was cached
    eval {$wp->get_user_stats( $username_2 ) };
    Test::More::is( $wp->user(), $username_2 );

}

sub get_set_team {
    Test::More::plan ( tests => 3 );

    #Set a dud api_url to prevent get_team_stats doing anything
    my $wp = WebService::WhatPulse->new( {'api_url' => 'file:/tmp/'});

    Test::More::is( $wp->team(), undef, "Team undef if not set yet");

    my $teamname = "The Flying Dutchman";
    $wp->team( $teamname );
    Test::More::is( $wp->team(), $teamname, "Team getter returns expected value");

    my $teamname_2 = "The London Philharmonic";

    # Ignore any errors, we just care if the teamname was cached
    eval {$wp->get_team_stats( $teamname_2 ) };
    Test::More::is( $wp->team(), $teamname_2 );
}




