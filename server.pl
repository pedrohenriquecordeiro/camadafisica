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

	#abre o arquivo
	my $filename = "message_slave.txt";
	open(my $fs, '<:encoding(UTF-8)', $filename)
		or die "Nao foi possivel abrir o arquivo message_slave.txt '$filename' $!";
	
	#salva o conteudo da primeira linha em uma variavel
	my $data_message_slave = <$fs>;
	
	#fecha o arquivo
	close $fs;

	#envia o conteudo
	my $thread_1 = threads->create(\&enviando_mensagem,$clientsocket,$data_message_slave) 
		or die "Erro no envio da imagem";

	$thread_1->join();

	# espera uma mensagem - posicao do mouse
	$mensagem_do_cliente_bin = <$clientsocket>;

	# se a mensagem for valida
	if( defined $mensagem_do_cliente_bin){

		print "defined mouse\n";

		# converte de binario para string
		my $mensagem_do_cliente = sprintf pack("b*",$mensagem_do_cliente_bin);

		# extrai da mensagem o conteudo efetivo
		my $data = substr $mensagem_do_cliente , 117;
		
		#salva conteudo em um arquivo externo
		my $arquivo = 'message_master.txt';
		open(my $fh, '>', $arquivo) or die "Não foi possível abrir o arquivo '$arquivo' $!";
		print $fh $data;
		close $fh;

	}
}

print "stoped!\n";


#fecha a conexao
$socket->close();
#FIM DO SCRIPT


###################################################### SUBROUTINA #####################################################
sub enviando_mensagem{
	
	# pegar parametros passados
	my @s = @_ ;
	my $sk = $s[0];
	my $data = $s[1];
	
	#
	# nesse ponto simulamos uma colisao
	# a partir da geracao de um numero aleatorio de 0 a 9
	#
	# se maior ou igual a 5 nao ocorre colisao
	# se menor ou igual a 4 ocorre colisao
	#
	
	my ($colisao,$time);
	
	#gera numero aleatoria de 0 a 9
	$colisao = int(rand(10));
	
	while($colisao le 4){
	
		#ocorreu colisao
		#gera um tempo em milisegundos aleatorio
		$time = int(rand(10)/10);
		
		# espera o tempo 
		sleep($time);
		
		#calcula se vai ocorrer outra colisao
		$colisao = int(rand(10));
	}
	
	#envia os dados
	print $sk "$data\n";

	threads->exit();
}
