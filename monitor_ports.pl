#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use Net::IP;

# ZADANIE:
# Build a program (in any language) for repetitive network scans displaying differences
# between subsequent scans.
#
# netstat –listen
# lsof -i
# scan can be executed either using external tools or using dedicated libraries of selected
# programming language
# - target of the scan must be parametrized as CLI argument
#- target can be single IP address as well as network range
# Example of expected result:
#
# ----- Initial scan:
# $ ./scanner 10.1.1.1
# *Target - 10.1.1.1: Full scan results:*
# Host: 10.1.1.1 Ports: 22/open/tcp////
# Host: 10.1.1.1 Ports: 25/open/tcp////
#
# ----- Repetitive scan with no changes on target host:
# $ ./scanner 10.1.1.1
# *Target - 10.1.1.1: No new records found in the last scan.*
#
#------ Repetitive scan with changes on target host:
# $ ./scanner 10.1.1.1
# *Target - 10.1.1.1: Full scan results:*
# Host:

# objekt ktory vznikne z argumenta prikazoveho riadku. JE to ip napr. 1.2.3.4.
# alebo ip range 1.2.3.4-2.3.4.5

#--- VARIABLES ---- 
my $host_ip;
my $netstat_old = '';
my $netstat_new = '';
my @line;
my $ip1;
my $ip2;
my $prnt;

# cmd line argument reading
if (defined $ARGV[0]) {
    $host_ip = Net::IP->new($ARGV[0]) or die Net::IP::Error();
}
else {
    print "IP/IP range argument is missing!\n";
    exit 0;
}


# nekonecny cyklus prerusi sa pomocou CTRL+C
while (1) {

    # Vystup z netstat prikazu sa ulozi do pola @netstat. 
    # Kazdy riadok vypisu z netstat je jeden prvok pola @netstat.
    my @netstat = `netstat -tulpan| awk \'{print \$1,\$4,\$5,\$6,\$7}\'`;

    # pre kazdy prvok z pola (teda riadok z netstatu)
    for my $new (@netstat) {

        # ignoruj prve dva riadky (hlavicku) z netstatu. 
        next if ($new =~ /Active/);
        next if ($new =~ /Proto/);

        # riadok rozdel podla medzier do pomocneho pola
        @line = split '\s+', $new;
 
        # ziskam IP addr, oddelim port od IP
        $ip1 = (split ':', $line[1])[0];
        next if $ip1 eq ''; # ignoruj prazdne IP. Vzniknu z IPv6 adresy => tcp6 :::22 :::* LISTEN

        $ip2 = (split ':', $line[2])[0];
        next if $ip2 eq '';
       
        # z IP ciek spravim objekty, aby som vedel pouzit funkciu overlaps
        my $local_addr   = Net::IP->new( $ip1 ) or die Net::IP::Error();
        my $foreign_addr = Net::IP->new( $ip2 ) or die Net::IP::Error();

        # Kontrola ci vystup z netstatu obsahuje IP z argumentu prikazoveho riadku
        # ak ani local_addr ani foreign_addr nie je v range ignoruj 
        next if (! $host_ip->overlaps($local_addr) ) and (! $host_ip->overlaps($foreign_addr) );
        
        # Ak som sa dostal do tohto bodu viem ze riadok obsahuje monitorovanu IP.
        # Postupne riadky pospajam do jedneho velkeho stringu, aby sa dobre porovnavali
        # dva po sebe iduce netstaty
        $netstat_new .= $new;
    }

    # porovnam 2 po sebe iduce vystupy z netstatu
    if ( $netstat_old eq $netstat_new ) {
        print ".... NO change for $ARGV[0] ....\n" if ($prnt eq 'true');
        $prnt = 'false';    
    }
    else {
        print "---- NEW change for $ARGV[0] ----\n";
        print $netstat_new;
        $prnt = 'true';
    }

    $netstat_old = $netstat_new; # archyvuj aktualny netstat
    $netstat_new = ''; # vymaz netstat string
    sleep 3;           # pockaj 3 sekundy
}
