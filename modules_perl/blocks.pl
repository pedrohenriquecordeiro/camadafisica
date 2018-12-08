sub hand_shaking_client{

    require '../modules_perl/modules.pl';
    our ( $atribute_separator , $control_separator );

    # pegar parametros passados
	my @s = @_ ;
	my $server_port = $s[0];
	my $server_ip   = $s[1];

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
    
}

sub hand_shaking_server{

    # pegar parametros passados
	my @s = @_ ;
	my $port = $s[0];
	my $address = $s[1];

    require '../modules_perl/modules.pl';
    our ( $atribute_separator , $control_separator );

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

}


## eh necessario retorna um true
1;