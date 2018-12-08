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

# declara variaveis
my $address = '172.16.252.75';
my $port = '7978';

my $socket = create_server($port,$address);
my $server_socket = $socket->accept() or die "[ERRO CAMADA FISICA] erro no inicio de conexao com o cliente"; # aceita ou nao a conexao com um cliente

# recebe o primeiro ACK
my $receive_bin = <$server_socket>;
my $receive = sprintf pack("b*",$receive_bin); 
print 'Primeiro ack recebido :>' . $receive;

# escreve no arquivo o primeiro ACK
write_file('transporte+fisica.txt',$receive . 'TRANSPORT_DIDNT|PHYSICAL_DONE');

my $data_file;
my @array_data_file;
# fica esperando a camada de transporte ler e escrever o segundo ACK
do{
	$data_file = read_file('transporte+fisica.txt');
	@array_data_file = split( $control_separator , $data_file );
}while(($array_data_file[1] eq 'TRANSPORT_DIDNT|PHYSICAL_DONE')
			|| ($array_data_file[1] eq 'TRANSPORT_DIDNT|PHYSICAL_DIDNT'));

# enviar o segundo ACK
my $thread = threads->create(\&send_message,$server_socket,$array_data_file[0]) or die "Erro no envio"; 
$thread->join();

# espera o terceiro ACK
$receive_bin = <$server_socket>;
$receive = sprintf pack("b*",$receive_bin); 
print 'Terceiro ack recebido :>' . $receive;

# escreve no arquivo o terceiro ACK
write_file('transporte+fisica.txt',$receive + 'TRANSPORT_DIDNT|PHYSICAL_DONE');





















# #!/usr/bin/perl

# ######### includes
# use 5.010;
# use strict;
# use threads;
# use warnings;
# use IO::Socket::INET;
# use Time::HiRes('sleep');
# use Try::Tiny;
# use Net::Address::IP::Local; # eh necessario instalar esse modulo a partir do cpan



# ######### declara variaveis
# my $port='7878';
# my ($socket,$clientsocket,$serverdata,$clientdata);
# my ($mensagem_do_cliente,$mensagem_do_cliente_bin);

# my $first_file = "message_master.txt";
# my $file_master = "message_master.txt";
# my $file_slave = "message_slave.txt";

# my $separator = chr(30);
# my $f_receive;
# my $tryopenfile;
# my $freceive_bin;
# my $freceive;
# my $freceive_data;
# my $data_fsend;
# my $f_send;
# my $fsend_data;
# my $fsend_data_bin;

# ######### cria o socket, com possibilidade de apenas um cliente conectado (Reuse eh 1 pois o socket pode ser reutilizavel)
# my $address;
# my $so =  "$^O\n";
# if(index($so, "linux") != -1) {
#     $address = eval{Net::Address::IP::Local->public_ipv4}; #descobre o ip da maquina servidor
# }elsif(index($so,"Win") != -1){
# 	$address = Net::Address::IP::Local->public;
# }else{
# 	$address = "127.0.0.1";
# }

# print "Starting server [ip:".$address." port:".$port."]...\n";
# $socket = new IO::Socket::INET ( 
# 	LocalHost => $address,
# 	LocalPort => $port,
# 	Proto     => 'tcp',
# 	Listen    => 1,
# 	Reuse     => 1              
# )or die "Erro: $! \n";
# $clientsocket = $socket->accept() or die "Erro no inicio de conexao com o cliente"; # aceita ou nao a conexao com um cliente

# ##########  cria PDU
# # preambulo da pdu = 7 bytes
# my $preambulo = '10101010101010101010101010101010101010101010101010101010';
# my $preambulo_bin = sprintf unpack("b*",$preambulo);

# # início do delimitador de Quadro = 1 byte
# my $start_frame = '10101011';
# my $start_frame_bin = sprintf unpack("b*",$start_frame);

# # mac do destino =  6 bytes
# my $mac = `arp -a $address`;
# if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
# 	$mac = $1;
# }
# my $mac_bin = sprintf unpack("b*",$mac);

# # mac do remetente = 6 bytes
# $so =  "$^O\n";
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

# # dado a ser enviado tera 46 bytes
# # tamanho do quadro
# # 7 + 1 + 6 + 6 + 46 = 66 bytes
# my $length = '00000000‭01000010';
# my $length_bin = sprintf unpack("b*",$length );

# my $pre_pdu = $preambulo_bin.$start_frame_bin.$mac_bin.$cmac_bin.$length_bin;

# ######### loop
# print "Running...\n";
# while(1){
# 	######### espera uma mensagem do controller (posicao do mouse)
# 	$freceive_bin = <$clientsocket>;
# 	if(defined $freceive_bin){
# 		print "[DEBUG] Posicao do mouse recebida da camada fisica\n";
# 		$freceive = sprintf pack("b*",$freceive_bin); # converte para string
# 		$freceive_data = substr $freceive , 117; # extrai da mensagem o conteudo efetivo
# 		open($f_receive, '>', $file_master) or die "Não foi possível abrir o arquivo '$file_master' $!";
# 		print $f_receive $freceive_data;
# 		close $f_receive;
# 		print "[DEBUG] Arquivo com posicao do mouse salvo para a camada de aplicação\n";
# 	}

# 	######### le mensagem da camada de cima (tela)
# 	$tryopenfile=1;
# 	while($tryopenfile){
# 		try {
# 			open($f_send, '<:encoding(UTF-8)', $file_slave) or die "Nao foi possivel abrir o arquivo '$file_slave' $!";
# 			$fsend_data = <$f_send>;
# 			close $f_send;
# 			$tryopenfile=0;
# 			print "[DEBUG] Arquivo com a tela lido da camada de aplicação\n";
# 			unlink $file_slave; #deleta o arquivo
# 		} catch {
# 		};
# 	}	
# 	$fsend_data_bin = sprintf unpack("b*",$fsend_data); # converte a mensagem para binario
# 	$fsend_data_bin = $pre_pdu.$fsend_data_bin; # concatena o os campos da pdu
# 	my $thread_1 = threads->create(\&send_message,$clientsocket,$fsend_data_bin) or die "Erro no envio"; #envia o quadro
# 	$thread_1->join();
# 	print "[DEBUG] Tela enviada enviada para camada fisica\n";
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
