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

#temos que filtrar o endereco ip que esta no arquivo
#cria o socket
$socket = new IO::Socket::INET (
  PeerHost => '192.168.1.6',
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";

#print "Conectado com o servidor.\n";

#envia o quadro
my $thread_1 = threads->create(\&enviando_mensagem,$socket) 
	or die "Erro na criacao da thread de espera";

# nao permite o encerramento do programa main enquanto a thread não finalizar
$thread_1 ->join() or die "Erro na criacao de dependencia com o programa principal\n";

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
	
	my $colisao;
	
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
