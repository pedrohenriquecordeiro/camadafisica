#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;


# eh necessario instalar esse modulo a partir do cpan
use Net::Address::IP::Local;

my ($socket,$clientsocket,$serverdata,$clientdata);

#descobre o ip do maquina servidor
my $address = eval{Net::Address::IP::Local->public_ipv4};

# cria o socket, com possibilidade de apenas um cliente conectado
# Reuse eh 1 pois o socket pode ser reutilizavel
$socket = new IO::Socket::INET (

    LocalHost => $address,
    LocalPort => '7878'  ,
    Proto     => 'tcp'   ,
    Listen    => 1       ,
    Reuse     => 1              

)or die "Erro: $! \n";


print "Waiting for the Client.\n";

# aceita ou nao a conexao com um cliente
$clientsocket = $socket->accept();

# mostra dados da conexao
print   "Connected from : ", $clientsocket->peerhost();     
print   "\nPort : ", $clientsocket->peerport(), "\n";

# envia uma mensagem para o cliente
$serverdata = "This is the Server speaking :)\n";
print $clientsocket "$serverdata \n";

# fica a espera de uma mensagem vinda cliente
$clientdata = <$clientsocket>;
print "Message received from Client : $clientdata\n";

#fecha a conexao
$socket->close();  

