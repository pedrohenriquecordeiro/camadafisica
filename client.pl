#!/usr/bin/perl

# se o parametro for <1> o cliente irá apenas enviar mensagens
# se o parametro for <0> o cliente irá apenas receber mensagens

use 5.010;
use strict;
use warnings;
use IO::Socket::INET;
use threads;
use Time::HiRes ('sleep');


#declara variaveis
my ($socket,$serverdata,$clientdata);

#cria o socket
$socket = new IO::Socket::INET (
  PeerHost => '192.168.1.6',
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";

print "Conectado com o servidor.\n";

my $modo_de_operacao = <$socket>;

if( not defined $modo_de_operacao){
	die "Erro";
}

#define comportamento o script conforme o parametro de entrada shift
if($modo_de_operacao eq 1){

	# espera uma mensagem vindo do cliente
	my $thread_1 = threads->create(\&esperando_mensagem,$socket) 
		or die "Erro na criacao da thread de espera";
		
}elsif($modo_de_operacao eq 0){

	# tem a possibilidade de envio de mensagens
	my $thread_1 = threads->create(\&enviando_mensagem,$socket) 
		or die "Erro na criacao da thread de espera";
	
}else{
	die "Erro";
}

# nao permite o encerramento do programa main enquanto a thread não finalizar
$thread_1 ->join() or die "Erro na criacao de dependencia com o programa principal\n";


#fecha a conexao
$socket->close();


####################### SUBROUTINAS ############################
sub esperando_mensagem{

	#pega parametros passados
	my @s = @_ ;
	my $socket  = $s[0];
	
	while(1){
		
		# espera uma mensagem
		my $mensagem_do_servidor = <$socket>;
	
		# se a mensagem for valida
		if( defined $mensagem_do_cliente){
			
			if($mensagem_do_cliente eq "000x\n"){
			
				# se o servidor enviar 000x a conexao eh fechada
				print $clientsocket "fechando conexao\n";
				last;
				
			}else{
			
				#resposta para o servidor
				print $socket "recebido\n";
				
				# mostra a mensagem recebida
				print "Mensagem do cliente : $mensagem_do_cliente \n";
				sleep(0.1);
				
			}
		}
	}
	threads->exit();
	
}


sub enviando_mensagem{
	
	# pegar parametros passados
	my @s = @_ ;
	my $socket = $s[0];
	
	while(1){
		
		print "Digite uma mensagem para o servidor ...";
		my $msg_para_servidor = <STDIN>;
		chomp $msg_para_servidor ;
		
		#envia a mensagem
		print $socket "$msg_para_servidor \n";
		
		#resposta do servidor
		my $mensagem_do_servidor = <$socket>;
		
		#avalia a mensagem
		if(defined $mensagem_do_servidor){
		
			print "Mensagem do servidor $mensagem_do_servidor";
			
			if($msg_para_servidor  eq "000x\n"){
			
				# se o servidor enviar 000x a conexao eh fechada
				last;
				
			}
		}
	}
	threads->exit();
}
