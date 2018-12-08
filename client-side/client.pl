#!/usr/bin/perl

##includes
use 5.010;
use strict;
use threads;
use warnings;
use IO::Socket::INET;
use Time::HiRes('sleep');
use bytes;
use Try::Tiny;
use Net::Address::IP::Local; 

require '../modules_perl/modules.pl';
our ( $atribute_separator , $control_separator );

# le conteudo do arquivo com o primeiro ACK
my $data_file;
my @array_data_file;
do{
	# espera a camada de transporte escrever o primeiro ack no arquvivo
	$data_file = read_file('transporte+fisica.txt');
	@array_data_file = split( $control_separator , $data_file );
	print @array_data_file;
}while(($array_data_file[1] eq 'TRANSPORT_DIDNT|PHYSICAL_DONE') 
			|| ($array_data_file[1] eq 'TRANSPORT_DIDNT|PHYSICAL_DIDNT'));

my @array_message_to_send = split($atribute_separator,$array_data_file[0]);
# pega a porta de destino
my $server_port = $array_message_to_send[1];
# ip -> ESSA DADO DEVE VIR DA CAMADA TCP
my $server_ip = '172.16.252.75';

# enviar o primeiro ACK
my $client_socket = connect_client($server_port,$server_ip);
my $thread = threads->create(\&send_message,$client_socket,$array_data_file[0]) or die "Erro no envio"; 
$thread->join();

# espera o segundo ACK do servidor
my $receive_bin = <$client_socket>;
my $receive = sprintf unpack("b*",$receive_bin); 
$receive = join( "=", $receive , 'TRANSPORT_DIDNT|PHYSICAL_DONE');
print 'Segundo ack recebido :>' . $receive;
# escreve o segundo ack no arquivo
write_file('transporte+fisica.txt',$receive);

my $shakinghands=1;

while ($shakinghands) {
	$data_file = read_file('transporte+fisica.txt');
	if (defined $data_file){
		@array_data_file = split( $control_separator , $data_file );
		if ($array_data_file[1] ne 'TRANSPORT_DIDNT|PHYSICAL_DONE'){
			$shakinghands=0;
		}
	}
}


# enviar o terceiro ACK
$thread = threads->create(\&send_message,$client_socket,$array_data_file[0]) or die "Erro no envio"; 
$thread->join();
















































# # envia para o servidor
# my $thread = threads->create(\&send_message,$socket,$ack1) or die "Erro no envio"; #envia o quadro
# $thread->join();

# # espera a resposta do servido 
# my $receive = <$socket>;


#!/usr/bin/perl

# ##includes
# use 5.010;
# use strict;
# use threads;
# use warnings;
# use IO::Socket::INET;
# use Time::HiRes('sleep');
# use bytes;
# use Try::Tiny;
# use Net::Address::IP::Local; 

# ######### declara variaveis
# my $socket;
# my $serverdata;
# my $clientdata;

# my $first_file = "../message_master.txt";
# my $file_master = "../message_master.txt";
# my $file_slave = "../message_slave.txt";

# my $separator = chr(30);
# my $tryopenfile;
# my $f_receive;
# my $freceive_bin;
# my $freceive;
# my $freceive_data;
# my $data_fsend;
# my $f_send;

# print "[DEBUG:CAMADA FISICA]Iniciando\n";
# ######### le mensagem da camada de cima (IP do servidor)
# $tryopenfile = 1;
# while($tryopenfile){
# 	open($f_send, '<:encoding(UTF-8)', $first_file) or die "[ERRO]Nao foi possivel abrir o arquivo '$first_file' $!";
# 	$data_fsend = <$f_send>;
# 	close $f_send;
# 	if(defined $data_fsend){
# 		$tryopenfile=0;
# 		print "[DEBUG:CAMADA FISICA]Arquivo a com IP do servidor lido da camada de aplicação\n";
# 		unlink $first_file; #deleta o arquivo
# 	}
# }

# my $offset = index($data_fsend,$separator) + length($separator);
# my $fsend_serverinfo = substr($data_fsend,0,$offset-length($separator));
# my $fsend_data = substr($data_fsend,$offset);
# my $fsend_data_bin = sprintf unpack("b*",$fsend_data);# converte a mensagem para binario

# my @serverfulladdr = split($atribute_separator, $fsend_serverinfo);
# #my $serveraddr = $serverfulladdr[0];
# my $serveraddr ="127.0.0.1" ;
# my $serverport = "7878";

# ########## cria socket
# print "[DEBUG:CAMADA FISICA]Connecting on server [ip:".$serveraddr." port:".$serverport."]...\n";
# $socket = new IO::Socket::INET (
# 	PeerHost => $serveraddr,
# 	PeerPort => $serverport,
# 	Proto    => 'tcp'        
# ) or die "[Erro]$!\n";
# print "[DEBUG:CAMADA FISICA]Connected on server [ip:".$serveraddr." port:".$serverport."]...\n";

# ##########  cria PDU
# # preambulo da pdu = 7 bytes
# my $preambulo = '10101010101010101010101010101010101010101010101010101010';
# my $preambulo_bin = sprintf unpack("b*",$preambulo);

# # início do delimitador de Quadro = 1 byte
# my $start_frame = '10101011';
# my $start_frame_bin = sprintf unpack("b*",$start_frame);

# # mac do destino =  6 bytes
# my $mac = `arp -a $serveraddr`;
# if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
# 	$mac = $1;
# }
# my $mac_bin = sprintf unpack("b*",$mac);

# # mac do remetente = 6 bytes
# my $so =  "$^O\n";
# my $cmac;
# if(index($so, "linux") != -1) {
#     $cmac = substr `cat /sys/class/net/*/address`,0,17;
# }elsif(index($so,"Win") != -1){
#     $cmac = `getmac`;
# 	if($cmac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
# 		$cmac = $1;
# 	}
# }else{
# 	$cmac = "00:00:00:00:00:00";
# }
# my $cmac_bin = sprintf unpack("b*",$cmac );

# # tamanho do segmento
# my $length = '00000000‭01000010';
# my $length_bin = sprintf unpack("b*",$length );

# my $pre_pdu = $preambulo_bin.$start_frame_bin.$mac_bin.$cmac_bin.$length_bin;


# ######### loop
# print "[DEBUG:CAMADA FISICA]Running...\n";
# while(1){
# 	# TODO corrigir aqui
# 	$fsend_data_bin = $pre_pdu.$fsend_data_bin; # concatena o os campos da pdu
# 	my $thread_1 = threads->create(\&send_message,$socket,$fsend_data_bin) or die "Erro no envio"; #envia o quadro
# 	$thread_1->join();
# 	print "[DEBUG:CAMADA FISICA]Posição do mouse enviada para camada fisica\n";

# 	######### espera uma mensagem do controlled (tela)
# 	$freceive_bin = <$socket>;
# 	if(defined $freceive_bin){
# 		print "[DEBUG:CAMADA FISICA]Imagem recebida da camada fisica\n";
# 		$freceive = sprintf pack("b*",$freceive_bin); # converte para string
# 		$freceive_data = substr $freceive , 117; # extrai da mensagem o conteudo efetivo
# 		open($f_receive, '>', $file_slave) or die "Não foi possível abrir o arquivo '$file_slave' $!";
# 		print $f_receive $freceive_data;
# 		close $f_receive;
# 		print "[DEBUG:CAMADA FISICA]Arquivo com a tela salvo para a camada de aplicação\n";
# 	}

# 	######### le mensagem da camada superior (posicao do mouse)
# 	$tryopenfile=1;
# 	while($tryopenfile){
# 		try {
# 			open($f_send, '<:encoding(UTF-8)', $file_master) or die "[ERRO]Nao foi possivel abrir o arquivo '$file_master' $!";
# 			$data_fsend = <$f_send>;
# 			close $f_send;
# 			$tryopenfile=0;
# 			print "[DEBUG:CAMADA FISICA]Arquivo com a posicao do mouse lido da camada de aplicação\n";
# 			unlink $file_master; #deleta o arquivo
# 		} catch {
# 		};
# 	}	
# 	$offset = index($data_fsend,$separator) + length($separator);
# 	$fsend_data = substr($data_fsend,$offset);
# 	$fsend_data_bin = sprintf unpack("b*",$fsend_data); # converte a mensagem para binario
# }
# $socket->close();
# print "Bye!\n";	


# ###### Funcao para enviar mensagem
# sub send_message{
# 	# pegar parametros passados
# 	my @s = @_ ;
# 	my $sk = $s[0];
# 	my $data_file = $s[1];
	
# 	my ($colisao,$time); 
# 	$colisao = int(rand(10)); # colisao se o numero for >= 4
# 	while($colisao le 4){ #ocorreu colisao
# 		$time = int(rand(10)/10);
# 		sleep($time); # espera um tempo aleatorio
# 		$colisao = int(rand(10)); #calcula se vai ocorrer outra colisao
# 	}	
# 	print $sk "$data_file\n"; #envia os dados
# 	threads->exit();
# }















# ######### loop
# print "[DEBUG:CAMADA FISICA]Running...\n";
# while(1){
# 	# TODO corrigir aqui
# 	$fsend_data_bin = $pre_pdu.$fsend_data_bin; # concatena o os campos da pdu
# 	my $thread_1 = threads->create(\&send_message,$socket,$fsend_data_bin) or die "Erro no envio"; #envia o quadro
# 	$thread_1->join();
# 	print "[DEBUG:CAMADA FISICA]Posição do mouse enviada para camada fisica\n";

# 	######### espera uma mensagem do controlled (tela)
# 	$freceive_bin = <$socket>;
# 	if(defined $freceive_bin){
# 		print "[DEBUG:CAMADA FISICA]Imagem recebida da camada fisica\n";
# 		$freceive = sprintf pack("b*",$freceive_bin); # converte para string
# 		$freceive_data = substr $freceive , 117; # extrai da mensagem o conteudo efetivo
# 		open($f_receive, '>', $file_slave) or die "Não foi possível abrir o arquivo '$file_slave' $!";
# 		print $f_receive $freceive_data;
# 		close $f_receive;
# 		print "[DEBUG:CAMADA FISICA]Arquivo com a tela salvo para a camada de aplicação\n";
# 	}

# 	######### le mensagem da camada superior (posicao do mouse)
# 	$tryopenfile=1;
# 	while($tryopenfile){
# 		try {
# 			open($f_send, '<:encoding(UTF-8)', $file_master) or die "[ERRO]Nao foi possivel abrir o arquivo '$file_master' $!";
# 			$data_fsend = <$f_send>;
# 			close $f_send;
# 			$tryopenfile=0;
# 			print "[DEBUG:CAMADA FISICA]Arquivo com a posicao do mouse lido da camada de aplicação\n";
# 			unlink $file_master; #deleta o arquivo
# 		} catch {
# 		};
# 	}	
# 	$offset = index($data_fsend,$separator) + length($separator);
# 	$fsend_data = substr($data_fsend,$offset);
# 	$fsend_data_bin = sprintf unpack("b*",$fsend_data); # converte a mensagem para binario
# }
# $socket->close();
# print "Bye!\n";	







