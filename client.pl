#!/usr/bin/perl

use 5.010;
use strict;
use threads;
use warnings;
use IO::Socket::INET;
use Time::HiRes ('sleep');

#declara variaveis
my ($socket,$serverdata,$clientdata);

#abre o arquivo
my $filename = 'data.txt';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Nao foi possivel abrir o arquivo '$filename' $!";
 
#salva o conteudo da primeira linha em uma variavel
my $data = <$fh>;


my $serveraddr='127.0.0.1';
my $clientaddr=eval{Net::Address::IP::Local->public_ipv4};

#temos que filtrar o endereco ip que esta no arquivo
#cria o socket
$socket = new IO::Socket::INET (
  PeerHost => '127.0.0.1',
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";

#print "Conectado com o servidor.\n";


my $preambulo = '10101010101010101010101010101010101010101010101010101010';
my $start_frame = '10101011';
my ($smac) = `arp -a $serveraddr` =~ /at\s+(\S+)\s+/;
my ($cmac) = `arp -a $clientaddr` =~ /at\s+(\S+)\s+/;
my $tipo = '0000000011111111';

$data= $preambulo.$start_frame.$smac.$cmac.$tipo.$data;

#envia o quadro
my $thread_1 = threads->create(\&enviando_mensagem,$socket) 
	or die "Erro na criacao da thread de espera";

$thread_1 ->join() or die "Fechado com sucesso!\n";

#fecha a conexao
$socket->close();



####################### SUBROUTINAS ############################
sub enviando_mensagem{
	
	# pegar parametros passados
	my @s = @_ ;
	my $socket = $s[0];
	
	#
	# nesse ponto simulamos uma colisao
	# a partir da geracao de um numero aleatorio de 0 a 9
	#
	# se maior ou igual a 5 nao ocorre colisao
	# se menor ou igual a 4 ocorre colisao
	#
	
	my ($colisao,$time);
	
	while(1){
		
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
		print $socket "$data\n";
		
		#resposta do servidor
		my $mensagem_do_servidor = <$socket>;
		
		#avalia a mensagem
		if(defined $mensagem_do_servidor){
		
			# se servidor respondeu -> sai do loop e finaliza
			last;
			
		}
	}
	
	threads->exit();
}
