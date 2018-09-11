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
my $data_file = <$fh>;

# conteudo de ate 1000 bytes
# converte o conteudo para binario
my $data_file_bin = sprintf unpack("b*",$data_file );

# ESSA LINHA DEVE SER ALTERADA POSTERIORMENTE
# POIS A CAMADA SUPERIOR ( CAMADA DE REDE ) QUE NOS DIRA
# QUAL O IP DO DESTINO (SERVIDOR)
my $serveraddr = '192.168.1.6';
my $clientaddr = eval{Net::Address::IP::Local->public_ipv4};

#cria o socket
$socket = new IO::Socket::INET (
  PeerHost => $serveraddr,
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";


# preambulo da pdu = 7 bytes
my $preambulo = '10101010101010101010101010101010101010101010101010101010';
my $preambulo_bin = sprintf unpack("b*",$preambulo);

# início do delimitador de Quadro = 1 byte
my $start_frame = '10101011';
my $start_frame_bin = sprintf unpack("b*",$start_frame);

# mac do servidor =  6 bytes
my $mac = `arp -a $serveraddr`;
if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
	$mac = $1;
}
my $mac_bin = sprintf unpack("b*",$mac);

# mac do destino = 6 bytes
my $cmac = `arp -a $clientaddr` =~ /at\s+(\S+)\s+/;
if($cmac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
	$cmac = $1;
}
my $cmac_bin = sprintf unpack("b*",$cmac );

# dado a ser enviado 1000 bytes

# tamanho de todo o quadro => 2 bytes
# total => 1022 bytes -> 8176 bits
my $length = '0001111111110000';
my $length_bin = sprintf unpack("b*",$length );

# concatena o os campos da pdu
my $data_bin = $preambulo_bin.$start_frame_bin.$mac_bin.$cmac_bin.$length_bin.$data_file_bin;

print "\n" . localtime(time) . "\npdu :: <" . $data_bin . ">\n";

#envia o quadro
my $thread_1 = threads->create(\&enviando_mensagem,$socket) 
	or die "Erro na criacao da thread de espera";

$thread_1->join();

#fecha a conexao
$socket->close();



####################### SUBROUTINAS ############################
sub enviando_mensagem{
	
	# pegar parametros passados
	my @s = @_ ;
	my $sk = $s[0];
	
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
	print $sk "$data_bin\n";
	
	#resposta do servidor
	my $mensagem_do_servidor = <$sk>;
	
	#avalia a mensagem
	if(not defined $mensagem_do_servidor){
	
		# se servidor respondeu -> sai do loop e finaliza
		die "erro no fadeback do servidor";
		
	}
	
	threads->exit();
}
