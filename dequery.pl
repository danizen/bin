#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use File::Basename;
use LWP::UserAgent;
use URI;

use lib '/usr/local/lib64/perl5';

use NLM::DBPassword qw/getDBPassword/;

sub usage {
    my $progname = basename($0);
    print STDERR "Usage: $progname [-uri baseuri] [-username username] [-s source] [-b binning] queryterms...\n";
    exit 1;
}

my $baseuri = "http://localhost:8080/vivisimo/cgi-bin/velocity";
my $username = 'api_user';

GetOptions(
        "uri=s" => \$baseuri, 
        "username=s" => \$username, 
        "password=s" => \my $password,
        "syntax=s" => \my $syntax,
        "cluster" => \my $cluster,
        "s=s" => \my @sources,
        "b=s" => \my @binning
        ) || &usage;

int(@ARGV) >= 1 || &usage;
my $query = join(@ARGV, ' ');

@sources || (@sources = ( 'discovery-bundle' ));

$baseuri =~ s{/$}{};

unless ($password) {
    $password = getDBPassword("$username\@dataexplorer");
    die "Cannot get password" unless $password;
}


my $ua = LWP::UserAgent->new;
$ua->agent("DataExplorer CLI client/1.0");

my $params = { 
     'v.function' => 'query-search',
     'v.app' => 'api-rest',
     'v.username' => $username,
     'v.password' => $password,
     'query' => $query,
     'sources' => join(@sources, ' ')
};

$params->{'syntax-repository-node'} = $syntax if $syntax;
$params->{'cluster'} = 1 if $cluster;

my $uri = URI->new($baseuri);
$uri->query_form($params);

my $req = HTTP::Request->new(GET => $uri);
my $res = $ua->request($req);

if ($res->is_success) {
    open STDOUT, "| xmllint -format -";
    print $res->content;
    close STDOUT;
    exit 0;
} else {
    print $res->status_line, "\n";
    exit 1;
}

