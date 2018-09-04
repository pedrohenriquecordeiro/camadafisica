 #! /usr/bin/perl			#Usado para chamar o interpretador do perl
 
 # server.pl
 use IO::Socket::INET;			#biblioteca que encapsula as funcionalidades do socket
 print "Servidor Socket TCP em Perln";# Criando o socket
 $server = IO::Socket::INET->new(
 		LocalAddr=>"localhost",	# host
 		LocalPort=>7000,	# porta que vai ficar em listening
 		Proto=>'tcp',		# protocolo
 		Listen=>10		# numero maximo de clientes conectados
 		);

$sock_client = $server->accept();	# aceitando o socket cliente
 
 while( 1 )
 {
 	$sock_client->recv($data,1024);	# recebendo os dados do cliente
 	if($data)
 	{
 		print "nRecebido: ", $data,"n";
 	}
 }