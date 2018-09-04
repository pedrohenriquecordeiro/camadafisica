#! /usr/bin/perl -w
use 5.010;
use warnings;
use strict;
use Socket;


# inicializamos os parametros
my $host = shift || '192.168.1.6';
my $port = shift || 7890;
my $proto = getprotobyname('tcp');


# gera endereco da porta no local indicado pelo ip
my $iaddr = inet_aton($host);
my $paddr = sockaddr_in($port, $iaddr);


# cria socket
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";

# tenta a conexao a partir do endereco da porta
connect(SOCKET, $paddr) or die "connect: $!";

my $message;
while($message = <SOCKET>) {
    print "$message";
}

#print SOCKET "Eu sou o cliente bro",

close SOCKET or die "close: $!";