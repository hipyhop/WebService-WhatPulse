package Net::WhatPulse;

use strict;
use warnings;

use LWP::UserAgent;
use XML::Simple;
use Carp;

our $VERSION = 0.1;

sub new {
    my ( $class, %args ) = @_;
    my $this = bless {
        apiurl        => 'http://whatpulse.org/api',
        user_endpoint => '/user.php?UserID=',
        team_endpoint => '/team.php?TeamID=',
        useragent_str => "Net-WhatPulse/$VERSION",
    }, $class;

    $this->{$_} = $args{$_} for ( keys %args );
    return $this;
}

sub get_user {
    my ( $this, $user ) = @_;
    my $url = join '', $this->{apiurl}, $this->{user_endpoint}, $user;
    if ( my $xml = $this->_fetch_xml($url) ) {
        return $this->_xml_to_hash($xml);
    }
    else {
        return 0;
    }
}

sub get_team {
    my ( $this, $team ) = @_;
    my $url = join '', $this->{apiurl}, $this->{team_endpoint}, $team;
    if ( my $xml = $this->_fetch_xml($url) ) {
        return $this->_xml_to_hash($xml);
    }
    else {
        return 0;
    }
}

sub _xml_to_hash {
    my ( $this, $xml ) = @_;
    return XMLin( $xml, SuppressEmpty => 1 );
}

sub _ua {
    my ( $this, $ua ) = @_;
    $this->{ua} = $ua if defined $ua;
    if ( !defined $this->{ua} ) {
        $ua = LWP::UserAgent->new;
        $ua->agent( $this->{useragent} );
        $this->{ua} = $ua;
    }
    return $this->{ua};
}

sub _fetch_xml {
    my ( $this, $uri ) = @_;
    my $ua = $this->_ua();
    my $req = HTTP::Request->new( GET => $uri );
    $req->header( Accept => 'text/xml' );
    my $res = $ua->request($req);
    if ( $res->is_success ) {
        return $res->content;
    }
    else {
        croak $res->status_line;
        return 0;
    }
}

1;

__END__

=head1 NAME

Net::WhatPulse - Perl module for retrieving WhatPulse.org user or team stats

=head1 VERSION

VERSION 0.1

=head1 SYNOPSIS

    use Net::WhatPulse;

    my $wp = Net::WhatPulse->new;

    my $stats = $wp->get_user('hipyhop');

    while(my ($key, $value) = each %{$stats}){
        print "$key: $value\n";
    }

    if($stats{'TeamID'} != 0){
        my $team_stats = $wp->get_team($stats{'TeamID'});

        while(my ($key, $value) = each %{$team_stats}){
            print "$key: $value\n";
        }
    }

=head1 DESCRIPTION

This module provides a perl interface to the WhatPulse APIs.  

If an XML attribute is empty, for example if the user is not part of a team, the attribute will be surpressed and not appear in the returned data structure. Therefore always check for the existence of an attribute before attempting to use it.

=head1 METHODS AND ARGUMENTS

=over4

=item new

This constructs a C<Net::WhatPulse> object with the default settings. Named parameters can be optionally supplied to change the behaviour of the instance.

=over 4

=item apiurl

This is the default URL of the API, defaults to http://whatpulse.org/api. Modify this if the URL changes or to use a custom server.

Use of 'file:/' is allowed to access local files.

=item user_endpoint

The API endpoint to query for User stats. Defaults to '/user.php?UserID='. The username will be concatenated by the get_user method.

=item team_endpoint

The API endpoint to query for Team stats. Defaults to '/team.php?TeamID='. The team id will be concatenated by the get_user method.

=item useragent_str

A string to be used as the useragent string. Defaults to "Net-WhatPulse/$VERSION".

=item ua

An LWP::UserAgent instance for querying the WhatPulse WebAPI.

=back

=item get_user($username)

Retrieve a HashRef of the User statistics by the username or numeric user_id.

=item get_team($team_id)

Retrieves a HashRef of the Team statistics by the numeric team_id.

=back

=head1 SUPPORT

Please submit all issues to the project page at L<http://github.com/hipyhop/net-whatpulse>

=head1 AUTHOR

Thomas Luff <tomfluff at me dot com>

=cut
