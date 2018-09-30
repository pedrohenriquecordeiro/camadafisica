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


my($mensagem_do_cliente,$mensagem_do_cliente_bin);

print "running ...\n";

#################################### PROCESSO QUE IRA ENTRAR EM LOOP #######################################3
while(1){

	# espera uma mensagem
	$mensagem_do_cliente_bin = <$clientsocket>;

	# se a mensagem for valida
	# obs : aqui podemos controlar o continuamento do script
	if( defined $mensagem_do_cliente_bin){

		# converte de binario para string
		my $mensagem_do_cliente = sprintf pack("b*",$mensagem_do_cliente_bin);

		# extrai da mensagem o conteudo efetivo
		my $data = substr $mensagem_do_cliente , 117;
		
		#salva conteudo em um arquivo externo
		my $arquivo = 'data_from_cliente.txt';
		open(my $fh, '>', $arquivo) or die "Não foi possível abrir o arquivo '$arquivo' $!";
		print $fh $data;
		close $fh;
			
	}else{
		last;
	}
}

print "stoped!\n";


#fecha a conexao
$socket->close();
#FIM DO SCRIPT
