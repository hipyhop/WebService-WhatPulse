package WebService::WhatPulse;

use strict;
use warnings;

use LWP::UserAgent;
use XML::Simple;
use Carp;

=head1 NAME

WebService::WhatPulse - Perl module for retrieving WhatPulse.org user or team stats

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WebService::WhatPulse;

    my $foo = WebService::WhatPulse->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my ( $class, $args ) = @_;
    my $self = bless {
        api_url        => 'http://api.whatpulse.org',
        user_endpoint => '/user.php?format=json&user=',
        team_endpoint => '/team.php?format=json&team=<TEAMID>',
        pulses_endpoint => '/pulses.php?format=json&user=',
        useragent_str => "WebService-WhatPulse/$VERSION",
    }, $class;

    #Add/override any settings passed in %$args;
    if( ref $args eq 'HASH' ){
        $self->{$_} = $args->{$_} for ( keys %$args );
    }
    return $self;
}

sub get_user {
    my ( $self, $user ) = @_;
    my $url = join '', $self->{apiurl}, $self->{user_endpoint}, $user;
    if ( my $xml = $self->_fetch_xml($url) ) {
        return $self->_xml_to_hash($xml);
    }
    else {
        return 0;
    }
}

sub get_team {
    my ( $self, $team, $show_members ) = @_;
    $team //= $self->{team};
    my $api_url = $self->{api_url};
    my $endpoint = $self->{team_endpoint};

    croak "No team name or id passed to get_team\n" if !defined $team;
    croak "API url or endpoint for teams is not defined\n" if !defined $api_url || !defined $endpoint;


    $endpoint =~ s/<TEAMID>/$team/;
    $endpoint .= "&members=yes" if $show_members;

    $api_url .= $endpoint;

    print $api_url;
#    if ( my $xml = $self->_fetch_xml($url) ) {
#        return $self->_xml_to_hash($xml);
#    }
#    else {
#        return 0;
#    }
}

sub _xml_to_hash {
    my ( $self, $xml ) = @_;
    return XMLin( $xml, SuppressEmpty => 1 );
}

sub _ua {
    my ( $self, $ua ) = @_;
    $self->{ua} = $ua if defined $ua;
    if ( !defined $self->{ua} ) {
        $ua = LWP::UserAgent->new;
        $ua->agent( $self->{useragent} );
        $self->{ua} = $ua;
    }
    return $self->{ua};
}

sub _fetch_xml {
    my ( $self, $uri ) = @_;
    my $ua = $self->_ua();
    my $req = HTTP::Request->new( GET => $uri );
    $req->header( Accept => 'text/xml' );
    my $res = $ua->request($req);
    if ( !$res->is_success ) {
        croak $res->status_line;
    }
    return $res->content;
}

1;

__END__

=head1 DESCRIPTION

This module provides a perl interface to the WhatPulse stats API.

=head1 METHODS AND ARGUMENTS

=over4

=item new

This constructs a C<WebService::WhatPulse> object with the default settings. Named parameters can be optionally supplied to change the behaviour of the instance.

=over 4

=item apiurl

This is the default URL of the API, defaults to http://api.whatpulse.org. Modify this if the URL changes or to use a custom server.

Use of 'file:/' is allowed to access local files.

=item user_endpoint

The API endpoint to query for User stats. Defaults to '/user.php?user='. The username will be concatenated by the get_user method.

=item team_endpoint

The API endpoint to query for Team stats. Defaults to '/team.php?team='. The team id will be concatenated by the get_user method.

=item useragent_str

A string to be used as the useragent string. Defaults to "WebService-WhatPulse/$VERSION".

=item ua

An LWP::UserAgent instance for querying the WhatPulse WebAPI.

=back

=item get_user($username)

Retrieve a HashRef of the User statistics by the username or numeric user_id.

=item get_team($team_id)

Retrieves a HashRef of the Team statistics by the numeric team_id.

=back

=head1 SUPPORT

Please submit all issues to the project page at L<http://github.com/hipyhop/webservice-whatpulse>

=head1 AUTHOR

Thomas Luff <tomfluff at me dot com>

=cut
