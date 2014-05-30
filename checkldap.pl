#!/usr/bin/env perl
#
use strict;
use warnings;
use Net::LDAP;

my $ldap = Net::LDAP->new( 'nlmaddc01.nlm.nih.gov') or die "$@";
my $mesg;

# Can we do an anymous bind?
$mesg = $ldap->bind ("CN=Users,DC=nlm,DC=nih,DC=gov", 
$mesg->code && die $mesg->error;

# Can we search for me?
$mesg = $ldap->search( base => "cn=Users", filter => "sAMAccountName=davisda4" );
$mesg->code && die $mesg->error;


foreach my $entry ($mesg->entries) { $entry->dump; }

$mesg = $ldap->unbind;
