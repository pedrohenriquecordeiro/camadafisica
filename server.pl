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
my $address = '127.0.0.1';#eval{Net::Address::IP::Local->public_ipv4};

# cria o socket, com possibilidade de apenas um cliente conectado
# Reuse eh 1 pois o socket pode ser reutilizavel
$socket = new IO::Socket::INET (

	LocalHost => $address,
	LocalPort => '7878'  ,
	Proto     => 'tcp'   ,
	Listen    => 1       ,
	Reuse     => 1              

)or die "Erro: $! \n";

#print "Esperando por um cliente.\n";

# aceita ou nao a conexao com um cliente	
$clientsocket = $socket->accept();

# mostra dados da conexao
#print   "Conectado com : ", $clientsocket->peerhost();     
#print   "\nNa porta : ", $clientsocket->peerport(), "\n\n";

# espera uma mensagem
my $mensagem_do_cliente = <$clientsocket>;

# se a mensagem for valida
if( defined $mensagem_do_cliente){
	
	# responte o cliente
	print $clientsocket "1\n";
	my $arquivo = 'data_from_c.txt';
	open(my $fh, '>', $arquivo) or die "Não foi possível abrir o arquivo '$arquivo' $!";
	print $fh $mensagem_do_cliente;
	close $fh;
		
}else{

	die "Erro::quadro nao recebido";
	
}

#fecha a conexao
$socket->close();
	

#returno do script
#esse retorno pode ser capturado dentro do arquivo php posteriormente
print $mensagem_do_cliente;