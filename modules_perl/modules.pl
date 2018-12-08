our ( $atribute_separator , $control_separator );
$atribute_separator = ':';
$control_separator = '=';

###### funcao para efetuar conexao com servidor
sub connect_client{
	# pegar parametros passados
	my @s = @_ ;
	my $server_port = $s[0];
	my $server_ip   = $s[1];
	
	########## cria socket
	print "[DEBUG:CAMADA FISICA]Connecting on server [ip:".$server_ip." port:".$server_port."]...\n";
	my $socket = new IO::Socket::INET (
		PeerHost => $server_ip,
		PeerPort => $server_port,
		Proto    => 'tcp'        
	) or die "[Erro]$!\n";
	print "[DEBUG:CAMADA FISICA]Connected on server [ip:".$server_ip." port:".$server_port."]...\n";

	return $socket;
}

sub create_server{
	# pegar parametros passados
	my @s = @_ ;
	my $port = $s[0];
	my $address  = $s[1];

	print "[DEBUG CAMADA FISICA - SERVIDOR] : Starting server ip:".$address." port:".$port."...\n";
	my $socket = new IO::Socket::INET ( 
		LocalHost => $address,
		LocalPort => $port,
		Proto     => 'tcp',
		Listen    => 1,
		Reuse     => 1              
	)or die "[ERRO] on create socket: $! \n";
	
	return $socket;
}

###### Funcao para enviar mensagem
sub send_message{
	# pegar parametros passados
	my @s = @_ ;
	my $sk = $s[0];
	my $data = $s[1];
	
	my ($colisao,$time);
    # colisao se o numero for >= 4 
	$colisao = int(rand(10)); 
    #ocorreu colisao
	while($colisao le 4){ 
		$time = int(rand(10)/10);
        # espera um tempo aleatorio
		sleep($time); 
        #calcula se vai ocorrer outra colisao
		$colisao = int(rand(10)); 
	}	
    #envia os dados
	my $data_bin = sprintf unpack("b*",$data);
	print $sk "$data_bin\n"; 
	threads->exit();
}

## funcao que cria a PDU da camada fisica
sub create_pdu{
	# pegar parametros passados
	my @s = @_ ;
	my $msg = $s[0];

	# cria PDU
	# preambulo da pdu = 7 bytes
	my $preambulo = '10101010101010101010101010101010101010101010101010101010';


	# início do delimitador de Quadro = 1 byte
	my $start_frame = '10101011';

	# mac do destino =  6 bytes
	my $mac = `arp -a $serveraddr`;
	if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
		$mac = $1;
	}

	# mac do remetente = 6 bytes
	my $so =  "$^O\n";
	my $cmac;
	if(index($so, "linux") != -1) {
		$cmac = substr `cat /sys/class/net/*/address`,0,17;
	}elsif(index($so,"Win") != -1){
		$cmac = `getmac`;
		if($cmac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
			$cmac = $1;
		}
	}else{
		$cmac = "00:00:00:00:00:00";
	}

	# tamanho do segmento
	my $length = '00000000‭01000010';

	# concatena os campos
	my $pdu = $preambulo.':'.$start_frame.':'.$mac.':'.$cmac.':'.$length;
	my $pdu_bin = sprintf unpack("b*",$pdu);

	return $pdu_bin;
}

## funcao que le um arquivo
sub read_file{
	# pegar parametros passados
	my @s = @_ ;
	my $file = $s[0];

	my $read;
    my $data;

	try {
		open($read, '<:encoding(UTF-8)', $file) or die "[ERRO]Nao foi possivel abrir o arquivo '$file' $!";
		$data= <$read>;
		close $read;
	} catch {
		die "[ERRO CAMADA FISICA : falha em ler o arquivo '$file'";
	};

	return $data;
}

## funcao que escreve em um arquivo
sub write_file{
	# pegar parametros passados
	my @s = @_ ;
	my $file = $s[0];
    my $data = $s[1];

	my $write;

	try {
		open($write, '>', $file) or die "[ERRO]Nao foi possivel abrir o arquivo '$file' $!";
		print $write $data;
		close $write;
	} catch {
		die "[ERRO CAMADA FISICA : falha em escrever no arquivo '$file'";
	};
}

sub delete_file{
	# pegar parametros passados
	my @s = @_ ;
	my $file = $s[0];

	#deleta o arquivo
	unlink $filer; 
}

## eh necessario retorna um true
1;