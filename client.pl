#!/usr/bin/perl

######### includes
use 5.010;
use strict;
use threads;
use warnings;
use IO::Socket::INET;
use Time::HiRes ('sleep');
use Try::Tiny;
use Net::Address::IP::Local; # eh necessario instalar esse modulo a partir do cpan

######### declara variaveis
my ($socket,$serverdata,$clientdata);

my $first_file = "message_master.txt";
my $file_master = "message_master.txt";
my $file_slave = "message_slave.txt";

my $separator = chr(30);
my $tryopenfile;
my $f_receive;
my $freceive_bin;
my $freceive;
my $freceive_data;
my $data_fsend;
my $f_send;

######### le mensagem da camada de cima (IP do servidor)
$tryopenfile = 1;
while($tryopenfile){
	try {
		open($f_send, '<:encoding(UTF-8)', $file_master) or die "Nao foi possivel abrir o arquivo '$file_master' $!";
		$data_fsend = <$f_send>;
		close $f_send;
		$tryopenfile=0;
		print "[DEBUG] Arquivo a com posicao do mouse lido da camada de aplicação\n";
		unlink $file_master; #deleta o arquivo
	} catch {
	};
}

my $offset = index($data_fsend,$separator) + length($separator);
my $fsend_serverinfo = substr($data_fsend,0,$offset-length($separator));
my $fsend_data = substr($data_fsend,$offset);
my $fsend_data_bin = sprintf unpack("b*",$fsend_data);# converte a mensagem para binario

my @serverfulladdr = split(':', $fsend_serverinfo);
my $serveraddr = $serverfulladdr[0];
my $serverport = $serverfulladdr[1];

########## cria socket
print "Connecting on server [ip:".$serveraddr." port:".$serverport."]...\n";
$socket = new IO::Socket::INET (
	PeerHost => $serveraddr,
	PeerPort => $serverport,
	Proto    => 'tcp'        
) or die "Erro : $!\n";


##########  cria PDU
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
my $so =  "$^O\n";
my $cmac = "00:00:00:00:00:00";
if(index($so, "linux") != -1) {
    $cmac = substr `cat /sys/class/net/*/address`,0,17;
}elsif(index($so,"Win") != -1){
    $cmac = `getmac`;
	if($cmac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
		$cmac = $1;
	}
}
my $cmac_bin = sprintf unpack("b*",$cmac );

# dado a ser enviado tera 46 bytes
# tamanho do quadro
# 7 + 1 + 6 + 6 + 46 = 66 bytes
my $length = '00000000‭01000010';
my $length_bin = sprintf unpack("b*",$length );

my $pre_pdu = $preambulo_bin.$start_frame_bin.$mac_bin.$cmac_bin.$length_bin;


######### loop
print "Running...\n";
while(1){
	# TODO corrigir aqui
	$fsend_data_bin = $pre_pdu.$fsend_data_bin; # concatena o os campos da pdu
	my $thread_1 = threads->create(\&send_message,$socket,$fsend_data_bin) or die "Erro no envio"; #envia o quadro
	$thread_1->join();
	print "[DEBUG] Posição do mouse enviada para camada fisica\n";

	######### espera uma mensagem do controlled (tela)
	$freceive_bin = <$socket>;
	if(defined $freceive_bin){
		print "[DEBUG] Imagem recebida da camada fisica\n";
		$freceive = sprintf pack("b*",$freceive_bin); # converte para string
		$freceive_data = substr $freceive , 117; # extrai da mensagem o conteudo efetivo
		open($f_receive, '>', $file_slave) or die "Não foi possível abrir o arquivo '$file_slave' $!";
		print $f_receive $freceive_data;
		close $f_receive;
		print "[DEBUG] Arquivo com a tela salvo para a camada de aplicação\n";
	}

	######### le mensagem da camada de cima (posicao do mouse)
	$tryopenfile=1;
	while($tryopenfile){
		try {
			open($f_send, '<:encoding(UTF-8)', $file_master) or die "Nao foi possivel abrir o arquivo '$file_master' $!";
			$data_fsend = <$f_send>;
			close $f_send;
			$tryopenfile=0;
			print "[DEBUG] Arquivo com a posicao do mouse lido da camada de aplicação\n";
			unlink $file_master; #deleta o arquivo
		} catch {
		};
	}	
	$offset = index($data_fsend,$separator) + length($separator);
	$fsend_data = substr($data_fsend,$offset);
	$fsend_data_bin = sprintf unpack("b*",$fsend_data); # converte a mensagem para binario
}
$socket->close();
print "Bye!\n";	


###### Funcao para enviar mensagem
sub send_message{
	# pegar parametros passados
	my @s = @_ ;
	my $sk = $s[0];
	my $data = $s[1];
	
	my ($colisao,$time); 
	$colisao = int(rand(10)); # colisao se o numero for >= 4
	while($colisao le 4){ #ocorreu colisao
		$time = int(rand(10)/10);
		sleep($time); # espera um tempo aleatorio
		$colisao = int(rand(10)); #calcula se vai ocorrer outra colisao
	}	
	print $sk "$data\n"; #envia os dados
	threads->exit();
}
