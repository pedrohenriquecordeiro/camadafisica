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
  or die "Não foi possível abrir o arquivo '$filename' $!";
 
#salva o conteudo da primeira linha em uma variavel
my $data = <$fh>;

#temos que filtrar o endereço ip que esta no arquivo
#cria o socket
$socket = new IO::Socket::INET (
  PeerHost => '192.168.1.6',
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";

print "Conectado com o servidor.\n";

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
	
	#envia os dados
	print $socket "$data\n";
	
	#resposta do servidor
	my $mensagem_do_servidor = <$socket>;
	
	#avalia a mensagem
	if(defined $mensagem_do_servidor){
	
		print "Mensagem do servidor $mensagem_do_servidor";
		
	}
	
	threads->exit();
}