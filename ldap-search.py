#!/usr/bin/env perl
# Lookup users and groups in LDAP
# 
# Reads a file $HOME/.ldaploginrc to get an ordered list of domain controllers
# to try, the bind DN, the base DN for search, and asks for the password.
# 
# $HOME/.ldaploginrc is in JSON format, here's an example:
#
# 
# {
#   "basedn": "DC=example,DC=com",
#   "binddn": "CN=danny,CN=Users,DC=example,DC=com",
#   "dclist": [ 
#     "dc1.example.com",
#     "dc2.example.com",
#     "dc3.example.com" ]
# }
#
use strict;
use warnings;
use Net::LDAP;
use Getopt::Long;
use File::Basename qw/basename/;
use JSON;

sub usage {
    my $PROGNAME = basename($0);
    print STDERR "Usage: $PROGNAME [options] query [query ...]";
    print STDERR qq{Options:
        --dc hostname ................ Domain Controller hostname
        --basedn baseDN .............. Base DN for search for objectclass=group or objectclass=user
        --binddn bindDN .............. Bind DN (you will be prompted for the password
        --groups ..................... filter on objects that are groups
        --users ...................... filter on objects that are users
    };
    exit 1;
}

my @groups = ();
my @users = ();

GetOptions("dc=s@" => \my $dclist,
            "basedn=s" => \my $basedn,
            "binddn=s" => \my $binddn,
            "groups" => \my $groups,
            "users" => \my $users) || usage;

my $ldap;

my $defaults = {};
my $json = JSON->new();
my $rcfilename = "$ENV{HOME}/.ldaploginrc";
if (-f $rcfilename) {
    open(RCFILE, '<', "$rcfilename") or die "$rcfilename: $@";
    my @lines;
    while (<RCFILE>) {
        chomp;
        push @lines, $_;
    }
    my $contents = join('', @lines);
    close RCFILE;
    eval {
        $defaults = $json->decode($contents);
    };
    die("$rcfilename: $@") if $@;
}

$basedn || ($basedn = $defaults->{'basedn'});
$binddn || ($binddn = $defaults->{'binddn'});
($dclist && int(@$dclist)>0) || ($dclist = $defaults->{'dclist'});

unless ($basedn && $binddn && $dclist && int(@$dclist)>0) {
    print STDERR "You must specify LDAP parameters through $rcfilename or command-line options.\n";
    exit 1;
}

if ($users && $groups) {
    print STDERR "You may only filter on one of users or groups\n";
    exit 1;
}

my $dc;
foreach my $adc (@$dclist) {
    $ldap = Net::LDAP->new($adc, port => 389);
    if ($ldap) {
        $dc = $adc;
        last;
    }
}

unless ($ldap) {
    print STDERR "error: unable to connect to domain controller\n";
    exit 1;
}
print "Connected to $dc\n\n";

print "Password: ";
system('/bin/stty -echo');
my $password = <STDIN>;
system('/bin/stty echo');
print "\n";
chomp $password;

my $mesg = $ldap->bind($binddn, password => $password);
if ($mesg->is_error()) {
    print STDERR "error: login as $binddn: ".$mesg->error_desc()."\n";
    exit 1;
}

unless (int(@ARGV)>0) {
    $ldap->unbind();
    print STDERR "No query specified: nothing to do\n";
    exit 1;
}

foreach my $query (@ARGV) {
    if ($users) {
        $query = "(&(objectclass=user)(sAMAccountName=$query))";
    } elsif ($groups) {
        $query = "(&(objectclass=group)(sAMAccountName=$query))";
    }
    $mesg = $ldap->search(base => $basedn, filter => $query);
    if ($mesg->code) {
        print STDERR "search $query: ".$mesg->code.": ".$mesg->error."\n";
    }
    print "Results for $query:\n\n";
    foreach my $entry ($mesg->entries) {
        $entry->dump;
    }
}

$ldap->unbind;
exit 0;



