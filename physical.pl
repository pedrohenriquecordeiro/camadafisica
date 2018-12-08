#!/usr/bin/perl

use 5.010;
use strict;
use threads;
use warnings;
use IO::Socket::INET;
use Time::HiRes('sleep');
use Try::Tiny;
use Net::Address::IP::Local;

sub fixStrSize {
	my ($str,$size) = @_;

	if ($size<=length($str)) {
		return substr($str,length($str)-size,size);
	}else{
		my $leadings=size-length($str);
		return "0"x$leadings.$str;
	}
}

package Bit;

sub new {
	my $class = @_;

	my $self = {
		preamble  => 0b10101010101010101010101010101010101010101010101010101010, # const 7 bytes
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
	$self->genCheckSum();

	return $self;
}


sub new_toReceive {
	my ($class, $bit) = @_;

	my $self = $class->new();
	my $i=0;
	FOR:for my $c (split //, $bit) {
		my $v = ord($c);
		switch ($v) {
			case  0 {$self->{preamble}=$v<<48;}
			case  1 {$self->{preamble}=$self->{preamble}|($v<<40);}
			case  2 {$self->{preamble}=$self->{preamble}|($v<<32);}
			case  3 {$self->{preamble}=$self->{preamble}|($v<<24);}
			case  4 {$self->{preamble}=$self->{preamble}|($v<<16);}
			case  5 {$self->{preamble}=$self->{preamble}|($v<<8);}
			case  6 {$self->{preamble}=$self->{preamble}|$v;}
			case  7 {$self->{startOfFrame}=$v;}
			case  8 {$self->{scrAddr}=$v<<40;}
			case  9 {$self->{scrAddr}=$self->{scrAddr}|($v<<32);}
			case 10 {$self->{scrAddr}=$self->{scrAddr}|($v<<24);}
			case 11 {$self->{scrAddr}=$self->{scrAddr}|($v<<16);}
			case 12 {$self->{scrAddr}=$self->{scrAddr}|($v<<8);}
			case 13 {$self->{scrAddr}=$self->{scrAddr}|$v;}
			case 14 {$self->{dstAddr}=$v<<40;}
			case 15 {$self->{dstAddr}=$self->{dstAddr}|($v<<32);}
			case 16 {$self->{dstAddr}=$self->{dstAddr}|($v<<24);}
			case 17 {$self->{dstAddr}=$self->{dstAddr}|($v<<16);}
			case 18 {$self->{dstAddr}=$self->{dstAddr}|($v<<8);}
			case 19 {$self->{dstAddr}=$self->{dstAddr}|$v;}
			case 20 {$self->{length}=$v<<8;}
			case 21 {
				$self->{length}=$self->{length}|$v;
				my $datasize=$self->{length}-(56+8+48+48+16+32);
				$self->{data}=substr($bit,22,$datasize);
				$self->{cyclicRCheck}=(ord(substr($bit, 22+$datasize,1))<<24)|(ord(substr($bit, 22+$datasize+1,1))<<16)|(ord(substr($bit, 22+$datasize+2,1))<<8)|ord(substr($bit, 22+$datasize+3,1));
				last FOR;
			}
			else{
				# TODO error
				print ("Invalid header"); 
			}
		}
		$i++;
	}
	if (!$self->checkSum()){
		# TODO error
		print ("Invalid checksum");
	}
	return $self;
}


sub toString {
	my $self = shift;

	my $str=fixStrSize(sprintf("%b", $self->{preamble}), 56);
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
	$bit.=chr($self->{preamble}>>48&0b11111111).chr($self->{preamble}>>40&0b11111111).chr($self->{preamble}>>32&0b11111111).chr($self->{preamble}>>24&0b11111111).chr($self->{preamble}>>16&0b11111111).chr($self->{preamble}>>8&0b11111111).chr($self->{preamble}&0b11111111);
	$bit.=chr($self->{startOfFrame}&0b11111111);
	$bit.=chr($self->{scrAddr}>>40&0b11111111).chr($self->{scrAddr}>>32&0b11111111).chr($self->{scrAddr}>>24&0b11111111).chr($self->{scrAddr}>>16&0b11111111).chr($self->{scrAddr}>>8&0b11111111).chr($self->{scrAddr}&0b11111111);
	$bit.=chr($self->{dstAddr}>>40&0b11111111).chr($self->{dstAddr}>>32&0b11111111).chr($self->{dstAddr}>>24&0b11111111).chr($self->{dstAddr}>>16&0b11111111).chr($self->{dstAddr}>>8&0b11111111).chr($self->{dstAddr}&0b11111111);
	$bit.=chr($self->{length}>>8&0b11111111).chr($self->{length}&0b11111111);
	$bit.=chr($self->{data});
	$bit.=chr($self->{cyclicRCheck}>>24&0b11111111).chr($self->{cyclicRCheck}>>16&0b11111111).chr($self->{cyclicRCheck}>>8&0b11111111).chr($self->{cyclicRCheck}&0b11111111);
	if (length($self->{data})<48){
		$str.= chr(0)x(48-length($self->{data}));
	}
	return $bit;
}

sub toData {
	my $self = shift;

	my $data=$self->{data};

	return $data;
}

sub genCheckSum {
	my $self = shift;
	# TODO implement
}

sub checkSum {
	my $self = shift;
	# TODO implement
	return 0;
}

1;


package PhysicalLayer;

sub new {
	my ($class, $isServer) = @_;

	my $self = {
		mac  => $class->getMAC(),
		sockets => {},
		socket => 0,
	};
	my $port=666;
	if ($isServer){
		my $so="$^O\n";
		my $socketIp="127.0.0.1";
		if(index($so, "linux") != -1) {
			$socketIp=eval{Net::Address::IP::Local->public_ipv4};
		}elsif(index($so,"Win") != -1){
			$socketIp=Net::Address::IP::Local->public;
		}
		print "Starting server [ip:".$socketIp." port:".$port."]...\n";
		$self->{socket}=new IO::Socket::INET ( 
			LocalHost => $socketIp,
			LocalPort => $port,
			Proto     => 'tcp',
			# Listen    => 10,
			Reuse     => 1
		)or die "Erro: $! \n";
	}else{
		print "Digite o ip do socket servidor: ";
		my $socketIp = <STDIN>;
		chomp $socketIp;
		$self->{socket}=new IO::Socket::INET (
			PeerHost => $socketIp,
			PeerPort => $port,
			Proto    => 'tcp'
		) or die "[Erro]$!\n";
	}
	

	return bless $self, $class;
}

sub arp {
	my ($class, $ip) = @_;

	my $mac = `arp -a $ip`;
	if($mac =~ m/(\w\w-\w\w-\w\w-\w\w-\w\w-\w\w) | (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w) /){
		$mac=$1;
	}
	my $mac_bin = 0;
	my $offset=44;
	for my $c (split //, $mac) {
		if ($c ne ":"){
			my $v = hex($c);
			$mac_bin=$mac_bin|($v<<$offset);
			$offset-=4;
		}
	}
	return $mac_bin;
}

sub getMAC {
	my $class = shift;

	my $so =  "$^O\n";
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
	my $mac_bin = 0;
	my $offset=44;
	for my $c (split //, $mac) {
		if ($c ne ":"){
			my $v = hex($c);
			$mac_bin=$mac_bin|($v<<$offset);
			$offset-=4;
		}
	}
	return $mac_bin;
}

sub read_file{
	my ($class, $file, $encoding) = @_;

	my ($read, $data);
	try {
		open($read, '<:$encoding', $file) or die "[ERRO]Nao foi possivel abrir o arquivo '$file' $!";
		$data= <$read>;
		close $read;
	} catch {};
	return $data;
}

sub write_file{
	my ($class, $file, $data, $encoding) = @_;

	my $write;
	try {
		open($write, '>:$encoding', $file) or die "[ERRO]Nao foi possivel abrir o arquivo '$file' $!";
		print $write $data;
		close $write;
	} catch {};
}

sub socketSend {
	my ($self, $dst, $data) = @_;
	
	my ($colisao,$time); 
	$colisao = int(rand(10)); 		# colisao se o numero for >= 4
	while($colisao le 4){ 			#ocorreu colisao
		$time = int(rand(10)/10);
		sleep($time); 				# espera um tempo aleatorio
		$colisao = int(rand(10));	#calcula se vai ocorrer outra colisao
	}	
	print $self->{socket} "$data\n";
	threads->exit();
}

sub forwardBit {
	my $self = shift;

	try{
		if (-e "packet_out.pdu" && -e "routed_ip.zap"){
			my $dstIP=$self->read_file("routed_ip.zap","encoding(UTF-8)");
			my $packet=$self->read_file("packet_out.pdu","raw");
			unlink "routed_ip.zap";
			unlink "packet_out.pdu";
			my $dstMAC=$self->arp($dstIP);
			my $bit=Bit->new_toSend($self->{mac}, $dstMAC, $packet);
			my $thread = threads->create(\&socketSend,$self,$dstMAC,$bit) or die "Erro no envio";
			$thread->join();
		}
	}catch{};
}


sub backwardBit {
	my $self = shift;
	#route to other sockets
}

sub receiveClients {
	my $self = shift;
	#add to hash
}