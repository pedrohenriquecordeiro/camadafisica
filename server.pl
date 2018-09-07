#!/usr/bin/perl

# se o parametro for <1> o servidor irá apenas enviar mensagens
# se o parametro for <0> o servidor irá apenas receber mensagens

use 5.010;
use strict;
use warnings;
use IO::Socket::INET;
use threads;
use Time::HiRes ('sleep');

# eh necessario instalar esse modulo a partir do cpan
use Net::Address::IP::Local;

# declara variaveis
my ($socket,$clientsocket,$serverdata,$clientdata);

#declara variaveis
my ($socket,$serverdata,$clientdata);

#abre o arquivo
my $filename = 'data.txt';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Não foi possível abrir o arquivo '$filename' $!";
 
#salva o conteudo da primeiro linha em uma variavel
my $data = <$fh>;

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

#envia uma mensagem ao cliente informando qual modo de operacao
#a partir disso, o cliente vai se adaptar ao modo de operacao do servidor
#
#por exemplo, se o servidor for apenas enviar mensagens, 
#o cliente apenas irareceber
#
print $clientsocket shift;

# mostra dados da conexao
print   "Conectado com : ", $clientsocket->peerhost();     
print   "\nNa porta : ", $clientsocket->peerport(), "\n\n";

#define comportamento o script conforme o parametro de entrada shift
if(shift eq 0){

	# fica a espera de mensagens
	my $thread_1 = threads->create(\&esperando_mensagem,$clientsocket) 
		or die "Erro na criacao da thread de espera";
		
}elsif(shift eq 1){
	
	# tem a possibilidade de envio de mensagens
	my $thread_1 = threads->create(\&enviando_mensagem,$clientsocket) 
		or die "Erro na criacao da thread de espera";
	
}else{
	die "Parametro invalido";
}

# nao permite o encerramento do programa main enquanto a thread não finalizar
$thread_1 ->join() or die "Erro na criacao de dependencia com o programa principal\n";

#fecha a conexao
$socket->close();  





####################### SUBROUTINAS ############################
sub esperando_mensagem{

	# pega parametros passados
	my @cs = @_ ;
	my $clientsocket  = $cs[0];
	
	while(1){
		
		# espera uma mensagem
		my $mensagem_do_cliente = <$clientsocket>;
		
		# se a mensagem for valida
		if( defined $mensagem_do_cliente){
		
			if($mensagem_do_cliente eq "000x\n"){
			
				# se o cliente enviar 000x a conexao eh fechada
				print $clientsocket "fechando conexao\n";
				last;
				
			}else{
			
				# resposte o cliente
				print $clientsocket "recebido\n";
				
				# mostra a mensagem recebida
				print "Mensagem do cliente : $mensagem_do_cliente \n";
				sleep(0.1);
				
			}
			
		}
	}
	threads->exit();
	
}


sub enviando_mensagem{
	
	# pega parametros passados
	my @s = @_ ;
	my $clientsocket = $s[0];
	
	while(1){
		
		
		#envia a mensagem
		print $clientsocket "$data\n";
		
		#resposta do servidor
		my $mensagem_feedback = <$clientsocket>;
		
		#avalia a mensagem
		if(defined $mensagem_feedback){
		
			print "Mensagem do servidor $mensagem_feedback";
			
			if($mensagem_feedback  eq "000x\n"){
			
				# se o cliente enviar 000x a conexao eh fechada
				last;
				
			}
		}
	}
	threads->exit();
}


