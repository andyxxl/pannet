#!/usr/bin/perl

# nacitaj/pouzi (use) moduly strict, warnings, diagnostics
# strict   - prisnejsia kontrola syntaxe
# warnings - vypisovanie warningov
# diagnostics - pri chybach podrobnejsi popis chyb
use strict;
use warnings;
use diagnostics;
use Net::IP;
use 5.016;

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
my @lines;
my %file_hash;
my $fh;
my @output;
my $scr_output;


# command line argument reading, $ARGV[0] je prvy argument
if (defined $ARGV[0]) {
    # vytvorim objekt $host_ip, ktory moze obsahovat range alebo IP addresu
    $host_ip = Net::IP->new($ARGV[0]) or die Net::IP::Error();
}
else {
    print "IP or IP range argument is missing!\n";
    exit 0;
}


# Loop
do {
    # do premennej ip sa ulozi prva adresa ak je to IP range.
    # Ak to nie je range tam len jedna IP adresa
    my $ip = $host_ip->ip();

    # premenna $cmd obsahuje shallovsky prikaz ako
    # napr.: pre danu IP :  netstat -tulpan | awk '$4 ~ /127.0.0.1/ {print $4,$6,$1}' | sort -u
    my $cmd = q(netstat -tulpan | awk '$4 ~ /).$ip.q(/ {print $4,$6,$1}' | sort -u);

    # do premennej $netstat_resp sa nacita obsah spusteneho shalloveho prikazu
    # je to jeden dlhy string, ktory obsahuje viacero znakov konca riadku
    # teda viacriakovy string podla toho co vypise netstat
    my $netstat_resp = `$cmd`;

    # chomp odreze znak konca riadku uplne na konci (ostatne ponecha).
    chomp($netstat_resp);

    # $netstat_resp rozdeli do pola podla koncov riadkov
    my @ip_lines = split /\R+/, $netstat_resp;

    # do pola @output prida dalsie pole @ip_lines, ale iba ak existuje @ip_lines
    push @output, @ip_lines if (@ip_lines);

} while (++$host_ip); # ak je range prejde na dalsiu IP

# ak existuje (-f) subor scan_history
if (-f 'scan_history') {
    # otvor subor na citanie
    open($fh, '<', 'scan_history' ) or die "Cannot open scan history $!";
    # prejdi kazdy riadok subora
    while(<$fh>) {
        # ak nude koniec riadku zmaz ho
        chomp($_);
        # do hashu/dictionary si uloz kluc (ktory je jeden riadok s netstatu) a uloz mu hodnotu 1.
        # hodnota jedna nie je podstatna
        $file_hash{"$_"} = 1;
    }
    close($fh);  # zavri subor
}

# otvor subor scan_hostory na pisanie na koniec subora (append)
open($fh, '>>', 'scan_history' ) or die "Cannot open scan history $!";
# pre kazdu polozku $item zo vstkych riadkov z outputu netstat
for my $item (@output) {
   # ak uz riadok existuje v subore nerob nic ak neexistuje vypis na obrazovku a
   # zapis si ho do suboru scan_history
   if (! exists($file_hash{"$item"})) {
       $scr_output .= "Host: $item\n";
       say $fh $item;
   }
}
close($fh);

if ($scr_output) {
    say  $scr_output;
}
else {
   say "No change!";
}


