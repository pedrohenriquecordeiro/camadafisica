#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;

my ($socket,$serverdata,$clientdata);

#criado o socket
$socket = new IO::Socket::INET (
  PeerHost => '192.168.1.6',
  PeerPort => '7878'       ,
  Proto    => 'tcp'        
) or die "Erro : $!\n";

print "Connected to the Server.\n";

# espera uma mensagem vindo do servidor
$serverdata = <$socket>;
print "Message from Server : $serverdata \n";


# envia uma mensagem para o servido
$clientdata = "This is the Client speaking :)";
print $socket "$clientdata \n";

#fecha a conexao
$socket->close();