#!/usr/bin/perl -w			
 
use 5.010;
use warnings;	
use strict;
use Socket;

my $port = shift || 7890;
my $proto = getprotobyname('tcp');

# cria um socket 
socket(SERVER, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";

# configura o socket para se reutilizavel
setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, 1) or die "setsock: $!";

# obtem uma porta
my $paddr = sockaddr_in($port, INADDR_ANY);

# liga a porta ao socket, e comeca a escutar
bind(SERVER, $paddr) or die "bind: $!";

# comeca a escutar
# SOMAXCONN eh o tamanho máximo da fila para conexões de clientes pendentes
listen(SERVER, SOMAXCONN) or die "listen: $!";

print "SERVER started on port $port\n";

# para cada conexao
my $client_addr;

# o servidor pode aceitar ou nao uma conexao
# se uma conexao for aceita, um novo socket eh criado -> CLIENT
if ($client_addr = accept(CLIENT, SERVER)) {

    # retorna o número da porta e o ip do cliente em formato compactado 
    my ($client_port, $client_ip) = sockaddr_in($client_addr);
	
	# converte o ip compactado em string(ASCII)
    my $client_ipnum = inet_ntoa($client_ip);
	
    # log de dados da conexao
    print "conectado : $client_ipnum]\n";
	
   # envia uma msg
    print CLIENT "Eu sou o servidor bro",
	
}

#fecha conexao
close CLIENT or die "close: $!";