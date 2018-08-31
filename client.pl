#!/usr/bin/perl
#
# The traditional first program.
 
# Strict and warnings are recommended.
use strict;
use warnings;

if(@ARGV != 2){
	print 'Uso: perl ' . $0 . ' [ip_servidor] [ip_cliente]';
}
my $ip_servidor = $ARGV[0] + 0;
my $ip_cliente = $ARGV[1] + 0;
my $port_number = 10001;

print 'ip_servidor: ' . $ip_servidor . " \n";
print 'ip_cliente: ' . $ip_cliente . " \n";
print 'port_number: ' . $port_number . " \n";
#como pegar numero da porta de um processo no windows
#https://blogs.technet.microsoft.com/askperf/2008/08/26/what-port-is-that-service-using/
