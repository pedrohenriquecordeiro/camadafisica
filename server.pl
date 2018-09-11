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

#descobre o ip da maquina servidor
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

# aceita ou nao a conexao com um cliente	
$clientsocket = $socket->accept() or die "Erro no inicio de conexao com o cliente";

# espera uma mensagem
my $mensagem_do_cliente = <$clientsocket>;

# se a mensagem for valida
if( defined $mensagem_do_cliente){
	
	# responte o cliente com um ok
	print $clientsocket "1\n";
	
	#salva pdu em um arquivo externo
	my $arquivo = 'data_from_cliente.txt';
	open(my $fh, '>', $arquivo) or die "Não foi possível abrir o arquivo '$arquivo' $!";
	print $fh $mensagem_do_cliente;
	close $fh;
		
}else{

	# responte o cliente com um fail
	print $clientsocket "0\n";
	die "Erro::quadro nao recebido corretamente";
	
}

#fecha a conexao
$socket->close();
