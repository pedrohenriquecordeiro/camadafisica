#!/usr/bin/perl

use 5.010;
use strict;
use threads;
use warnings;
use IO::Socket::INET;
use Time::HiRes ('sleep');

# eh necessario instalar esse modulo a partir do cpan
use Net::Address::IP::Local;

# declara variaveis
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

print "Esperando por um cliente.\n";

# aceita ou nao a conexao com um cliente	
$clientsocket = $socket->accept();

# mostra dados da conexao
print   "Conectado com : ", $clientsocket->peerhost();     
print   "\nNa porta : ", $clientsocket->peerport(), "\n\n";

# espera uma mensagem
my $mensagem_do_cliente = <$clientsocket>;

# se a mensagem for valida
if( defined $mensagem_do_cliente){
	
	# responte o cliente
	print $clientsocket "1\n";
	
	# mostra a mensagem recebida
	print "Mensagem do cliente : $mensagem_do_cliente \n";
		
}else{
	die "Erro no receber o quadro";
}

#fecha a conexao
$socket->close();