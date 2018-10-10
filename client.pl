#!/usr/bin/perl

use 5.010;
use strict;
use threads;
use warnings;
#use Sys::HostAddr;
use IO::Socket::INET;
use Time::HiRes ('sleep');


# declara variaveis
my ($socket,$serverdata,$clientdata);


# ESSA LINHA DEVE SER ALTERADA POSTERIORMENTE
# POIS A CAMADA SUPERIOR ( CAMADA DE REDE ) QUE NOS DIRA
# QUAL O IP DO DESTINO (SERVIDOR)
my $serveraddr = '192.168.1.4';
# ip do localhost
#my $sysaddr = Sys::HostAddr->new();
#my $clientaddr = $sysaddr->first_ip();;

#cria o socket
$socket = new IO::Socket::INET (
  PeerHost => $serveraddr,
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";


################################################### CRIANDO PDU #######################################################
# preambulo da pdu = 7 bytes
my $preambulo = '10101010101010101010101010101010101010101010101010101010';
my $preambulo_bin = sprintf unpack("b*",$preambulo);

# início do delimitador de Quadro = 1 byte
my $start_frame = '10101011';
my $start_frame_bin = sprintf unpack("b*",$start_frame);

# mac do destino =  6 bytes
my $mac = `arp -a $serveraddr`;
if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
	$mac = $1;
}
my $mac_bin = sprintf unpack("b*",$mac);

# mac do remetente = 6 bytes
my $cmac = `getmac`;
if($cmac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
	$cmac = $1;
}
my $cmac_bin = sprintf unpack("b*",$cmac );

# dado a ser enviado tera 46 bytes
# tamanho do quadro
# 7 + 1 + 6 + 6 + 46 = 66 bytes
my $length = '00000000‭01000010';
my $length_bin = sprintf unpack("b*",$length );

my $pre_pdu = $preambulo_bin.$start_frame_bin.$mac_bin.$cmac_bin.$length_bin;

print "running ...\n";

####################### processo que entrara em loop ######################3
while(1){

	# espera uma mensagem - tela do servidor
	my $mensagem_server = <$socket>;

	if( defined $mensagem_server){

		print "defined - display\n";
		
		#salva conteudo em um arquivo externo
		my $image = 'message_slave.txt';
		open(my $f_image, '>', $image) or die "Não foi possível abrir o arquivo '$image' $!";
		print $f_image $mensagem_server;
		close $f_image;
	}

	#abre um arquivo
	my $file_master = "message_master.txt";
	open(my $fh, '<:encoding(UTF-8)', $file_master)
	  or die "Nao foi possivel abrir o arquivo '$file_master' $!";
	 
	#salva o conteudo da primeira linha em uma variavel
	#minimo de 46 bytes - posicao do mouse
	my $data_file = <$fh>;
	
	#fecha o arquivo
	close $fh;

	print "send data\n";
	
	# converte o conteudo do arquivo para binario 
	my $data_file_bin = sprintf unpack("b*",$data_file);

	# concatena o os campos da pdu
	# corrigir aqui
	my $data_bin = $pre_pdu.$data_file_bin;

	#envia o quadro
	my $thread_1 = threads->create(\&enviando_mensagem,$socket,$data_bin) 
		or die "Erro no envio";

	$thread_1->join();

	

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
