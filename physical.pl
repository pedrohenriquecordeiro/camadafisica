#!/usr/bin/perl

use 5.010;
use strict;
use Thread;
use warnings;
use IO::Socket::INET;
use Time::HiRes('sleep');
use Try::Tiny;
use Net::Address::IP::Local;
use threads;
use threads::shared;

sub fixStrSize {
	my ($str,$size) = @_;
	if ($size<=length($str)) {
		return substr($str,length($str)-$size,$size);
	}else{
		my $leadings=$size-length($str);
		return "0"x$leadings.$str;
	}
}


package Bit;

sub new {
	my $class = @_;
	my $self = {
		preamble  => 0b01010101, # const 7 bytes
		startOfFrame => 0b10101011, # const 1 byte
		scrAddr  => 0, # 6 bytes (MAC)
		dstAddr  => 0, # 6 bytes (MAC)
		length  => 0, # 2 bytes
		data  => "", # 46 bytes <= data <= 1500 bytes
		cyclicRCheck  => 0, # 4 bytes checksum
	};
	return bless $self, $class;
}

sub new_toSend {
	my ($class, $scrAddr, $dstAddr, $data) = @_;
	my $self = $class->new();
	$self->{scrAddr} = $scrAddr; 
	$self->{dstAddr} = $dstAddr;
	$self->{data} = $data; 
	$self->{length} = length($data)+(56+8+48+48+16+32);
	genCheckSum();
	return $self;
}


sub new_toReceive {
	my ($class, $bit) = @_;
	my $self = $class->new();
	my $i=0;
	FOR:for my $c (split //, $bit) {
		my $v = ord($c);
		if ($i==0){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==1){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==2){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==3){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==4){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==5){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==6){
			if($v != $self->{preamble}){
				# TODO error
				print ("Invalid header (preamble)\n");
			}
		}elsif($i==7){
			$self->{startOfFrame}=$v;
		}elsif($i==8){
			$self->{scrAddr}=$v<<40;
		}elsif($i==9){
			$self->{scrAddr}=$self->{scrAddr}|($v<<32);
		}elsif($i==10){
			$self->{scrAddr}=$self->{scrAddr}|($v<<24);
		}elsif($i==11){
			$self->{scrAddr}=$self->{scrAddr}|($v<<16);
		}elsif($i==12){
			$self->{scrAddr}=$self->{scrAddr}|($v<<8);
		}elsif($i==13){
			$self->{scrAddr}=$self->{scrAddr}|$v;
		}elsif($i==14){
			$self->{dstAddr}=$v<<40;
		}elsif($i==15){
			$self->{dstAddr}=$self->{dstAddr}|($v<<32);
		}elsif($i==16){
			$self->{dstAddr}=$self->{dstAddr}|($v<<24);
		}elsif($i==17){
			$self->{dstAddr}=$self->{dstAddr}|($v<<16);
		}elsif($i==18){
			$self->{dstAddr}=$self->{dstAddr}|($v<<8);
		}elsif($i==19){
			$self->{dstAddr}=$self->{dstAddr}|$v;
		}elsif($i==20){
			$self->{length}=$v<<8;
		}elsif($i==21){
			$self->{length}=$self->{length}|$v;
			my $datasize=$self->{length}-(56+8+48+48+16+32);
			$self->{data}=substr($bit,22,$datasize);
			$self->{cyclicRCheck}=(ord(substr($bit, 22+$datasize,1))<<24)|(ord(substr($bit, 22+$datasize+1,1))<<16)|(ord(substr($bit, 22+$datasize+2,1))<<8)|ord(substr($bit, 22+$datasize+3,1));
			last FOR;
		}else{
			# TODO error
			print ("Invalid header\n");
		}
		$i++;
	}
	if (!Bit::checkSum($self)){
		# TODO error
		print ("Invalid checksum\n");
	}
	return $self;
}


sub toString {
	my $self = shift;
	my $str=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{preamble}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{startOfFrame}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{scrAddr}), 48);
	$str.=fixStrSize(sprintf("%b", $self->{dstAddr}), 48);
	$str.=fixStrSize(sprintf("%b", $self->{length}), 16);
	$str.=$self->{data};
	$str.=fixStrSize(sprintf("%b", $self->{cyclicRCheck}), 32);
	if (length($self->{data})<48){
		$str.= chr(0)x(48-length($self->{data}));
	}
	return $str;
}

sub toBin {
	my $self = shift;
	my $bit="";
	$bit.=chr($self->{preamble}).chr($self->{preamble}).chr($self->{preamble}).chr($self->{preamble}).chr($self->{preamble}).chr($self->{preamble}).chr($self->{preamble});
	$bit.=chr($self->{startOfFrame}&0b11111111);
	$bit.=chr($self->{scrAddr}>>40&0b11111111).chr($self->{scrAddr}>>32&0b11111111).chr($self->{scrAddr}>>24&0b11111111).chr($self->{scrAddr}>>16&0b11111111).chr($self->{scrAddr}>>8&0b11111111).chr($self->{scrAddr}&0b11111111);
	$bit.=chr($self->{dstAddr}>>40&0b11111111).chr($self->{dstAddr}>>32&0b11111111).chr($self->{dstAddr}>>24&0b11111111).chr($self->{dstAddr}>>16&0b11111111).chr($self->{dstAddr}>>8&0b11111111).chr($self->{dstAddr}&0b11111111);
	$bit.=chr($self->{length}>>8&0b11111111).chr($self->{length}&0b11111111);
	$bit.=$self->{data};
	$bit.=chr($self->{cyclicRCheck}>>24&0b11111111).chr($self->{cyclicRCheck}>>16&0b11111111).chr($self->{cyclicRCheck}>>8&0b11111111).chr($self->{cyclicRCheck}&0b11111111);
	if (length($self->{data})<48){
		$bit.= chr(0)x(48-length($self->{data}));
	}
	return $bit;
}

sub toData {
	my $self = shift;
	my $data=$self->{data};
	return $data;
}

sub genCheckSum {
	# my $self = shift;
	# TODO implement
}

sub checkSum {
	my $self = shift;
	# TODO implement
	return 1;
}


package PhysicalLayer;

sub new {
	my ($class) = @_;
	my %clientsockets;
	my $self = {
		mac  => $class->getMAC(),
		sockets => {},
		socket => 0,
		isServer => -1,
	};
	my $port=666;
	my $opt;
	print ("-------------------------------------\n");
	print ("-Bem vindo ao Protocolo Mickey Mouse-\n");
	print ("-------------------------------------\n");
	do{
		print ("Digite uma das opções abaixo:\n");
		print ("S - Camada fisica se comportando como servidor*\n");
		print ("C - Camada fisica se comportando como cliente\n");
		print ("E - Sair\n");
		print ("*Apenas um dispositivo da rede deve ser servidor!\n");
		my $line= <STDIN>;
		chomp $line;
		$opt=uc(substr($line,0,1));
		if ($opt eq "S") {
			$self->{isServer}=1;
		}elsif ($opt eq "C"){
			$self->{isServer}=0;
		}elsif ($opt eq "E"){
			exit 0;
		}else{
			print ("Opção invalida\n");
		}
	}while ($self->{isServer} == -1);
	if ($self->{isServer}){
		print ("\n\n");
		my $so="$^O\n";
		my $socketIp="127.0.0.1";
		if(index($so, "linux") != -1) {
			$socketIp=eval{Net::Address::IP::Local->public_ipv4};
		}elsif(index($so,"Win") != -1){
			$socketIp=Net::Address::IP::Local->public;
		}
		print "Starting server [ip:".$socketIp." port:".$port."]...";
		$self->{socket}=new IO::Socket::INET ( 
			LocalHost => $socketIp,
			LocalPort => $port,
			Proto     => 'tcp',
			Listen    => 10,
			Reuse     => 1
		)or die "\nErro: $! \n";
		print ("OK\n");
	}else{
		print "Digite o ip do socket servidor: \n";
		my $socketIp = <STDIN>;
		chomp $socketIp;
		print ("\n\n");
		print "Connecting on server [ip:".$socketIp." port:".$port."]...";
		$self->{socket}=new IO::Socket::INET (
			PeerHost => $socketIp,
			PeerPort => $port,
			Proto    => 'tcp'
		) or die "\n[Erro]$!\n";
		print ("OK\n");
	}
	return bless $self, $class;
}

sub arp {
	my ($class, $ip) = @_;
	my $re1='.*?';	# Non-greedy match on filler
	my $re2='((?:[0-9A-Fa-f][0-9A-Fa-f]:){5}(?:[0-9A-Fa-f][0-9A-Fa-f]))(?![:0-9A-Fa-f])';	# Mac Address 1
	my $re3='.*?';	# Non-greedy match on filler

	my $re=$re1.$re2.$re3;
	my $mac_raw = `arp -a $ip`;
	if ($mac_raw =~ m/$re/is){
		my $mac=$1;
		my $mac_int = 0;
		my $offset=44;
		for my $c (split //, $mac) {
			if (length $c && $c !~ tr/0-9A-Fa-f//c){
				my $v = hex($c);
				$mac_int=$mac_int|($v<<$offset);
				$offset-=4;
			}
		}
		return $mac_int;
	}else{
		# TODO error
		print("Error, could not detect MAC address, using IP...\n");
		my @ip_arr = split(/\./, $ip);
		my $ip_dec=(($ip_arr[3]+0))|(($ip_arr[2]+0)<<8)|(($ip_arr[1]+0)<<16)|(($ip_arr[0]+0)<<24);
		return $ip_dec;
	}
		
}

sub getMAC {
	my $class = shift;
	my $so = "$^O\n";
	my $mac;
	if(index($so, "linux") != -1) {
		$mac = substr `cat /sys/class/net/*/address`,0,17;
	}elsif(index($so,"Win") != -1){
		$mac = `getmac`;
		if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
			$mac = $1;
		}
	}else{
		$mac = "00:00:00:00:00:00";
	}
	my $mac_int = 0;
	my $offset=44;
	for my $c (split //, $mac) {
		if (length $c && $c !~ tr/0-9A-Fa-f//c){
			my $v = hex($c);
			$mac_int=$mac_int|($v<<$offset);
			$offset-=4;
		}
	}
	return $mac_int;
}

sub read_file{
	my ($class, $file, $encoding) = @_;
	my ($read, $data);
	open($read, '<:'.$encoding, $file) or die "[ERRO]Nao foi possivel abrir o arquivo '$file' $!\n";
	$data= <$read>;
	close $read;
	return $data;
}

sub write_file{
	my ($class, $file, $data, $encoding) = @_;
	my $write;
	open($write, '>:'.$encoding, $file) or die "[ERRO]Nao foi possivel abrir o arquivo '$file' $!\n";
	print $write "$data\n";
	close $write;
}

sub socketSend {
	my ($self, $dst, $data) = @_;
	print("Thread - Socket Send\n");
	my ($colisao,$time); 
	$colisao = int(rand(10)); 		# colisao se o numero for >= 4
	while($colisao le 4){ 			#ocorreu colisao
		print("Colisao\n");
		$time = int(rand(10)/10);
		sleep($time); 				# espera um tempo aleatorio
		$colisao = int(rand(10));	#calcula se vai ocorrer outra colisao
	}	
	if ($self->{isServer}) {
		print("Enviando para: ".$dst."\n");
		if (exists $self->{sockets}{$dst}){
			my $sk=$self->{sockets}{$dst};
			print $sk "$data\n";
		}else{
			print("Destinatário não existente\n");
		}
	}else{
		my $sk=$self->{socket};
		print $sk "$data\n";
	}
}

sub forwardBit {
	my $self = shift;
	print ("Thread - Forward Bit\n");
	while (1){
		if (-e "packet_out.pdu" && -e "routed_ip.zap"){
			my $dstIP=$self->read_file("routed_ip.zap","encoding(UTF-8)");
			my $packet=$self->read_file("packet_out.pdu","raw");
			unlink "routed_ip.zap";
			unlink "packet_out.pdu";
			my $dstMAC=$self->arp($dstIP);
			my $bit=Bit->new_toSend($self->{mac}, $dstMAC, $packet);
			my $bit_bin=Bit::toBin($bit);
			Thread->new( sub { $self->socketSend($dstMAC,$bit_bin); } );
		}
	}
}


sub backwardBit {
	my ($self,$bit) = @_;
	print ("Thread - Backward Bit\n");
	while (1){
		if (!-e "bit_out.pdu"){
			my $data=$bit->toData();
			write_file("bit_out.pdu",$data,"raw");
			last;
		}
	}
	
}

sub receiveMessage {
	my ($self,$sock) = @_;
	print ("Thread - Receive Message\n");
	while (1) {
		my $data=<$sock>;
		if(defined $data){
			my $bit=Bit->new_toReceive($data);
			if ($bit->{dstAddr} == $self->{mac}){
				Thread->new( sub { $self->backwardBit($bit); } );
			}else{
				if ($self->{isServer}) {
					if (exists $self->{sockets}{$bit->{dstAddr}}){
						my $sk=$self->{sockets}{$bit->{dstAddr}};
						print $sk "$data\n";
					}
				}
			}
		}
	}
	
}

sub receiveClients {
	my $self = shift;
	my $sk=$self->{socket};	
	print ("Recebendo clientes...\n");
	print ("Digite a quantidade de clientes que irão conectar:\n");
	my $line= <STDIN>;
	chomp $line;
	my $clients=$line+0;
	my $cur_clients=0;
	while (1) {
		if (my $client=$sk->accept()){
			my $client_mac=$self->arp($client->peerhost());
			print($client->peerhost()."\n");
			print($client_mac."\n");
			$self->{sockets}{$client_mac}=$client;
			$cur_clients=$cur_clients+1;
		}
		if ($clients==$cur_clients){
			last;
		}
	}
	
}

sub run {
	my $self = shift;
	print ("Main Thread - Run\n");
	if ($self->{isServer}){
		$self->receiveClients();
		my %hash_sockts=$self->{sockets}->%*;
		foreach my $key (keys %hash_sockts){
			my $sk = $self->{sockets}{$key};
		  	Thread->new( sub { $self->receiveMessage($sk); } );
		}
		Thread->new( sub { $self->forwardBit(); } );
	}else{
		Thread->new( sub { $self->receiveMessage($self->{socket}); } );
		Thread->new( sub { $self->forwardBit(); } );
	}
	my $opt;
	do{
		print ("Digite 'Q' para encerrar a aplicação\n");
		my $line= <STDIN>;
		chomp $line;
		$opt=uc(substr($line,0,1));
		if ($opt eq "Q") {
			exit 0;
		}else{
			print ("Opção invalida\n");
		}
	}while (1);
}



package Main;

my $pl=PhysicalLayer->new();
$pl->run();
	