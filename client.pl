#! /usr/bin/perl
 
 # client.pl
 use IO::Socket::INET;
 print "Cliente Socket TCP em Perl";# Criando o socket cliente
 $client = IO::Socket::INET->new(
 			PeerAddr=>"localhost",		# host do server
                                     PeerPort  => "7000",# porta em que o server está listening
                                     Timeout   => 60 );	# timeout de conexao
 
 while(1)
 {
     $msg = "Mensagem de teste!";
     print "nEnviando: ",$msg, " ";

    if($client->send($msg))				#enviando a mensagem
     {
             print "-> Enviado com sucesso","n";
 	sleep(5);
     }
 }