#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  test4trace.pl
#
#        USAGE:  ./test4trace.pl <host> <port>
#
#  DESCRIPTION:  The "UI" for this script may not
#                make sense but this is a sub
#                routine of a future version of my
#                cryptonark script that tests for
#                the existence of the TRACE method
#                on a web site.  That's why,
#                syntactically, this script follows
#                cryptonark's syntax and version
#                numbering.
#
#      OPTIONS:  ---
# REQUIREMENTS:  Perl 5.10 & LWP::UserAgent
#         BUGS:  None Found Yet
#        NOTES:  ---
#       AUTHOR:  Chris Mahns
#      COMPANY:  Blogging Techstacks
#      VERSION:  0.3
#      CREATED:  11/03/2009 21:45:30
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use feature ':5.10';

use LWP::UserAgent;

my $host = $ARGV[0];
my $port = $ARGV[1];
my $portpart = '';
my $scheme;

my $help = "Usage:  $0 <hostname> <port>";

if ( !@ARGV ) {
    print $help . "\n";
    exit 0;
}

if ( $port == 443 ) {
    $scheme = 'https';
}
elsif ( $port == 80 ) {
    $scheme = 'http';
}
else {
    $portpart = ":$port";
    $scheme = 'http';
}

sub test_for_trace {
    my $url = "$scheme://$host$portpart/";

    my $method = "TRACE";
    my $ua     = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    $ua->agent('test4trace-pci-auditor/v0.3');
    
    my $request = HTTP::Request->new( $method => $url );
    $request->header(Header0 => "TRACE");
    $request->header(Header1 => "Test");

    my $response = $ua->request($request);

    given ( $response->code ) {
        when (200) {
            say "======this is what you sent======";
            say $response->content;
            say "=================================";
            say $method, " is enabled and working.";
        }
        when (301) {
            say "Redirect present.  Retry request against ",
              $response->header('Location');
        }
        when (302) {
            say "Redirect present.  Retry request against ",
              $response->header('Location');
        }
        when (307) {
            say "Redirect present.  Retry request against ",
              $response->header('Location');
        }
        when (403) {
            say $response->status_line;
            say $method, " is forbidden.";
        }
        when (404) {
            say $response->status_line;
            say "This is an unexpected response";
        }
        when (405) {
            say $response->status_line;
            say $method, " is not permitted.";
        }
        when (501) {
            say $response->status_line;
            say $method, " is not implemented.";
        }
        default {
            say $response->status_line;
        }
    }
}

sub test_for_track {
    my $test = 'This is an HTTP TRACE test.';
    my $url = "$scheme://$host$portpart/";

    my $method = "TRACK";
    my $ua     = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    $ua->agent('test4trace-pci-auditor/v0.3');
    
    my $request = HTTP::Request->new( $method => $url );
    $request->header(Header0 => "TRACK");
    $request->header(Header1 => "Test");

    my $response = $ua->request($request);

    given ( $response->code ) {
        when (200) {
            say "======this is what you sent======";
            say $response->content;
            say "=================================";
            say $method, " is enabled and working.";
        }
        when (301) {
            say "Redirect present.  Retry request against ",
              $response->header('Location');
        }
        when (302) {
            say "Redirect present.  Retry request against ",
              $response->header('Location');
        }
        when (307) {
            say "Redirect present.  Retry request against ",
              $response->header('Location');
        }
        when (403) {
            say $response->status_line;
            say $method, " is forbidden.";
        }
        when (404) {
            say $response->status_line;
            say "This is an unexpected response";
        }
        when (405) {
            say $response->status_line;
            say $method, " is not permitted.";
        }
        when (501) {
            say $response->status_line;
            say $method, " is not implemented.";
        }
        default {
            say $response->status_line;
        }
    }
}
say "First we test for Trace...";
sleep 2;
test_for_trace();

say "\nNow we test for Track...";
sleep 2;
test_for_track();

